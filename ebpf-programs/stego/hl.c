#include <linux/if_vlan.h>
#include <linux/if_ether.h>		// struct ethhdr
#include <linux/pkt_cls.h>
#include <linux/time.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/icmp.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/ip.h>

#define BINBASE 8 
#define NBINS 0x1<<BINBASE

/* TODO: Improve performance by using multiple per-cpu hash maps.
 */
BPF_ARRAY(hl_stats, __u32, NBINS);

/* Header cursor to keep track of current parsing position */
struct hdr_cursor {
        void *pos;
};

static __always_inline int proto_is_vlan(__u16 h_proto)
{
        return !!(h_proto == bpf_htons(ETH_P_8021Q) ||
                  h_proto == bpf_htons(ETH_P_8021AD));
}

/*
	   * Struct icmphdr_common represents the common part of the icmphdr and icmp6hdr
	   *  * structures.
	   *   */
struct icmphdr_common {
        __u8	type;
	__u8    code;
	__sum16 cksum;
};


/* Parse the Ethernet header and return protocol.
 * Ignore VLANs.
 *
 * Protocol is returned in network byte order.
 */
static __always_inline int parse_ethhdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct ethhdr **ethhdr)
{
       struct ethhdr *eth = nh->pos;
        int hdrsize = sizeof(*eth);
        struct vlan_hdr *vlh;
        __u16 h_proto;
        int i;

        /* Byte-count bounds check; check if current pointer + size of header
         * is after data_end.
         */
        if (nh->pos + hdrsize > data_end)
                return -1;

        nh->pos += hdrsize;
        *ethhdr = eth;
        vlh = nh->pos;
        h_proto = eth->h_proto;

        /* Use loop unrolling to avoid the verifier restriction on loops;
         * support up to VLAN_MAX_DEPTH layers of VLAN encapsulation.
         */
        #pragma unroll
        for (i = 0; i < VLAN_MAX_DEPTH; i++) {
                if (!proto_is_vlan(h_proto))
                        break;

                if ( (void *)(vlh + 1) > data_end)
                        break;

                h_proto = vlh->h_vlan_encapsulated_proto;
                vlh++;
        }

        nh->pos = vlh;
        return h_proto; /* network-byte-order */


}

static __always_inline int parse_ip6hdr(struct hdr_cursor *nh,
					void *data_end,
					struct ipv6hdr **ip6hdr)
{
	struct ipv6hdr *ip6h = nh->pos;

 	if ( (void *)(ip6h + 1) > data_end)
		return -1;

	nh->pos = ip6h + 1;
	*ip6hdr = ip6h;

	return ip6h->nexthdr;
}

static __always_inline int handle_rx(struct CTXTYPE *ctx, struct pkt_metadata *md) 
{
	/* Preliminary step: cast to void*.
	 * (Not clear why data/data_end are stored as long)
	 */
	void *data_end = (void *)(long)ctx->data_end;
	void *data     = (void *)(long)ctx->data;
	__u32 ipv6field = 0;
	__u32 len = 0;
	__u32 init_value = 1;
	int eth_proto, ip_proto = 0;
	struct hdr_cursor nh;
	struct ethhdr *eth;
	struct ipv6hdr* iph6;

	/* Parse Ethernet header and verify protocol number. */
	nh.pos = data;
	len = data_end - data;
	eth = (struct ethhdr *)data;
	eth_proto = parse_ethhdr(&nh, data_end, &eth);
	if ( eth_proto < 0 ) {
		return TC_ACT_OK; /* TODO: XDP_ABORT? */
	}
	if ( eth_proto != bpf_htons(ETH_P_IPV6) )
	{
		return TC_ACT_OK;
	}

	/* Parse IP header and verify protocol number. */
	if( (ip_proto = parse_ip6hdr(&nh, data_end, &iph6)) < 0 ) {
		return TC_ACT_OK;
	}	

	/* Check flow label
	 */
	if( (void*) iph6 + sizeof(struct ipv6hdr) < data_end) {
		 ipv6field = iph6->hop_limit;
	}

	/* Collect the required statistics. */

	__u32 key = ipv6field >> (8-BINBASE);
	__u32 *counter = 
		hl_stats.lookup(&key);

	if(!counter)
		hl_stats.update(&key, &init_value);
	else
		__sync_fetch_and_add(counter, 1);

	  

	return TC_ACT_OK;
}

