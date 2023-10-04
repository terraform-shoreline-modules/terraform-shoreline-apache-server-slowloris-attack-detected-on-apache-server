
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Slowloris Attack Detected on Apache server.
---

The Slowloris Attack is a type of Denial of Service (DoS) attack that exploits a vulnerability in the Apache web server. It works by sending HTTP requests to the server and keeping those connections open for as long as possible, thereby using up all the available resources of the server and rendering it unresponsive to legitimate requests. As a result, the server becomes slow or unresponsive, causing downtime for the affected website or service. This type of attack can be detected and mitigated by implementing specific security measures and tools.

### Parameters
```shell
export APACHE_PORT="PLACEHOLDER"

export INTERFACE="PLACEHOLDER"

export IP_ADDRESS="PLACEHOLDER"

export PATH_TO_APACHE_CONF_FILE="PLACEHOLDER"

export MAX_CONNECTIONS_PER_IP="PLACEHOLDER"

```

## Debug

### Check if Apache is running
```shell
systemctl status apache2
```

### Check Apache logs for any suspicious activity
```shell
tail -f /var/log/apache2/access.log
```

### Check active connections to the server
```shell
netstat -anp | grep ${APACHE_PORT}
```

### Check the number of connections per IP address
```shell
netstat -anp | grep ${APACHE_PORT} | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
```

### Check Apache server status for any suspicious activity
```shell
curl -I http://localhost/server-status
```

### Check Apache server configuration for any vulnerabilities
```shell
apache2ctl -t -D DUMP_MODULES
```

### Check for any active Slowloris attacks
```shell
tcpdump -i ${INTERFACE} 'tcp[20:2] == 0x4745'
```

### Block IPs with suspicious activity
```shell
iptables -A INPUT -s ${IP_ADDRESS} -j DROP
```

## Repair

### Configure the Apache server to limit the number of connections from a single IP address.
```shell
bash

#!/bin/bash



# Apache configuration file path

APACHE_CONF_PATH="${PATH_TO_APACHE_CONF_FILE}"



# Maximum number of connections per IP address

MAX_CONNECTIONS_PER_IP="${MAX_CONNECTIONS_PER_IP}"



# Get the current value of the MaxClients directive

MAX_CLIENTS=$(grep -oP 'MaxClients \K[0-9]+' $APACHE_CONF_PATH)



# Calculate the new value of the MaxClients directive

NEW_MAX_CLIENTS=$(expr $MAX_CLIENTS \* $MAX_CONNECTIONS_PER_IP)



# Update the MaxClients directive in the Apache configuration file

sed -i "s/MaxClients $MAX_CLIENTS/MaxClients $NEW_MAX_CLIENTS/g" $APACHE_CONF_PATH



# Restart the Apache service

systemctl restart apache2


```

### Install a rate-limiting module on the server to prevent excessive requests from any single IP address.
```shell


#!/bin/bash



# Install the mod_evasive Apache module

sudo apt-get update

sudo apt-get install libapache2-mod-evasive



# Configure mod_evasive to limit requests from a single IP address

sudo tee /etc/apache2/mods-available/mod-evasive.conf > /dev/null ${<EOF

<IfModule mod_evasive20.c}

    DOSHashTableSize 3097

    DOSPageCount 10

    DOSSiteCount 50

    DOSPageInterval 1

    DOSSiteInterval 1

    DOSBlockingPeriod 10

    DOSEmailNotify admin@domain.com

    DOSSystemCommand "sudo /usr/bin/logger -t mod_evasive -p local6.info"

    DOSLogDir "/var/log/apache2/"

    DOSWhitelist 127.0.0.1

${_IFMODULE}

EOF



# Enable the mod_evasive module and restart Apache

sudo a2enmod evasive

sudo systemctl restart apache2.service


```