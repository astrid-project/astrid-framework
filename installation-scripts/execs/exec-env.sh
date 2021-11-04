#!/bin/bash

function exec_env_types ()
{
  echo -n "'
[
	{
		\"id\": \"bare-metal\",
		\"name\": \"Bare Metal\"
	},
	{
		\"id\": \"container-docker\",
		\"name\": \"Container Docker\"
	},
	{
		\"id\": \"container-k8s\",
		\"name\": \"Container Kubernetes\"
	},
	{
		\"id\": \"vm\",
		\"name\": \"Virtual Machine\"
	},
	{
		\"id\": \"cloud\",
		\"name\": \"Cloud\"
	},
	{
		\"id\": \"application\",
		\"name\": \"Application\"
	},
	{
		\"id\": \"gateway\",
		\"name\": \"Gateway\"
	},
	{
		\"id\": \"mobile\",
		\"name\": \"Mobile\"
	},
	{
		\"id\": \"raspberry\",
		\"name\": \"Raspberry\"
	}
]
  '"
}

function exec_env ()
{
  echo -n "'
  [
    { 
      \"lcp\":
      { 
        \"port\":5000, 
        \"https\":false 
      }, 
    \"id\": \"${EE_NAME}\", 
    \"description\": \"exec-env\", 
    \"type_id\":\"container-docker\", 
    \"hostname\":\"${EE_NAME}\", 
    \"enabled\":\"Yes\" 
    }
  ]
  '"
}
