# BPF tools for detecting network covert channels

This folder contains a set of bpf programs for inspecting network protocol headers, which are compatible with the <A href="https://github.com/polycube-network/polycube/blob/master/Documentation/services/pcn-dynmon/dynmon.rst">Polycube Dynmon</A> service. 
They create simple statistics about the usage of vulnerable fields that can be used for implementing network covert channels. Currently supported fields: 
<ul>
<li>IPv6: flow label, traffic class, hop limit, 
<li>IPv4: type of service/differentiated service code pointer, identification, time-to-live, fragment offset, internet header length, 
<li>TCP: ack, reserved bits, timestamp,
<li>UDP: checksum.
</ul>
The current folder maintains the source code, as well as the corresponding json files that can be injected to Dynmon.

## Theory of operation

These tools inspect network packets and create an histogram of values used in the corresponding header field. The histogram is made of a given number of bins, and all possible field values are equally divided into the available bins, in a consecutive way. Practically speaking, the field values grouped into the same bin share the same prefix, which is also used as the <i>key</i> in the output (the number of shared bits depends on the number of bins). <br>
The number of bins and the sampling interval are hardcode in each program, but they can be easily changed by setting the BINBASE macro. There are only a few practical limitations. First, the total number of bins must be lower than the number of possible values for the specific field, otherwise memory will be wasted for unused bins. Second, the larger is the number of bins, the higher will be internal memory usage; of course, also the delay to retrieve the whole histogram and the overhead on the network will increase. Depending on system configuration, it might be possible to be unable to use more than 2^16-2^18 bins.

## Use cases

These tools can be used to check how the kernel generates these values for different flows/packets, and to detect covert channels hidden in the network protocol headers. 
They were designed to feed some detection algorithms elaborated by the <A href="https://simargl.eu/">SIMARGL project</A>. Validation and performance evaluation is described in the following papers:

[1] A. Carrega, L. Caviglione, M. Repetto, M. Zuppelli. Programmable Data Gathering for Detecting Stegomalware. 2nd International Workshop on Cyber-Security Threats, Trust and Privacy Management in Software-defined and Virtualized Infrastructures (SecSoft), co-located with NetSoft'2020, Ghent, Belgium (Virtual Conference), July 3rd, 2020. <A href="https://doi.org/10.1109/NetSoft48620.2020.9165537">DOI: 10.1109/NetSoft48620.2020.9165537</A><br>
[2] L. Caviglione, W. Mazurczyk, M. Repetto, A. Schaffhauser, M. Zuppelli. Kernel-level tracing for detecting stegomalware and covert channels in Linux environments. Computer Networks, pre-print. <A href="https://doi.org/10.1016/j.comnet.2021.108010">DOI: 10.1016/j.comnet.2021.108010</A>
