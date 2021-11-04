#!/bin/bash

function network_link_types()
{
  echo -n "'
[
	{
		\"description\": \"Connection through Multi-Point\",
		\"id\": \"multi-pnt\",
		\"name\": \"Multi-Point\"
	},
	{
		\"description\": \"Connection through Network Slice\",
		\"id\": \"network-slice\",
		\"name\": \"Network Slice\"
	},
	{
		\"description\": \"Connection through Point to Point\",
		\"id\": \"pnt2pnt\",
		\"name\": \"Point to Point\"
	},
	{
		\"description\": \"Connection through WiFi network\",
		\"id\": \"wifi\",
		\"name\": \"WiFi\"
	},
	{
		\"description\": \"Hosted Service\",
		\"id\": \"hosted\",
		\"name\": \"Hosted\"
	}
]
'"
}
