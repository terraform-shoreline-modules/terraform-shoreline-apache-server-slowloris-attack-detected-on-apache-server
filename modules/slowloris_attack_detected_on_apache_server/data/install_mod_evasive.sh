

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