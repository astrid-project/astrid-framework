#!/bin/bash

function ebpf_program_catalog()
{
  echo -n "'
[
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define RX_DROP 2;\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n#define DNS_QTYPE_INVALID 0\r\n#define DNS_QTYPE_ANY 255\r\n\r\n\r\nstruct dnshdr {\r\n   uint16_t id;\r\n#if __BYTE_ORDER == __BIG_ENDIAN\r\n   uint16_t qr:1;\r\n   uint16_t opcode:4;\r\n   uint16_t aa:1;\r\n   uint16_t tc:1;\r\n   uint16_t rd:1;\r\n   uint16_t ra:1;\r\n   uint16_t zero:3;\r\n   uint16_t rcode:4;\r\n#elif __BYTE_ORDER == __LITTLE_ENDIAN\r\n   uint16_t rd:1;\r\n   uint16_t tc:1;\r\n   uint16_t aa:1;\r\n   uint16_t opcode:4;\r\n   uint16_t qr:1;\r\n   uint16_t rcode:4;\r\n   uint16_t zero:3;\r\n   uint16_t ra:1;\r\n#else\r\n#error \\"Adjust your <bits/endian.h> defines\\"\r\n#endif\r\n   uint16_t qcount;   /* question count */\r\n   uint16_t ancount;   /* Answer record count */\r\n   uint16_t nscount;   /* Name Server (Autority Record) Count */ \r\n   uint16_t adcount;   /* Additional Record Count */\r\n} __attribute__((packed));\r\n\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t, 1);\r\nBPF_ARRAY(DNS_QTYPE_ANY_PACKETS_COUNTER, uint64_t, 1);\r\n\r\nstatic __always_inline\r\nunsigned short parse_dns_query(void *query, void *data_end, unsigned int *count)\r\n{\r\n   /* Struct of the query:\r\n    *   [len] [characters] [len] [characters] [0] [qtype] [qclass]\r\n    *     8        len       8        len      8     16       16\r\n    */\r\n\r\n   struct dnslen {\r\n      uint8_t len;\r\n   };\r\n   struct query_type {\r\n      uint16_t value;\r\n   };\r\n   struct dnslen *p;\r\n   struct query_type *qtype;\r\n   uint8_t len = 0;\r\n   *count = 0; \r\n\r\n   /* Loop through the url, until len==0 */\r\n   /* Current limitation: max 10 domains. */\r\n   /* Kernel 4.19 does not allow more than 5 cycles in this case! */\r\n   for(unsigned int i=0; i<3 ; i++) {\r\n      p = query;\r\n      if( query + sizeof(struct dnslen) > data_end)\r\n         return DNS_QTYPE_INVALID;\r\n\r\n      len = p->len;\r\n\r\n      query+=len+1;\r\n      *count+=len+1; /* Counts the chars + the len field itself */\r\n\r\n      if( len == 0 ) {\r\n         break;\r\n      }\r\n   }\r\n   \r\n   qtype = query;\r\n   if( (void *)(qtype+1) > data_end )\r\n      return DNS_QTYPE_INVALID;\r\n\r\n   /* Might be improved by checking for specific qclasses (e.g., IN). */\r\n   return ntohs(qtype->value);\r\n}\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data;\r\n    if (data + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + ip_header_len;\r\n    if (data + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n\r\n        /*Parsing DNS*/\r\n        struct dnshdr *dnsh = data + ip_header_len + sizeof(struct udphdr);\r\n        if (data + ip_header_len + sizeof(struct udphdr) + sizeof(struct dnshdr) > data_end)\r\n            return RX_OK;\r\n\r\n     /* Counts queries both in requests and responses. */\r\n\r\n     unsigned int count = 0; /* First time initalized to 0. */\r\n     unsigned short qtype = DNS_QTYPE_INVALID;\r\n     uint16_t num_queries = ntohs(dnsh->qcount);\r\n     if( num_queries == 0 )\r\n        return RX_OK;\r\n\r\n     void *query = (void *) dnsh + 12;\r\n     /* Loop through multiple queries in the same packet. */\r\n     for(unsigned int i=1; i<4; i++) {\r\n        query+=count;\r\n        if( query > data_end )\r\n           return RX_OK;\r\n        qtype = parse_dns_query(query, data_end, &count);\r\n   \r\n        if ( qtype == DNS_QTYPE_INVALID )\r\n           return RX_OK;\r\n   \r\n        /* hh    For integer types, causes printf to expect an int-sized integer argument which was promoted from a char. \r\n         * h    For integer types, causes printf to expect an int-sized integer argument which was promoted from a short.\r\n         */\r\n           pcn_log(ctx, LOG_TRACE, \\"Query Type: %hu\\", qtype);\r\n\r\n      /* Stop when an ANY query is seen. */\r\n      if ( qtype == DNS_QTYPE_ANY || i>=num_queries)\r\n         break;\r\n\r\n     }\r\n\r\n\r\n        if (qtype == DNS_QTYPE_ANY) {\r\n            pcn_log(ctx, LOG_TRACE, \\"RECEIVED DNS QUERY ANY\\");\r\n            key = 0;\r\n            uint64_t * dns_qtype_any_counter = DNS_QTYPE_ANY_PACKETS_COUNTER.lookup(&key);\r\n            if (!dns_qtype_any_counter)\r\n                pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_QTYPE_ANY_PACKETS_COUNTER map\\");\r\n            else\r\n                *dns_qtype_any_counter+=1;\r\n   return RX_DROP;\r\n     }\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				},
				{
					\"map-name\": \"DNS_QTYPE_ANY_PACKETS_COUNTER\",
					\"name\": \"Total DNS queries of type ANY\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS queries of type ANY  seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of total DNS packets and ANY query - Raw IP packets version / Drop ANY queries\",
		\"id\": \"dns_drop_ip\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define RX_DROP 2;\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n#define DNS_QTYPE_INVALID 0\r\n#define DNS_QTYPE_ANY 255\r\n\r\n\r\nstruct dnshdr {\r\n   uint16_t id;\r\n#if __BYTE_ORDER == __BIG_ENDIAN\r\n   uint16_t qr:1;\r\n   uint16_t opcode:4;\r\n   uint16_t aa:1;\r\n   uint16_t tc:1;\r\n   uint16_t rd:1;\r\n   uint16_t ra:1;\r\n   uint16_t zero:3;\r\n   uint16_t rcode:4;\r\n#elif __BYTE_ORDER == __LITTLE_ENDIAN\r\n   uint16_t rd:1;\r\n   uint16_t tc:1;\r\n   uint16_t aa:1;\r\n   uint16_t opcode:4;\r\n   uint16_t qr:1;\r\n   uint16_t rcode:4;\r\n   uint16_t zero:3;\r\n   uint16_t ra:1;\r\n#else\r\n#error \\"Adjust your <bits/endian.h> defines\\"\r\n#endif\r\n   uint16_t qcount;   /* question count */\r\n   uint16_t ancount;   /* Answer record count */\r\n   uint16_t nscount;   /* Name Server (Autority Record) Count */ \r\n   uint16_t adcount;   /* Additional Record Count */\r\n} __attribute__((packed));\r\n\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t, 1);\r\nBPF_ARRAY(DNS_QTYPE_ANY_PACKETS_COUNTER, uint64_t, 1);\r\n\r\nstatic __always_inline\r\nunsigned short parse_dns_query(void *query, void *data_end, unsigned int *count)\r\n{\r\n   /* Struct of the query:\r\n    *   [len] [characters] [len] [characters] [0] [qtype] [qclass]\r\n    *     8        len       8        len      8     16       16\r\n    */\r\n\r\n   struct dnslen {\r\n      uint8_t len;\r\n   };\r\n   struct query_type {\r\n      uint16_t value;\r\n   };\r\n   struct dnslen *p;\r\n   struct query_type *qtype;\r\n   uint8_t len = 0;\r\n   *count = 0; \r\n\r\n   /* Loop through the url, until len==0 */\r\n   /* Current limitation: max 10 domains. */\r\n   /* Kernel 4.19 does not allow more than 5 cycles in this case! */\r\n   for(unsigned int i=0; i<3 ; i++) {\r\n      p = query;\r\n      if( query + sizeof(struct dnslen) > data_end)\r\n         return DNS_QTYPE_INVALID;\r\n\r\n      len = p->len;\r\n\r\n      query+=len+1;\r\n      *count+=len+1; /* Counts the chars + the len field itself */\r\n\r\n      if( len == 0 ) {\r\n         break;\r\n      }\r\n   }\r\n   \r\n   qtype = query;\r\n   if( (void *)(qtype+1) > data_end )\r\n      return DNS_QTYPE_INVALID;\r\n\r\n   /* Might be improved by checking for specific qclasses (e.g., IN). */\r\n   return ntohs(qtype->value);\r\n}\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data;\r\n    if (data + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + ip_header_len;\r\n    if (data + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n\r\n        /*Parsing DNS*/\r\n        struct dnshdr *dnsh = data + ip_header_len + sizeof(struct udphdr);\r\n        if (data + ip_header_len + sizeof(struct udphdr) + sizeof(struct dnshdr) > data_end)\r\n            return RX_OK;\r\n\r\n     /* Counts queries both in requests and responses. */\r\n\r\n     unsigned int count = 0; /* First time initalized to 0. */\r\n     unsigned short qtype = DNS_QTYPE_INVALID;\r\n     uint16_t num_queries = ntohs(dnsh->qcount);\r\n     if( num_queries == 0 )\r\n        return RX_OK;\r\n\r\n     void *query = (void *) dnsh + 12;\r\n     /* Loop through multiple queries in the same packet. */\r\n     for(unsigned int i=1; i<4; i++) {\r\n        query+=count;\r\n        if( query > data_end )\r\n           return RX_OK;\r\n        qtype = parse_dns_query(query, data_end, &count);\r\n   \r\n        if ( qtype == DNS_QTYPE_INVALID )\r\n           return RX_OK;\r\n   \r\n        /* hh    For integer types, causes printf to expect an int-sized integer argument which was promoted from a char. \r\n         * h    For integer types, causes printf to expect an int-sized integer argument which was promoted from a short.\r\n         */\r\n           pcn_log(ctx, LOG_TRACE, \\"Query Type: %hu\\", qtype);\r\n\r\n      /* Stop when an ANY query is seen. */\r\n      if ( qtype == DNS_QTYPE_ANY || i>=num_queries)\r\n         break;\r\n\r\n     }\r\n\r\n\r\n        if (qtype == DNS_QTYPE_ANY) {\r\n            pcn_log(ctx, LOG_TRACE, \\"RECEIVED DNS QUERY ANY\\");\r\n            key = 0;\r\n            uint64_t * dns_qtype_any_counter = DNS_QTYPE_ANY_PACKETS_COUNTER.lookup(&key);\r\n            if (!dns_qtype_any_counter)\r\n                pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_QTYPE_ANY_PACKETS_COUNTER map\\");\r\n            else\r\n                *dns_qtype_any_counter+=1;\r\n   return RX_DROP;\r\n     }\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				},
				{
					\"map-name\": \"DNS_QTYPE_ANY_PACKETS_COUNTER\",
					\"name\": \"Total DNS queries of type ANY\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS queries of type ANY  seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of total DNS packets and ANY query - Raw IP packets version / Drop ANY queries\",
		\"id\": \"dns_drop\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n#define DNS_QTYPE_INVALID 0\r\n#define DNS_QTYPE_ANY 255\r\n\r\n\r\nstruct dnshdr {\r\n   uint16_t id;\r\n#if __BYTE_ORDER == __BIG_ENDIAN\r\n   uint16_t qr:1;\r\n   uint16_t opcode:4;\r\n   uint16_t aa:1;\r\n   uint16_t tc:1;\r\n   uint16_t rd:1;\r\n   uint16_t ra:1;\r\n   uint16_t zero:3;\r\n   uint16_t rcode:4;\r\n#elif __BYTE_ORDER == __LITTLE_ENDIAN\r\n   uint16_t rd:1;\r\n   uint16_t tc:1;\r\n   uint16_t aa:1;\r\n   uint16_t opcode:4;\r\n   uint16_t qr:1;\r\n   uint16_t rcode:4;\r\n   uint16_t zero:3;\r\n   uint16_t ra:1;\r\n#else\r\n#error \\"Adjust your <bits/endian.h> defines\\"\r\n#endif\r\n   uint16_t qcount;   /* question count */\r\n   uint16_t ancount;   /* Answer record count */\r\n   uint16_t nscount;   /* Name Server (Autority Record) Count */ \r\n   uint16_t adcount;   /* Additional Record Count */\r\n} __attribute__((packed));\r\n\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t, 1);\r\nBPF_ARRAY(DNS_QTYPE_ANY_PACKETS_COUNTER, uint64_t, 1);\r\n\r\nstatic __always_inline\r\nunsigned short parse_dns_query(void *query, void *data_end, unsigned int *count)\r\n{\r\n   /* Struct of the query:\r\n    *   [len] [characters] [len] [characters] [0] [qtype] [qclass]\r\n    *     8        len       8        len      8     16       16\r\n    */\r\n\r\n   struct dnslen {\r\n      uint8_t len;\r\n   };\r\n   struct query_type {\r\n      uint16_t value;\r\n   };\r\n   struct dnslen *p;\r\n   struct query_type *qtype;\r\n   uint8_t len = 0;\r\n   *count = 0; \r\n\r\n   /* Loop through the url, until len==0 */\r\n   /* Current limitation: max 10 domains. */\r\n   /* Kernel 4.19 does not allow more than 5 cycles in this case! */\r\n   for(unsigned int i=0; i<3 ; i++) {\r\n      p = query;\r\n      if( query + sizeof(struct dnslen) > data_end)\r\n         return DNS_QTYPE_INVALID;\r\n\r\n      len = p->len;\r\n\r\n      query+=len+1;\r\n      *count+=len+1; /* Counts the chars + the len field itself */\r\n\r\n      if( len == 0 ) {\r\n         break;\r\n      }\r\n   }\r\n   \r\n   qtype = query;\r\n   if( (void *)(qtype+1) > data_end )\r\n      return DNS_QTYPE_INVALID;\r\n\r\n   /* Might be improved by checking for specific qclasses (e.g., IN). */\r\n   return ntohs(qtype->value);\r\n}\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data;\r\n    if (data + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + ip_header_len;\r\n    if (data + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n\r\n        /*Parsing DNS*/\r\n        struct dnshdr *dnsh = data + ip_header_len + sizeof(struct udphdr);\r\n        if (data + ip_header_len + sizeof(struct udphdr) + sizeof(struct dnshdr) > data_end)\r\n            return RX_OK;\r\n\r\n     /* Counts queries both in requests and responses. */\r\n\r\n     unsigned int count = 0; /* First time initalized to 0. */\r\n     unsigned short qtype = DNS_QTYPE_INVALID;\r\n     uint16_t num_queries = ntohs(dnsh->qcount);\r\n     if( num_queries == 0 )\r\n        return RX_OK;\r\n\r\n     void *query = (void *) dnsh + 12;\r\n     /* Loop through multiple queries in the same packet. */\r\n     for(unsigned int i=1; i<4; i++) {\r\n        query+=count;\r\n        if( query > data_end )\r\n           return RX_OK;\r\n        qtype = parse_dns_query(query, data_end, &count);\r\n   \r\n        if ( qtype == DNS_QTYPE_INVALID )\r\n           return RX_OK;\r\n   \r\n        /* hh    For integer types, causes printf to expect an int-sized integer argument which was promoted from a char. \r\n         * h    For integer types, causes printf to expect an int-sized integer argument which was promoted from a short.\r\n         */\r\n           pcn_log(ctx, LOG_TRACE, \\"Query Type: %hu\\", qtype);\r\n\r\n      /* Stop when an ANY query is seen. */\r\n      if ( qtype == DNS_QTYPE_ANY || i>=num_queries)\r\n         break;\r\n\r\n     }\r\n\r\n\r\n        if (qtype == DNS_QTYPE_ANY) {\r\n            pcn_log(ctx, LOG_TRACE, \\"RECEIVED DNS QUERY ANY\\");\r\n            key = 0;\r\n            uint64_t * dns_qtype_any_counter = DNS_QTYPE_ANY_PACKETS_COUNTER.lookup(&key);\r\n            if (!dns_qtype_any_counter)\r\n                pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_QTYPE_ANY_PACKETS_COUNTER map\\");\r\n            else\r\n                *dns_qtype_any_counter+=1;\r\n        }\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				},
				{
					\"map-name\": \"DNS_QTYPE_ANY_PACKETS_COUNTER\",
					\"name\": \"Total DNS queries of type ANY\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS queries of type ANY  seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of total DNS packets and ANY query - Raw IP packets version\",
		\"id\": \"dns_warn_ip\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <linux/if_vlan.h>\r\n#include <linux/if_ether.h>      // struct ethhdr\r\n#include <linux/pkt_cls.h>\r\n#include <linux/time.h>\r\n#include <linux/if_ether.h>\r\n#include <linux/ip.h>\r\n#include <linux/ipv6.h>\r\n#include <linux/icmp.h>\r\n#include <linux/tcp.h>\r\n#include <linux/udp.h>\r\n#include <linux/ip.h>\r\n\r\n#define BINBASE 12 \r\n#define NBINS 0x1<<BINBASE\r\n\r\n/* TODO: Improve performance by using multiple per-cpu hash maps.\r\n */\r\nBPF_ARRAY(fl_stats, __u32, NBINS);\r\n\r\n/* Header cursor to keep track of current parsing position */\r\nstruct hdr_cursor {\r\n        void *pos;\r\n};\r\n\r\nstatic __always_inline int proto_is_vlan(__u16 h_proto)\r\n{\r\n        return !!(h_proto == bpf_htons(ETH_P_8021Q) ||\r\n                  h_proto == bpf_htons(ETH_P_8021AD));\r\n}\r\n\r\n/*\r\n      * Struct icmphdr_common represents the common part of the icmphdr and icmp6hdr\r\n      *  * structures.\r\n      *   */\r\nstruct icmphdr_common {\r\n        __u8   type;\r\n   __u8    code;\r\n   __sum16 cksum;\r\n};\r\n\r\n\r\n/* Parse the Ethernet header and return protocol.\r\n * Ignore VLANs.\r\n *\r\n * Protocol is returned in network byte order.\r\n */\r\nstatic __always_inline int parse_ethhdr(struct hdr_cursor *nh,\r\n                                        void *data_end,\r\n                                        struct ethhdr **ethhdr)\r\n{\r\n       struct ethhdr *eth = nh->pos;\r\n        int hdrsize = sizeof(*eth);\r\n        struct vlan_hdr *vlh;\r\n        __u16 h_proto;\r\n        int i;\r\n\r\n        /* Byte-count bounds check; check if current pointer + size of header\r\n         * is after data_end.\r\n         */\r\n        if (nh->pos + hdrsize > data_end)\r\n                return -1;\r\n\r\n        nh->pos += hdrsize;\r\n        *ethhdr = eth;\r\n        vlh = nh->pos;\r\n        h_proto = eth->h_proto;\r\n\r\n        /* Use loop unrolling to avoid the verifier restriction on loops;\r\n         * support up to VLAN_MAX_DEPTH layers of VLAN encapsulation.\r\n         */\r\n        #pragma unroll\r\n        for (i = 0; i < VLAN_MAX_DEPTH; i++) {\r\n                if (!proto_is_vlan(h_proto))\r\n                        break;\r\n\r\n                if ( (void *)(vlh + 1) > data_end)\r\n                        break;\r\n\r\n                h_proto = vlh->h_vlan_encapsulated_proto;\r\n                vlh++;\r\n        }\r\n\r\n        nh->pos = vlh;\r\n        return h_proto; /* network-byte-order */\r\n\r\n\r\n}\r\n\r\nstatic __always_inline int parse_ip6hdr(struct hdr_cursor *nh,\r\n               void *data_end,\r\n               struct ipv6hdr **ip6hdr)\r\n{\r\n   struct ipv6hdr *ip6h = nh->pos;\r\n\r\n    if ( (void *)(ip6h + 1) > data_end)\r\n      return -1;\r\n\r\n   nh->pos = ip6h + 1;\r\n   *ip6hdr = ip6h;\r\n\r\n   return ip6h->nexthdr;\r\n}\r\n\r\nstatic __always_inline int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) \r\n{\r\n   /* Preliminary step: cast to void*.\r\n    * (Not clear why data/data_end are stored as long)\r\n    */\r\n   void *data_end = (void *)(long)ctx->data_end;\r\n   void *data     = (void *)(long)ctx->data;\r\n   __u32 ipv6field = 0;\r\n   __u32 len = 0;\r\n   __u32 init_value = 1;\r\n   int eth_proto, ip_proto = 0;\r\n   struct hdr_cursor nh;\r\n   struct ethhdr *eth;\r\n   struct ipv6hdr* iph6;\r\n\r\n   /* Parse Ethernet header and verify protocol number. */\r\n   nh.pos = data;\r\n   len = data_end - data;\r\n   eth = (struct ethhdr *)data;\r\n   eth_proto = parse_ethhdr(&nh, data_end, &eth);\r\n   if ( eth_proto < 0 ) {\r\n      return TC_ACT_OK; /* TODO: XDP_ABORT? */\r\n   }\r\n   if ( eth_proto != bpf_htons(ETH_P_IPV6) )\r\n   {\r\n      return TC_ACT_OK;\r\n   }\r\n\r\n   /* Parse IP header and verify protocol number. */\r\n   if( (ip_proto = parse_ip6hdr(&nh, data_end, &iph6)) < 0 ) {\r\n      return TC_ACT_OK;\r\n   }   \r\n\r\n   /* Check flow label\r\n    */\r\n   if( (void*) iph6 + sizeof(struct ipv6hdr) < data_end) {\r\n      for(short i=0;i<3;i++) {\r\n        ipv6field |= iph6->flow_lbl[i];\r\n        if(i==0) {\r\n            /* Remove DSCP value */\r\n            ipv6field &=0x0f;\r\n        }\r\n        if(i!=2)\r\n            ipv6field <<= 8;\r\n      }\r\n   }\r\n\r\n   /* Collect the required statistics. */\r\n\r\n   __u32 key = ipv6field >> (20-BINBASE);\r\n   __u32 *counter = \r\n      fl_stats.lookup(&key);\r\n\r\n   if(!counter)\r\n      fl_stats.update(&key, &init_value);\r\n   else\r\n      __sync_fetch_and_add(counter, 1);\r\n\r\n     \r\n\r\n   return TC_ACT_OK;\r\n}\r\n\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"fl_stats\",
					\"name\": \"Flow label occurrences\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics measures the distribution of flow label values in IPv6 packets\",
						\"labels\": [
							{
								\"name\": \"IP_VERS\",
								\"value\": \"IPv6\"
							},
							{
								\"name\": \"FIELD\",
								\"value\": \"FLOW_LABEL\"
							}
						],
						\"type\": \"histogram\"
					}
				}
			]
		},
		\"description\": \"Histogram of the values used for flow labels in IPv6 packets\",
		\"id\": \"fl\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <linux/if_vlan.h>\r\n#include <linux/if_ether.h>      // struct ethhdr\r\n#include <linux/pkt_cls.h>\r\n#include <linux/time.h>\r\n#include <linux/if_ether.h>\r\n#include <linux/ip.h>\r\n#include <linux/ipv6.h>\r\n#include <linux/icmp.h>\r\n#include <linux/tcp.h>\r\n#include <linux/udp.h>\r\n#include <linux/ip.h>\r\n\r\n#define BINBASE 8 \r\n#define NBINS 0x1<<BINBASE\r\n\r\n/* TODO: Improve performance by using multiple per-cpu hash maps.\r\n */\r\nBPF_ARRAY(tc_stats, __u32, NBINS);\r\n\r\n/* Header cursor to keep track of current parsing position */\r\nstruct hdr_cursor {\r\n        void *pos;\r\n};\r\n\r\nstatic __always_inline int proto_is_vlan(__u16 h_proto)\r\n{\r\n        return !!(h_proto == bpf_htons(ETH_P_8021Q) ||\r\n                  h_proto == bpf_htons(ETH_P_8021AD));\r\n}\r\n\r\n/*\r\n      * Struct icmphdr_common represents the common part of the icmphdr and icmp6hdr\r\n      *  * structures.\r\n      *   */\r\nstruct icmphdr_common {\r\n        __u8   type;\r\n   __u8    code;\r\n   __sum16 cksum;\r\n};\r\n\r\n\r\n/* Parse the Ethernet header and return protocol.\r\n * Ignore VLANs.\r\n *\r\n * Protocol is returned in network byte order.\r\n */\r\nstatic __always_inline int parse_ethhdr(struct hdr_cursor *nh,\r\n                                        void *data_end,\r\n                                        struct ethhdr **ethhdr)\r\n{\r\n       struct ethhdr *eth = nh->pos;\r\n        int hdrsize = sizeof(*eth);\r\n        struct vlan_hdr *vlh;\r\n        __u16 h_proto;\r\n        int i;\r\n\r\n        /* Byte-count bounds check; check if current pointer + size of header\r\n         * is after data_end.\r\n         */\r\n        if (nh->pos + hdrsize > data_end)\r\n                return -1;\r\n\r\n        nh->pos += hdrsize;\r\n        *ethhdr = eth;\r\n        vlh = nh->pos;\r\n        h_proto = eth->h_proto;\r\n\r\n        /* Use loop unrolling to avoid the verifier restriction on loops;\r\n         * support up to VLAN_MAX_DEPTH layers of VLAN encapsulation.\r\n         */\r\n        #pragma unroll\r\n        for (i = 0; i < VLAN_MAX_DEPTH; i++) {\r\n                if (!proto_is_vlan(h_proto))\r\n                        break;\r\n\r\n                if ( (void *)(vlh + 1) > data_end)\r\n                        break;\r\n\r\n                h_proto = vlh->h_vlan_encapsulated_proto;\r\n                vlh++;\r\n        }\r\n\r\n        nh->pos = vlh;\r\n        return h_proto; /* network-byte-order */\r\n\r\n\r\n}\r\n\r\nstatic __always_inline int parse_ip6hdr(struct hdr_cursor *nh,\r\n               void *data_end,\r\n               struct ipv6hdr **ip6hdr)\r\n{\r\n   struct ipv6hdr *ip6h = nh->pos;\r\n\r\n    if ( (void *)(ip6h + 1) > data_end)\r\n      return -1;\r\n\r\n   nh->pos = ip6h + 1;\r\n   *ip6hdr = ip6h;\r\n\r\n   return ip6h->nexthdr;\r\n}\r\n\r\nstatic __always_inline int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) \r\n{\r\n   /* Preliminary step: cast to void*.\r\n    * (Not clear why data/data_end are stored as long)\r\n    */\r\n   void *data_end = (void *)(long)ctx->data_end;\r\n   void *data     = (void *)(long)ctx->data;\r\n   __u32 ipv6field = 0;\r\n   __u32 len = 0;\r\n   __u32 init_value = 1;\r\n   int eth_proto, ip_proto = 0;\r\n   struct hdr_cursor nh;\r\n   struct ethhdr *eth;\r\n   struct ipv6hdr* iph6;\r\n\r\n   /* Parse Ethernet header and verify protocol number. */\r\n   nh.pos = data;\r\n   len = data_end - data;\r\n   eth = (struct ethhdr *)data;\r\n   eth_proto = parse_ethhdr(&nh, data_end, &eth);\r\n   if ( eth_proto < 0 ) {\r\n      return TC_ACT_OK; /* TODO: XDP_ABORT? */\r\n   }\r\n   if ( eth_proto != bpf_htons(ETH_P_IPV6) )\r\n   {\r\n      return TC_ACT_OK;\r\n   }\r\n\r\n   /* Parse IP header and verify protocol number. */\r\n   if( (ip_proto = parse_ip6hdr(&nh, data_end, &iph6)) < 0 ) {\r\n      return TC_ACT_OK;\r\n   }   \r\n\r\n   /* Check traffic class\r\n    */\r\n   if( (void*) iph6 + sizeof(struct ipv6hdr) < data_end) {\r\n      ipv6field = iph6->priority;\r\n      ipv6field <<=4;\r\n      /* Remove the byte used for the flow label */\r\n      ipv6field |= (iph6->flow_lbl[0] >> 4);\r\n   }\r\n\r\n   /* Collect the required statistics. */\r\n\r\n   __u32 key = ipv6field >> (8-BINBASE);\r\n   __u32 *counter = \r\n      tc_stats.lookup(&key);\r\n\r\n   if(!counter)\r\n      tc_stats.update(&key, &init_value);\r\n   else\r\n      __sync_fetch_and_add(counter, 1);\r\n\r\n     \r\n\r\n   return TC_ACT_OK;\r\n}\r\n\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"tc_stats\",
					\"name\": \"Traffic Class occurrences\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics measures the distribution of traffic class values in IPv6 packets.\",
						\"labels\": [
							{
								\"name\": \"IP_VERS\",
								\"value\": \"IPv6\"
							},
							{
								\"name\": \"FIELD\",
								\"value\": \"TRAFFIC_CLASS\"
							}
						],
						\"type\": \"histogram\"
					}
				}
			]
		},
		\"description\": \"Histogram of the values used for traffic control in IPv6 packets\",
		\"id\": \"tc\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <linux/if_vlan.h>\r\n#include <linux/if_ether.h>      // struct ethhdr\r\n#include <linux/pkt_cls.h>\r\n#include <linux/time.h>\r\n#include <linux/if_ether.h>\r\n#include <linux/ip.h>\r\n#include <linux/ipv6.h>\r\n#include <linux/icmp.h>\r\n#include <linux/tcp.h>\r\n#include <linux/udp.h>\r\n#include <linux/ip.h>\r\n\r\n#define BINBASE 8 \r\n#define NBINS 0x1<<BINBASE\r\n\r\n/* TODO: Improve performance by using multiple per-cpu hash maps.\r\n */\r\nBPF_ARRAY(hl_stats, __u32, NBINS);\r\n\r\n/* Header cursor to keep track of current parsing position */\r\nstruct hdr_cursor {\r\n        void *pos;\r\n};\r\n\r\nstatic __always_inline int proto_is_vlan(__u16 h_proto)\r\n{\r\n        return !!(h_proto == bpf_htons(ETH_P_8021Q) ||\r\n                  h_proto == bpf_htons(ETH_P_8021AD));\r\n}\r\n\r\n/*\r\n      * Struct icmphdr_common represents the common part of the icmphdr and icmp6hdr\r\n      *  * structures.\r\n      *   */\r\nstruct icmphdr_common {\r\n        __u8   type;\r\n   __u8    code;\r\n   __sum16 cksum;\r\n};\r\n\r\n\r\n/* Parse the Ethernet header and return protocol.\r\n * Ignore VLANs.\r\n *\r\n * Protocol is returned in network byte order.\r\n */\r\nstatic __always_inline int parse_ethhdr(struct hdr_cursor *nh,\r\n                                        void *data_end,\r\n                                        struct ethhdr **ethhdr)\r\n{\r\n       struct ethhdr *eth = nh->pos;\r\n        int hdrsize = sizeof(*eth);\r\n        struct vlan_hdr *vlh;\r\n        __u16 h_proto;\r\n        int i;\r\n\r\n        /* Byte-count bounds check; check if current pointer + size of header\r\n         * is after data_end.\r\n         */\r\n        if (nh->pos + hdrsize > data_end)\r\n                return -1;\r\n\r\n        nh->pos += hdrsize;\r\n        *ethhdr = eth;\r\n        vlh = nh->pos;\r\n        h_proto = eth->h_proto;\r\n\r\n        /* Use loop unrolling to avoid the verifier restriction on loops;\r\n         * support up to VLAN_MAX_DEPTH layers of VLAN encapsulation.\r\n         */\r\n        #pragma unroll\r\n        for (i = 0; i < VLAN_MAX_DEPTH; i++) {\r\n                if (!proto_is_vlan(h_proto))\r\n                        break;\r\n\r\n                if ( (void *)(vlh + 1) > data_end)\r\n                        break;\r\n\r\n                h_proto = vlh->h_vlan_encapsulated_proto;\r\n                vlh++;\r\n        }\r\n\r\n        nh->pos = vlh;\r\n        return h_proto; /* network-byte-order */\r\n\r\n\r\n}\r\n\r\nstatic __always_inline int parse_ip6hdr(struct hdr_cursor *nh,\r\n               void *data_end,\r\n               struct ipv6hdr **ip6hdr)\r\n{\r\n   struct ipv6hdr *ip6h = nh->pos;\r\n\r\n    if ( (void *)(ip6h + 1) > data_end)\r\n      return -1;\r\n\r\n   nh->pos = ip6h + 1;\r\n   *ip6hdr = ip6h;\r\n\r\n   return ip6h->nexthdr;\r\n}\r\n\r\nstatic __always_inline int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) \r\n{\r\n   /* Preliminary step: cast to void*.\r\n    * (Not clear why data/data_end are stored as long)\r\n    */\r\n   void *data_end = (void *)(long)ctx->data_end;\r\n   void *data     = (void *)(long)ctx->data;\r\n   __u32 ipv6field = 0;\r\n   __u32 len = 0;\r\n   __u32 init_value = 1;\r\n   int eth_proto, ip_proto = 0;\r\n   struct hdr_cursor nh;\r\n   struct ethhdr *eth;\r\n   struct ipv6hdr* iph6;\r\n\r\n   /* Parse Ethernet header and verify protocol number. */\r\n   nh.pos = data;\r\n   len = data_end - data;\r\n   eth = (struct ethhdr *)data;\r\n   eth_proto = parse_ethhdr(&nh, data_end, &eth);\r\n   if ( eth_proto < 0 ) {\r\n      return TC_ACT_OK; /* TODO: XDP_ABORT? */\r\n   }\r\n   if ( eth_proto != bpf_htons(ETH_P_IPV6) )\r\n   {\r\n      return TC_ACT_OK;\r\n   }\r\n\r\n   /* Parse IP header and verify protocol number. */\r\n   if( (ip_proto = parse_ip6hdr(&nh, data_end, &iph6)) < 0 ) {\r\n      return TC_ACT_OK;\r\n   }   \r\n\r\n   /* Check flow label\r\n    */\r\n   if( (void*) iph6 + sizeof(struct ipv6hdr) < data_end) {\r\n       ipv6field = iph6->hop_limit;\r\n   }\r\n\r\n   /* Collect the required statistics. */\r\n\r\n   __u32 key = ipv6field >> (8-BINBASE);\r\n   __u32 *counter = \r\n      hl_stats.lookup(&key);\r\n\r\n   if(!counter)\r\n      hl_stats.update(&key, &init_value);\r\n   else\r\n      __sync_fetch_and_add(counter, 1);\r\n\r\n     \r\n\r\n   return TC_ACT_OK;\r\n}\r\n\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"hl_stats\",
					\"name\": \"Hop Limit occurrences\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics measures the distribution of hop limit values in IPv6 packets.\",
						\"labels\": [
							{
								\"name\": \"IP_VERS\",
								\"value\": \"IPv6\"
							},
							{
								\"name\": \"FIELD\",
								\"value\": \"HOP_LIMIT\"
							}
						],
						\"type\": \"histogram\"
					}
				}
			]
		},
		\"description\": \"Histogram of the values used for hop limit in IPv6 packets\",
		\"id\": \"hl\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": [
				\"#include <uapi/linux/ip.h>\",
				\"#include <uapi/linux/udp.h>\",
				\"#define IP_PROTO_UDP 17\",
				\"#define NTP_PORT 123\",
				\"#define NTP_MODE_PRIVATE 7\",
				\"#define MODE(li_vn_mode) (uint8_t) ((li_vn_mode & 0x07) >> 0)\",
				\"struct eth_hdr {\",
				\"    __be64 dst : 48;\",
				\"    __be64 src : 48;\",
				\"    __be16 proto;\",
				\"} __attribute__((packed));\",
				\"struct ntp_packet {\",
				\"    uint8_t li_vn_mode;\",
				\"    uint8_t stratum;\",
				\"    uint8_t poll;\",
				\"    uint8_t precision;\",
				\"    uint32_t rootDelay;\",
				\"    uint32_t rootDispersion;\",
				\"    uint32_t refId;\",
				\"    uint32_t refTm_s;\",
				\"    uint32_t refTm_f;\",
				\"    uint32_t origTm_s;\",
				\"    uint32_t origTm_f;\",
				\"    uint32_t rxTm_s;\",
				\"    uint32_t rxTm_f;\",
				\"    uint32_t txTm_s;\",
				\"    uint32_t txTm_f;\",
				\"} __attribute__((packed));\",
				\"BPF_ARRAY(NTP_PACKETS_COUNTER, uint64_t, 1);\",
				\"BPF_ARRAY(NTP_MODE_PRIVATE_PACKETS_COUNTER, uint64_t, 1);\",
				\"static __always_inline\",
				\"int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\",
				\"    /*Parsing L2*/\",
				\"    void *data = (void *) (long) ctx->data;\",
				\"    void *data_end = (void *) (long) ctx->data_end;\",
				\"    struct eth_hdr *ethernet = data;\",
				\"    if (data + sizeof(*ethernet) > data_end)\",
				\"        return RX_OK;\",
				\"    if (ethernet->proto != bpf_htons(ETH_P_IP))\",
				\"        return RX_OK;\",
				\"    /*Parsing L3*/\",
				\"    struct iphdr *ip = data + sizeof(struct eth_hdr);\",
				\"    if (data + sizeof(struct eth_hdr) + sizeof(*ip) > data_end)\",
				\"        return RX_OK;\",
				\"    if ((int) ip->version != 4)\",
				\"        return RX_OK;\",
				\"    if (ip->protocol != IP_PROTO_UDP)\",
				\"        return RX_OK;\",
				\"    /*Parsing L4*/\",
				\"    uint8_t ip_header_len = 4 * ip->ihl;\",
				\"    struct udphdr *udp = data + sizeof(*ethernet) + ip_header_len;\",
				\"    if (data + sizeof(*ethernet) + ip_header_len + sizeof(*udp) > data_end)\",
				\"        return RX_OK;\",
				\"    if (udp->source == bpf_htons(NTP_PORT) || udp->dest == bpf_htons(NTP_PORT)) {\",
				\"        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\",
				\"        unsigned int key = 0;\",
				\"        uint64_t * ntp_pckts_counter = NTP_PACKETS_COUNTER.lookup(&key);\",
				\"        if (!ntp_pckts_counter)\",
				\"            pcn_log(ctx, LOG_ERR, \\"[NTP_AMP_WARNING] Unable to find NTP_PACKETS_COUNTER map\\");\",
				\"        else\",
				\"            *ntp_pckts_counter+=1;\",
				\"        /*Parsing NTP*/\",
				\"        struct ntp_packet *ntp = data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr);\",
				\"        if (data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr) + sizeof(*ntp) > data_end)\",
				\"            return RX_OK;\",
				\"        uint8_t mode = MODE(ntp->li_vn_mode);\",
				\"        pcn_log(ctx, LOG_TRACE, \\"NTP mode: %hhu\\", mode);\",
				\"        if (mode == NTP_MODE_PRIVATE) {\",
				\"            pcn_log(ctx, LOG_TRACE, \\"RECEIVED NTP MODE 7\\");\",
				\"            key = 0;\",
				\"            uint64_t * ntp_mode_private_counter = NTP_MODE_PRIVATE_PACKETS_COUNTER.lookup(&key);\",
				\"            if (!ntp_mode_private_counter)\",
				\"                pcn_log(ctx, LOG_ERR, \\"[NTP_AMP_WARNING] Unable to find NTP_MODE_PRIVATE_PACKETS_COUNTER map\\");\",
				\"            else\",
				\"                *ntp_mode_private_counter+=1;\",
				\"        }\",
				\"    }\",
				\"    return RX_OK;\",
				\"}\"
			],
			\"metrics\": [
				{
					\"map-name\": \"NTP_PACKETS_COUNTER\",
					\"name\": \"ntp_packets_total\",
					\"open-metrics-metadata\": {
						\"help\": \"This metric represents the number of NTP packets that has traveled through this probe.\",
						\"labels\": [
							{
								\"name\": \"IP_PROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"NTP\"
							}
						],
						\"type\": \"counter\"
					}
				},
				{
					\"map-name\": \"NTP_MODE_PRIVATE_PACKETS_COUNTER\",
					\"name\": \"ntp_mode_private_packets_total\",
					\"open-metrics-metadata\": {
						\"help\": \"This metric represents the number of NTP packets with MODE = 7 (MODE_PRIVATE) that has traveled through this probe.\",
						\"labels\": [
							{
								\"name\": \"IP_PROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"NTP\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"NTP packets capture for BAU and WARN\",
		\"id\": \"ntp_bau_and_warn\",
		\"parameters\": [
			{
				\"description\": \"NTP packets capture for BAU and WARN\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": [
				\"#include <uapi/linux/ip.h>\",
				\"#include <uapi/linux/udp.h>\",
				\"\",
				\"#define IP_PROTO_UDP 17\",
				\"#define NTP_PORT 123\",
				\"\",
				\"struct eth_hdr {\",
				\"    __be64 dst : 48;\",
				\"    __be64 src : 48;\",
				\"    __be16 proto;\",
				\"} __attribute__((packed));\",
				\"\",
				\"BPF_ARRAY(NTP_PACKETS_COUNTER, uint64_t,1);\",
				\"\",
				\"static __always_inline\",
				\"int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\",
				\"    /*Parsing L2*/\",
				\"    void *data = (void *) (long) ctx->data;\",
				\"    void *data_end = (void *) (long) ctx->data_end;\",
				\"    struct eth_hdr *ethernet = data;\",
				\"    if (data + sizeof(*ethernet) > data_end)\",
				\"        return RX_OK;\",
				\"\",
				\"    if (ethernet->proto != bpf_htons(ETH_P_IP))\",
				\"        return RX_OK;\",
				\"\",
				\"    /*Parsing L3*/\",
				\"    struct iphdr *ip = data + sizeof(struct eth_hdr);\",
				\"    if (data + sizeof(struct eth_hdr) + sizeof(*ip) > data_end)\",
				\"        return RX_OK;\",
				\"    if ((int) ip->version != 4)\",
				\"        return RX_OK;\",
				\"\",
				\"    if (ip->protocol != IP_PROTO_UDP)\",
				\"        return RX_OK;\",
				\"\",
				\"    /*Parsing L4*/\",
				\"    uint8_t ip_header_len = 4 * ip->ihl;\",
				\"    struct udphdr *udp = data + sizeof(*ethernet) + ip_header_len;\",
				\"    if (data + sizeof(*ethernet) + ip_header_len + sizeof(*udp) > data_end)\",
				\"        return RX_OK;\",
				\"\",
				\"    if (udp->source == bpf_htons(NTP_PORT) || udp->dest == bpf_htons(NTP_PORT)) {\",
				\"        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\",
				\"        unsigned int key = 0;\",
				\"        uint64_t * ntp_pckts_counter = NTP_PACKETS_COUNTER.lookup(&key);\",
				\"        if (!ntp_pckts_counter)\",
				\"            pcn_log(ctx, LOG_ERR, \\"[NTP_AMP_BUA] Unable to find NTP_PACKETS_COUNTER map\\");\",
				\"        else\",
				\"            *ntp_pckts_counter+=1;\",
				\"    }\",
				\"\",
				\"    return RX_OK;\",
				\"}\"
			],
			\"metrics\": [
				{
					\"map-name\": \"NTP_PACKETS_COUNTER\",
					\"name\": \"ntp_packets_total\",
					\"open-metrics-metadata\": {
						\"help\": \"This metric represents the number of NTP packets that has traveled through this probe.\",
						\"labels\": [
							{
								\"name\": \"IP_PROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"NTP\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"NTP packets capture for BAU only\",
		\"id\": \"ntp_bau\",
		\"parameters\": [
			{
				\"description\": \"NTP packets capture for BAU only\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n\r\nstruct eth_hdr {\r\n    __be64 dst : 48;\r\n    __be64 src : 48;\r\n    __be16 proto;\r\n} __attribute__((packed));\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t,1);\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n\r\n    /*Parsing L2*/\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n    struct eth_hdr *ethernet = data;\r\n    if (data + sizeof(*ethernet) > data_end)\r\n        return RX_OK;\r\n\r\n    if (ethernet->proto != bpf_htons(ETH_P_IP))\r\n        return RX_OK;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data + sizeof(struct eth_hdr);\r\n    if (data + sizeof(struct eth_hdr) + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + sizeof(*ethernet) + ip_header_len;\r\n    if (data + sizeof(*ethernet) + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_BUA] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of all DNS packets\",
		\"id\": \"dns_bau\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t,1);\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data; \r\n    if (data + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + ip_header_len;\r\n    if (data + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_BUA] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of all DNS packets - Raw IP packets version\",
		\"id\": \"dns_bau_ip\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	},
	{
		\"config\": {
			\"code\": \"#include <uapi/linux/ip.h>\r\n#include <uapi/linux/udp.h>\r\n\r\n#define IP_PROTO_UDP 17\r\n#define DNS_PORT 53\r\n#define DNS_QTYPE_INVALID 0\r\n#define DNS_QTYPE_ANY 255\r\n\r\n\r\nstruct dnshdr {\r\n   uint16_t id;\r\n#if __BYTE_ORDER == __BIG_ENDIAN\r\n   uint16_t qr:1;\r\n   uint16_t opcode:4;\r\n   uint16_t aa:1;\r\n   uint16_t tc:1;\r\n   uint16_t rd:1;\r\n   uint16_t ra:1;\r\n   uint16_t zero:3;\r\n   uint16_t rcode:4;\r\n#elif __BYTE_ORDER == __LITTLE_ENDIAN\r\n   uint16_t rd:1;\r\n   uint16_t tc:1;\r\n   uint16_t aa:1;\r\n   uint16_t opcode:4;\r\n   uint16_t qr:1;\r\n   uint16_t rcode:4;\r\n   uint16_t zero:3;\r\n   uint16_t ra:1;\r\n#else\r\n#error \\"Adjust your <bits/endian.h> defines\\"\r\n#endif\r\n   uint16_t qcount;   /* question count */\r\n   uint16_t ancount;   /* Answer record count */\r\n   uint16_t nscount;   /* Name Server (Autority Record) Count */ \r\n   uint16_t adcount;   /* Additional Record Count */\r\n} __attribute__((packed));\r\n\r\nstruct eth_hdr {\r\n    __be64 dst : 48;\r\n    __be64 src : 48;\r\n    __be16 proto;\r\n} __attribute__((packed));\r\n\r\n\r\nBPF_ARRAY(DNS_PACKETS_COUNTER, uint64_t, 1);\r\nBPF_ARRAY(DNS_QTYPE_ANY_PACKETS_COUNTER, uint64_t, 1);\r\n\r\nstatic __always_inline\r\nunsigned short parse_dns_query(void *query, void *data_end, unsigned int *count)\r\n{\r\n   /* Struct of the query:\r\n    *   [len] [characters] [len] [characters] [0] [qtype] [qclass]\r\n    *     8        len       8        len      8     16       16\r\n    */\r\n\r\n   struct dnslen {\r\n      uint8_t len;\r\n   };\r\n   struct query_type {\r\n      uint16_t value;\r\n   };\r\n   struct dnslen *p;\r\n   struct query_type *qtype;\r\n   uint8_t len = 0;\r\n   *count = 0; \r\n\r\n   /* Loop through the url, until len==0 */\r\n   /* Current limitation: max 10 domains. */\r\n   /* Kernel 4.19 does not allow more than 5 cycles in this case! */\r\n   for(unsigned int i=0; i<3 ; i++) {\r\n      p = query;\r\n      if( query + sizeof(struct dnslen) > data_end)\r\n         return DNS_QTYPE_INVALID;\r\n\r\n      len = p->len;\r\n\r\n      query+=len+1;\r\n      *count+=len+1; /* Counts the chars + the len field itself */\r\n\r\n      if( len == 0 ) {\r\n         break;\r\n      }\r\n   }\r\n   \r\n   qtype = query;\r\n   if( (void *)(qtype+1) > data_end )\r\n      return DNS_QTYPE_INVALID;\r\n\r\n   /* Might be improved by checking for specific qclasses (e.g., IN). */\r\n   return ntohs(qtype->value);\r\n}\r\n\r\nstatic __always_inline\r\nint handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) {\r\n    /*Parsing L2*/\r\n    void *data = (void *) (long) ctx->data;\r\n    void *data_end = (void *) (long) ctx->data_end;\r\n    struct eth_hdr *ethernet = data;\r\n    if (data + sizeof(*ethernet) > data_end)\r\n        return RX_OK;\r\n\r\n    if (ethernet->proto != bpf_htons(ETH_P_IP))\r\n        return RX_OK;\r\n\r\n    /*Parsing L3*/\r\n    struct iphdr *ip = data + sizeof(struct eth_hdr);\r\n    if (data + sizeof(struct eth_hdr) + sizeof(*ip) > data_end)\r\n        return RX_OK;\r\n    if ((int) ip->version != 4)\r\n        return RX_OK;\r\n\r\n    if (ip->protocol != IP_PROTO_UDP)\r\n        return RX_OK;\r\n\r\n    /*Parsing L4*/\r\n    uint8_t ip_header_len = 4 * ip->ihl;\r\n    struct udphdr *udp = data + sizeof(*ethernet) + ip_header_len;\r\n    if (data + sizeof(*ethernet) + ip_header_len + sizeof(*udp) > data_end)\r\n        return RX_OK;\r\n\r\n    if (udp->source == bpf_htons(DNS_PORT) || udp->dest == bpf_htons(DNS_PORT)) {\r\n        pcn_log(ctx, LOG_TRACE, \\"%I:%P\\t-> %I:%P\\", ip->saddr,udp->source,ip->daddr,udp->dest);\r\n        unsigned int key = 0;\r\n        uint64_t * dns_pckts_counter = DNS_PACKETS_COUNTER.lookup(&key);\r\n        if (!dns_pckts_counter)\r\n            pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_PACKETS_COUNTER map\\");\r\n        else\r\n            *dns_pckts_counter+=1;\r\n\r\n        /*Parsing DNS*/\r\n        struct dnshdr *dnsh = data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr);\r\n        if (data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr) + sizeof(struct dnshdr) > data_end)\r\n            return RX_OK;\r\n\r\n     /* Counts queries both in requests and responses. */\r\n\r\n     unsigned int count = 0; /* First time initalized to 0. */\r\n     unsigned short qtype = DNS_QTYPE_INVALID;\r\n     uint16_t num_queries = ntohs(dnsh->qcount);\r\n     if( num_queries == 0 )\r\n        return RX_OK;\r\n\r\n     void *query = (void *) dnsh + 12;\r\n     /* Loop through multiple queries in the same packet. */\r\n     for(unsigned int i=1; i<4; i++) {\r\n        query+=count;\r\n        if( query > data_end )\r\n           return RX_OK;\r\n        qtype = parse_dns_query(query, data_end, &count);\r\n   \r\n        if ( qtype == DNS_QTYPE_INVALID )\r\n           return RX_OK;\r\n   \r\n        /* hh    For integer types, causes printf to expect an int-sized integer argument which was promoted from a char. \r\n         * h    For integer types, causes printf to expect an int-sized integer argument which was promoted from a short.\r\n         */\r\n           pcn_log(ctx, LOG_TRACE, \\"Query Type: %hu\\", qtype);\r\n\r\n      /* Stop when an ANY query is seen. */\r\n      if ( qtype == DNS_QTYPE_ANY || i>=num_queries)\r\n         break;\r\n\r\n     }\r\n\r\n\r\n        if (qtype == DNS_QTYPE_ANY) {\r\n            pcn_log(ctx, LOG_TRACE, \\"RECEIVED DNS QUERY ANY\\");\r\n            key = 0;\r\n            uint64_t * dns_qtype_any_counter = DNS_QTYPE_ANY_PACKETS_COUNTER.lookup(&key);\r\n            if (!dns_qtype_any_counter)\r\n                pcn_log(ctx, LOG_ERR, \\"[DNS_AMP_WARNING] Unable to find DNS_QTYPE_ANY_PACKETS_COUNTER map\\");\r\n            else\r\n                *dns_qtype_any_counter+=1;\r\n        }\r\n    }\r\n\r\n    return RX_OK;\r\n}\r\n\",
			\"metrics\": [
				{
					\"map-name\": \"DNS_PACKETS_COUNTER\",
					\"name\": \"Total DNS packets\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS packets seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				},
				{
					\"map-name\": \"DNS_QTYPE_ANY_PACKETS_COUNTER\",
					\"name\": \"Total DNS queries of type ANY\",
					\"open-metrics-metadata\": {
						\"help\": \"This metrics represents the number of DNS queries of type ANY  seen by the probe.\",
						\"labels\": [
							{
								\"name\": \"IPPROTO\",
								\"value\": \"UDP\"
							},
							{
								\"name\": \"L4\",
								\"value\": \"DNS\"
							}
						],
						\"type\": \"counter\"
					}
				}
			]
		},
		\"description\": \"Counter of total DNS packets and ANY query\",
		\"id\": \"dns_warn\",
		\"parameters\": [
			{
				\"description\": \"Local interface to monitor\",
				\"example\": \"eno1\",
				\"id\": \"interface\",
				\"list\": false,
				\"type\": \"string\"
			}
		]
	}
]
'"
}
