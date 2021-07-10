# A container for running standalone Zeek network analyzer.
#
# Copyright (c) 2021, The ASTRID Consortium
# All rights reserved
#

from debian:testing

# Download latest binaries for Debian
RUN apt-get update && \
	apt-get -y install wget gnupg && \
	echo 'deb http://download.opensuse.org/repositories/security:/zeek/Debian_Testing/ /' | \
	tee -a /etc/apt/sources.list.d/security:zeek.list && \
	wget -nv https://download.opensuse.org/repositories/security:zeek/Debian_Testing/Release.key -O Release.key && \
	apt-key add - < Release.key && \
	apt-get update && \
	apt-get -y upgrade  && \
	apt-get -y install zeek && \
	rm -rf /var/lib/apt/lists/* && \
	rm -f Release.key  && \
	ln -s /opt/zeek/bin/zeek /usr/local/bin/&& \
	ln -s /opt/zeek/bin/zeek-cut /usr/local/bin/ && \
	ln -s /opt/zeek/bin/zeekctl /usr/local/bin

# Install the necessary script to count DNS queries
COPY count-dns-qtype.zeek /opt/zeek/share/zeek/policy/protocols/dns/
RUN echo "@load ./count-dns-qtype.zeek" >> /opt/zeek/share/zeek/policy/protocols/dns/__load__.zeek && \
	echo "@load protocols/dns" >> /opt/zeek/share/zeek/site/local.zeek && \
	 /usr/local/bin/zeekctl stop && \
	/usr/local/bin/zeekctl deploy && \
	sed -ie "s/\/.*sendmail//" /opt/zeek/lib/zeek/python/zeekctl/ZeekControl/options.py && \
	 /usr/local/bin/zeekctl stop

WORKDIR /root/

CMD ["/usr/local/bin/zeek", "-C", "-ieth0", "protocols/dns/count-dns-qtype"]
