##! This script counts the total number of dns queries and 
##! the number of ANY queries.

@load base/protocols/dns/main

module dnsquerytypecount;

export {
    # Append the value LOG to the Log::ID enumerable.
    redef enum Log::ID += { LOG };

    # Ignore checksum errors due to offloading
    redef ignore_checksums = T;

    # Define a new type called Factor::Info.
    type Counters: record {
        tot:     count &log;
        tot_any: count &log;
    	};
}

global tot_query: count;
global tot_any_query: count;

event zeek_init()
	{
		tot_query=0;
		tot_any_query=0;

		# Create the logging stream.
    		Log::create_stream(LOG, [$columns=Counters, $path="dns-counters"]);
	}

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count, original_query: string) &priority=5
	{
		tot_query += 1;
		if( qtype==255 ) {
			tot_any_query += 1;
			}

		Log::write(dnsquerytypecount::LOG, [$tot=tot_query, $tot_any=tot_any_query]);
	}
