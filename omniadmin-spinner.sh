#!/bin/bash
# OmniAdmin quick installation for Spinner v1.0
# by Dia Seung
#
# -----------------------------------
# Usage: 
# 1). Update the 'jar_location' variable below. 
# 2). Place script in the 'liferay-docker/spinner/env-{env}/' dir. 
# 3). Run ./omniadmin-spinner.sh
# (Tip: If you run into permission denied, don't forget to run 'chmod +x omniadmin-spinner.sh')
# -----------------------------------
# Link to OmniAdmin: https://github.com/exela/secret-sauce/releases/tag/v0.1.0-barebones



# VARIABLES
jar_location='/home/dia/Downloads/'
omniadmin_jar_name='omni.admin.autologin-barebones-7.4.1.jar'
destination='liferay_mount/files/deploy/'


# Bash Script --------------------------------------
# Place the Omniadmin Jar
echo "Placing the OmniAdmin jar..."
cp $jar_location$omniadmin_jar_name $destination
if [[ -e "liferay_mount/files/deploy/$omniadmin_jar_name" ]]; then
    echo -e "[SUCCESS] $omniadmin_jar_name placed in $destination"
else
    echo -e "[ERROR] Please manually place OmniAdmin jar"
fi

# Update docker-compose.yml file with the encryption property to make OmniAdmin work
echo "Adding the encryption property to docker-compose.yml file"
sed -i -e "s/extra_hosts:/    - LIFERAY_PASSWORDS_PERIOD_ENCRYPTION_PERIOD_ALGORITHM=NONE\n        extra_hosts:/"  docker-compose.yml

# Script Completion Notice
echo "[SUCCESS] OmniAdmin install complete!"