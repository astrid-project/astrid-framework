#include <uapi/linux/ip.h>
#include <uapi/linux/udp.h>

#define IP_PROTO_UDP 17
#define NTP_PORT 123
#define NTP_MODE_PRIVATE 7

#define MODE(li_vn_mode) (uint8_t) ((li_vn_mode & 0x07) >> 0)

struct eth_hdr {
    __be64 dst : 48;
    __be64 src : 48;
    __be16 proto;
} __attribute__((packed));

struct ntp_packet {
    uint8_t li_vn_mode;
    uint8_t stratum;
    uint8_t poll;
    uint8_t precision;
    uint32_t rootDelay;
    uint32_t rootDispersion;
    uint32_t refId;
    uint32_t refTm_s;
    uint32_t refTm_f;
    uint32_t origTm_s;
    uint32_t origTm_f;
    uint32_t rxTm_s;
    uint32_t rxTm_f;
    uint32_t txTm_s;
    uint32_t txTm_f;
} __attribute__((packed));

BPF_ARRAY(NTP_PACKETS_COUNTER, uint64_t, 1);
BPF_ARRAY(NTP_MODE_PRIVATE_PACKETS_COUNTER, uint64_t, 1);

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

    if (udp->source == bpf_htons(NTP_PORT) || udp->dest == bpf_htons(NTP_PORT)) {
        pcn_log(ctx, LOG_TRACE, \"%I:%P\\t-> %I:%P\", ip->saddr,udp->source,ip->daddr,udp->dest);
        unsigned int key = 0;
        uint64_t * ntp_pckts_counter = NTP_PACKETS_COUNTER.lookup(&key);
        if (!ntp_pckts_counter)
            pcn_log(ctx, LOG_ERR, \"[NTP_AMP_WARNING] Unable to find NTP_PACKETS_COUNTER map\");
        else
            *ntp_pckts_counter+=1;

        /*Parsing NTP*/
        struct ntp_packet *ntp = data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr);
        if (data + sizeof(*ethernet) + ip_header_len + sizeof(struct udphdr) + sizeof(*ntp) > data_end)
            return RX_OK;

        uint8_t mode = MODE(ntp->li_vn_mode);
        pcn_log(ctx, LOG_TRACE, \"NTP mode: %hhu\", mode);
        if (mode == NTP_MODE_PRIVATE) {
            pcn_log(ctx, LOG_TRACE, \"RECEIVED NTP MODE 7\");
            key = 0;
            uint64_t * ntp_mode_private_counter = NTP_MODE_PRIVATE_PACKETS_COUNTER.lookup(&key);
            if (!ntp_mode_private_counter)
                pcn_log(ctx, LOG_ERR, \"[NTP_AMP_WARNING] Unable to find NTP_MODE_PRIVATE_PACKETS_COUNTER map\");
            else
                *ntp_mode_private_counter+=1;
        }
    }

    return RX_OK;
}
