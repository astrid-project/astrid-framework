# Monitoring tools for amplification attacks

## Amplification attacks

Volumetric (Distributed) Denial of Service attacks remain one of the major threats for any organization, capable of saturating most Internet access links through the usage of botnets and amplification techniques. There are many Internet protocols where small queries may trigger larger responses. Those exploited for DDoS amplifi- cation attacks use the UDP transport protocol, because this makes easier to spoof the IP address of the victim. Well-known examples include the Network Time Protocol (NTP) and the Domain Name System (DNS); however, the problem extends to other servers and protocols as well (Memcache, SIP, LDAP, RIP, SNMP). 

While the detection of a volumetric DDoS is trivial, effective mitigation is almost impossible for the victim, because these attacks saturate its Internet link. Today, the most effective defensive mechanism consists in diverting all traffic from the Internet to an external scrubbing center in case of attack. This limits the impact to the time needed to detect the saturation and divert packets; typically a few dozens of minutes are required at most. However, such approach needs to model the capacity of the scrubbing center some times more than the biggest expected attack (e.g., four to ten), hence resulting in large resource overprovisioning, which should be continuously increased as the attackers can increase the volume of their attacks.<sup>[1](#myfootnote1)</sup>

Mitigation of an amplification attack is challenging, because packets come from legitimate sources and carry valid data. Stopping it at its root would be possible in theory, by applying safe configurations to servers, blocking unnecessary ports, activating anti-spoofing filters; however, this is difficult to achieve in practice, because it depends on each organization that connects servers and devices to the Internet. With the advent of 5G technology, the number of (vulnerable) connected devices will increase, giving attackers more opportunities to create large botnets and to find vulnerable servers for amplifying their attacks. However, the same 5G architecture offers unprecedented opportunities to integrate monitoring and inspection functions at the edge, which can be used to detect and mitigate DoS attacks before they are amplified [1]. 

This folder collects a set of tools developed by the ASTRID project to analyze amplification attacks at their root, i.e., before they hit Internet servers and are amplified. This is the most useful scenario for mitigating such kind of attacks, because it allows to detect malicious flows before they saturate servers and links. Please note that the usage of such programs is only limited to detection, whereas mitigation should be implemented by other tools in the ASTRID framework.

## Content

The programs collected in this folder are designed to feed the Analytic Toolkit (ATk) [1]. For each supported protocol, two programs are provided. One program only collects basic volumetric measurements (number of packets seen), the other one also performs deep packet inspection to look for specific signatures that are expected to trigger an amplification effect (and also reports the number of such packets). Details about ATk operation and the relevant signatures are described in a related paper [1]. 

Two files are provided for each program. The original source code (.c) is the eBPF program alone. The JSON file (.json) is the input to the <A href="https://github.com/polycube-network/polycube/blob/master/Documentation/services/pcn-dynmon/dynmon.rst">dynmon</A> cube; it embeds the C code and additional metadata for the common control plane.

## Usage

Programs can be directly injected in <A href="https://github.com/polycube-network/polycube/blob/master/Documentation/services/pcn-dynmon/dynmon.rst">dynmon</A>  through the Polycube REST API. However, in the ASTRID framework, this operation should be performed by the <A href="https://github.com/astrid-project/cb-manager.git">CB Manager</A>. The implementation of ASTRID use cases includes these programs in the ebpfprogram catalog. 

## References

[1] M. Repetto, A. Carrega, G. Lamanna, J. Yusupov, O. Toscano, G. Bruno, M. Nuovo, M. Cappelli. Leveraging the 5G architecture to mitigate amplification attacks. 3rd International Workshop on Cyber-Security Threats, Trust and Privacy Management in Software-defined and Virtualized Infrastructures (SecSoft), July 2nd, 2021, Tokyo, Japan. 

## Notes

<a name="myfootnote1">1</a>: Less than two years after the unprecedented 1.35 Tbps DDoS attack experienced by GitHub, AWS reported to have defeated against a 2.3 Tbps attack in February 2020, which almost doubled the previous volume. During the same period, Imperva reported one of its client to have experienced a 500 million packets-per-second attack, which represents the most intensive DDoS attack against network infrastructure in the history of the Internet.


