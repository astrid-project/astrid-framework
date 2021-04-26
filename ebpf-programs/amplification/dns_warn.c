#include <uapi/linux/ip.h>
#include <uapi/linux/udp.h>

#define IP_PROTO_UDP 17
#define DNS_PORT 53
#define DNS_QTYPE_INVALID 0
#define DNS_QTYPE_ANY 255


struct dnshdr {
	uint16_t id;
#if __BYTE_ORDER == __BIG_ENDIAN
	uint16_t qr:1;
	uint16_t opcode:4;
	uint16_t aa:1;
	uint16_t tc:1;
	uint16_t rd:1;
	uint16_t ra:1;
	uint16_t zero:3;
	uint16_t rcode:4;
#elif __BYTE_ORDER == __LITTLE_ENDIAN
	uint16_t rd:1;
	uint16_t tc:1;
	uint16_t aa:1;
	uint16_t opcode:4;
	uint16_t qr:1;
	uint16_t rcode:4;
	uint16_t zero:3;
	uint16_t ra:1;
#else
#error \"Adjust your <bits/endian.h> defines\"
#endif
	uint16_t qcount;	/* question count */
	uint16_t ancount;	/* Answer record count */
	uint16_t nscount;	/* Name Server (Autority Record) Count */ 
	uint16_t adcount;	/* Additional Record Count */
} __attribute__((packed));

struct eth_hdr {
    __be64 dst : 48;
    __be64 src : 48;
    __be16 proto;
} __attribute__((packed));


BPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t, 1);
BPF_ARRAY(DNS_QTYPE_ANY_PACKETS_COUNTER, uint64_t, 1);

static __always_inline
unsigned short parse_dns_query(void *query, void *data_end, unsigned int *count)
{
	/* Struct of the query:
	 *	[len] [characters] [len] [characters] [0] [qtype] [qclass]
	 *	  8        len       8        len      8     16       16
	 */

	struct dnslen {
		uint8_t len;
	};
	struct query_type {
		uint16_t value;
	};
	struct dnslen *p;
	struct query_type *qtype;
	uint8_t len = 0;
	*count = 0; 

	/* Loop through the url, until len==0 */
	/* Current limitation: max 10 domains. */
	/* Kernel 4.19 does not allow more than 5 cycles in this case! */
	for(unsigned int i=0; i<3 ; i++) {
		p = query;
		if( query + sizeof(struct dnslen) > data_end)
			return DNS_QTYPE_INVALID;

		len = p->len;

		query+=len+1;
		*count+=len+1; /* Counts the chars + the len field itself */

		if( len == 0 ) {
			break;
		}
	}
	
	qtype = query;
	if( (void *)(qtype+1) > data_end )
		return DNS_QTYPE_INVALID;

	/* Might be improved by checking for specific qclasses (e.g., IN). */
	return ntohs(qtype->value);
}

static __always_inline
int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {
    /*Parsing L2*/
    void *data = (void *) (long) ctx->data;
    void *data_end = (void *) (long) ctx->data_end;
    struct eth_hdr *ethernet = data;
    if (data + sizeof(*ethernet) > data_end)
        return RX_OK;

    if (ethernet->proto != bpf_htons(ETH_P_IP))
        return RX_OK;

    /*Parsing L3*/
    struct iphdr *ip = data + sizeof(struct eth_hdr);
    if (data + sizeof(struct eth_hdr) + sizeof(*ip) > data_end)
        return RX_OK;
    if ((int) ip->version != 4)
        return RX_OK;

    if (ip->protocol != IP_PROTO_UDP)
        return RX_OK;

    /*Parsing L4*/
    uint8_t ip_header_len = 4 * ip->ihl;
    struct udphdr *udp = data + sizeof(*ethernet) + ip_header_len;
    if (data + sizeof(*ethernet) + ip_header_len + sizeof(*udp) > data_end)
        return RX_OK;

    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {
        pcn_log(ctx, LOG_TRACE, \"%I:%P\\t-> %I:%P\", ip->saddr,udp->source,ip->daddr,udp->dest);
        unsigned int key = 0;
        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);
        if (!dns_pckts_counter)
            pcn_log(ctx, LOG_ERR, \"[DNS_AMP_WARNING] Unable to find DNS_PACKETS_COUNTER map\");
        else
            *dns_pckts_counter+=1;

        /*Parsing DNS*/
        struct dnshdr *dnsh = data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr);
        if (data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr) + sizeof(struct dnshdr) > data_end)
            return RX_OK;

	  /* Counts queries both in requests and responses. */

	  unsigned int count = 0; /* First time initalized to 0. */
	  unsigned short qtype = DNS_QTYPE_INVALID;
	  uint16_t num_queries = ntohs(dnsh->qcount);
	  if( num_queries == 0 )
		  return RX_OK;

	  void *query = (void *) dnsh + 12;
	  /* Loop through multiple queries in the same packet. */
	  for(unsigned int i=1; i<4; i++) {
		  query+=count;
		  if( query > data_end )
			  return RX_OK;
		  qtype = parse_dns_query(query, data_end, &count);
	
		  if ( qtype == DNS_QTYPE_INVALID )
			  return RX_OK;
	
		  /* hh 	For integer types, causes printf to expect an int-sized integer argument which was promoted from a char. 
		   * h 	For integer types, causes printf to expect an int-sized integer argument which was promoted from a short.
		   */
	        pcn_log(ctx, LOG_TRACE, \"Query Type: %hu\", qtype);

		/* Stop when an ANY query is seen. */
		if ( qtype == DNS_QTYPE_ANY || i>=num_queries)
			break;

	  }


        if (qtype == DNS_QTYPE_ANY) {
            pcn_log(ctx, LOG_TRACE, \"RECEIVED DNS QUERY ANY\");
            key = 0;
            uint64_t * dns_qtype_any_counter = DNS_QTYPE_ANY_PACKETS_COUNTER.lookup(&key);
            if (!dns_qtype_any_counter)
                pcn_log(ctx, LOG_ERR, \"[DNS_AMP_WARNING] Unable to find DNS_QTYPE_ANY_PACKETS_COUNTER map\");
            else
                *dns_qtype_any_counter+=1;
        }
    }

    return RX_OK;
}
