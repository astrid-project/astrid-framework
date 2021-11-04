  #!/bin/bash

function agent_catalog()
{
  echo -n "'
    [
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/metricbeat/init.sh\"
    				},
    				\"id\": \"init\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/metricbeat/start.sh\",
    					\"daemon\": true
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/metricbeat/stop.sh\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/metricbeat/health.sh\"
    				},
    				\"id\": \"health\"
    			}
    		],
    		\"id\": \"metricbeat\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"enabled\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/metricbeat/modules.d/system.yml\"
    				},
    				\"description\": \"Enable/disable the collection of the system data\",
    				\"example\": true,
    				\"id\": \"system-enabled\",
    				\"type\": \"boolean\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"period\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/metricbeat/modules.d/system.yml\"
    				},
    				\"description\": \"Period to collect the system data\",
    				\"example\": \"10s\",
    				\"id\": \"system-period\",
    				\"type\": \"time-duration\"
    			}
    		],
    		\"partner\": \"cnit\",
    		\"resources\": [
    			{
    				\"config\": {
    					\"path\": \"/opt/astrid/metricbeat/modules.d/system.yml\"
    				},
    				\"description\": \"Configuration file to collect log system data\",
    				\"example\": \"https://github.com/astrid-project/astrid-framework/blob/75ff3182b290b44329dc146140af5e4e083484ed/agents/metricbeat/settings/7.8.0/modules.d/system.yml\",
    				\"id\": \"config-file\"
    			}
    		]
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/filebeat/init.sh\"
    				},
    				\"id\": \"init\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/filebeat/start.sh\",
    					\"daemon\": true
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/filebeat/stop.sh\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/filebeat/health.sh\"
    				},
    				\"id\": \"health\"
    			}
    		],
    		\"id\": \"filebeat\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"enabled\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/filebeat/config/log.yml\"
    				},
    				\"description\": \"Enable/disable the collection of log data\",
    				\"example\": true,
    				\"id\": \"log-enabled\",
    				\"type\": \"boolean\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"backoff\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/filebeat/config/log.yml\"
    				},
    				\"description\": \"Period to collect the log data\",
    				\"example\": \"10s\",
    				\"id\": \"log-period\",
    				\"type\": \"time-duration\"
    			}
    		],
    		\"partner\": \"cnit\",
    		\"resources\": [
    			{
    				\"config\": {
    					\"path\": \"/opt/astrid/filebeat/config/log.yml\"
    				},
    				\"description\": \"Configuration file to collect log data\",
    				\"example\": \"https://github.com/astrid-project/astrid-framework/blob/89cee77fb4b3c3af2bcf0b52bb40c26937a49202/agents/filebeat/settings/7.8.0/config/log.yml\",
    				\"id\": \"config-file\"
    			}
    		]
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"sudo systemctl start nprobe\"
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"sudo systemctl stop nprobe\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"sudo systemctl restart nprobe\"
    				},
    				\"id\": \"restart\",
    				\"status\": \"started\"
    			}
    		],
    		\"id\": \"nprobe\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"-i\"
    					],
    					\"schema\": \"properties\",
    					\"source\": \"/etc/nprobe/nprobe.conf\"
    				},
    				\"description\": \"Set the network interface to probe\",
    				\"example\": \"eth0\",
    				\"id\": \"network-interface\",
    				\"type\": \"string\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"-capture-direction\"
    					],
    					\"schema\": \"properties\",
    					\"source\": \"/etc/nprobe/nprobe.conf\"
    				},
    				\"description\": \"Specify packet capture direction: 0=RX+TX (default), 1=RX only, 2=TX only\",
    				\"example\": 1,
    				\"id\": \"capture-direction\",
    				\"type\": \"integer\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"-T\"
    					],
    					\"schema\": \"properties\",
    					\"source\": \"/etc/nprobe/nprobe.conf\"
    				},
    				\"description\": \"Specifies the NFv9 template\",
    				\"example\": \"%IPV4_SRC_ADDR %IPV4_DST_ADDR %IN_PKTS %IN_BYTES %OUT_PKTS %OUT_BYTES %FLOW_ACTIVE_TIMEOUT %FLOW_INACTIVE_TIMEOUT %L4_SRC_PORT %L4_DST_PORT %TCP_FLAGS %CLIENT_TCP_FLAGS %SERVER_TCP_FLAGS %PROTOCOL %SRC_TOS %LONGEST_FLOW_PKT %SHORTEST_FLOW_PKT %TCP_WIN_MSS_IN %TCP_WIN_MSS_OUT %SRC_TO_DST_SECOND_BYTES %DST_TO_SRC_SECOND_BYTES %LAST_SWITCHED %FIRST_SWITCHED %MIN_IP_PKT_LEN %MAX_IP_PKT_LEN %DIRECTION %FLOW_ID %FLOW_START_SEC %FLOW_END_SEC %DURATION_IN %DURATION_OUT %PAYLOAD_HASH\",
    				\"id\": \"flow-template\",
    				\"type\": \"string\"
    			}
    		],
    		\"partner\": \"cnit\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/logstash/init.sh\"
    				},
    				\"id\": \"init\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/logstash/start.sh\",
    					\"daemon\": true
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/logstash/stop.sh\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/logstash/health.sh\"
    				},
    				\"id\": \"health\"
    			}
    		],
    		\"id\": \"logstash\",
    		\"partner\": \"cnit\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"termux-battery-status\"
    				},
    				\"id\": \"battery-status\"
    			}
    		],
    		\"id\": \"termux-api\",
    		\"partner\": \"cnit\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"curl localhost:5003/interceptionstart -d '{\\"userID\\":\\"{userID}\\", \\"serviceProviderID\\":\\"{serviceProviderID}\\",  \\"serviceID\\": \\"{serviceID}\\"}'\"
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"curl localhost:5003/interceptionstop -d '{\\"userID\\":\\"{userID}\\", \\"serviceProviderID\\":\\"{serviceProviderID}\\",  \\"serviceID\\": \\"{serviceID}\\"}'\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			}
    		],
    		\"id\": \"interception-core-agent\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/cubebeat/init.sh\"
    				},
    				\"id\": \"init\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/cubebeat/start.sh\",
    					\"daemon\": true
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/cubebeat/stop.sh\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"/opt/astrid/commands/cubebeat/health.sh\"
    				},
    				\"id\": \"health\"
    			}
    		],
    		\"id\": \"cubebeat\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"enabled\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/cubebeat/config.d/synflood.yml\"
    				},
    				\"description\": \"Enable/disable the collection of synflood data\",
    				\"example\": true,
    				\"id\": \"synflood-enabled\",
    				\"type\": \"boolean\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"0\",
    						\"period\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/cubebeat/config.d/synflood.yml\"
    				},
    				\"description\": \"Period to collect the synflood data\",
    				\"example\": \"10s\",
    				\"id\": \"synflood-period\",
    				\"type\": \"time-duration\"
    			}
    		],
    		\"partner\": \"cnit\",
    		\"resources\": [
    			{
    				\"config\": {
    					\"path\": \"/opt/astrid/cubebeat/config.d/synflood.yml\"
    				},
    				\"description\": \"Configuration file to collect synflood data\",
    				\"example\": \"https://github.com/astrid-project/astrid-framework/blob/75ff3182b290b44329dc146140af5e4e083484ed/agents/cubebeat/settings/master/config.d/synflood.yml\",
    				\"id\": \"config-file\"
    			}
    		]
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"sed -i 's/topic_id => \\".*\\"/topic_id => \\"{value}\\"/' /usr/share/logstash/pipeline/polycube_*.conf\"
    				},
    				\"id\": \"kafka-topic\"
    			}
    		],
    		\"id\": \"agent-probe\",
    		\"partner\": \"cnit\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"{run}\"
    				},
    				\"id\": \"test\"
    			}
    		],
    		\"description\": \"Agent entry for development purpose.\",
    		\"id\": \"dev\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"test\",
    						\"2\",
    						\"enabled\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/home/alexcarrega/test/test.yml\"
    				},
    				\"description\": \"Test field\",
    				\"example\": true,
    				\"id\": \"test-yaml\",
    				\"type\": \"boolean\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"test\",
    						\"1\",
    						\"format\"
    					],
    					\"schema\": \"json\",
    					\"source\": \"/home/alexcarrega/test/test.json\"
    				},
    				\"description\": \"Test field\",
    				\"example\": \"plain\",
    				\"id\": \"test-json\",
    				\"type\": \"string\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"test\",
    						\"counter\"
    					],
    					\"schema\": \"xml\",
    					\"source\": \"/home/alexcarrega/test/test.xml\"
    				},
    				\"description\": \"Test field\",
    				\"example\": 35,
    				\"id\": \"test-xml\",
    				\"type\": \"integer\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"test\",
    						\"enhanced\"
    					],
    					\"schema\": \"properties\",
    					\"source\": \"/home/alexcarrega/test/test.ini\"
    				},
    				\"description\": \"Test field\",
    				\"example\": \"ssl\",
    				\"id\": \"test-properties\",
    				\"type\": \"string\"
    			}
    		],
    		\"partner\": \"cnit\",
    		\"resources\": [
    			{
    				\"config\": {
    					\"path\": \"resource.yml\"
    				},
    				\"description\": \"Configuration file\",
    				\"example\": \"...\",
    				\"id\": \"test-resource\"
    			}
    		],
    		\"stage\": \"development\"
    	},
    	{
    		\"id\": \"dynmon\",
    		\"partner\": \"cnit\"
    	},
    	{
    		\"actions\": [
    			{
    				\"config\": {
    					\"cmd\": \"curl -XPOST localhost:9999/service-start\"
    				},
    				\"id\": \"start\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"curl -XPOST localhost:9999/service-stop\"
    				},
    				\"id\": \"stop\",
    				\"status\": \"stopped\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"curl -XPOST localhost:9999/service-restart\"
    				},
    				\"id\": \"restart\",
    				\"status\": \"started\"
    			},
    			{
    				\"config\": {
    					\"cmd\": \"curl localhost:9999/service-status\"
    				},
    				\"id\": \"status\"
    			}
    		],
    		\"id\": \"packetbeat\",
    		\"parameters\": [
    			{
    				\"config\": {
    					\"path\": [
    						\"packetbeat\",
    						\"interfaces\",
    						\"device\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/packetbeat/packetbeat.yml\"
    				},
    				\"description\": \"The network device to capture traffic from (you can specify any for the device)\",
    				\"example\": \"eth0\",
    				\"id\": \"interface\",
    				\"type\": \"string\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"packetbeat\",
    						\"protocols\",
    						\"icmp\",
    						\"enabled\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/packetbeat/packetbeat.yml\"
    				},
    				\"description\": \"Enable/disable the stats of ICMP packets\",
    				\"example\": true,
    				\"id\": \"icmp-enabled\",
    				\"type\": \"boolean\"
    			},
    			{
    				\"config\": {
    					\"path\": [
    						\"packetbeat\",
    						\"output\",
    						\"topic\"
    					],
    					\"schema\": \"yaml\",
    					\"source\": \"/opt/astrid/packetbeat/packetbeat.yml\"
    				},
    				\"description\": \"Kafka output topic.\",
    				\"example\": \"\",
    				\"id\": \"kafka-topic\",
    				\"type\": \"string\"
    			}
    		],
    		\"partner\": \"cnit\"
    	}
    ]
'"
}
