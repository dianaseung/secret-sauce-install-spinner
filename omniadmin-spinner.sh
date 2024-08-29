#!/bin/bash
# OmniAdmin quick installation for Spinner v1.1
# by Dia Seung
#
# -----------------------------------
# Usage: 
# 1). Clone repo to drive: `git clone https://github.com/dianaseung/secret-sauce-install-spinner.git``
# 2). Run `./omniadmin-spinner.sh init` to download jar, and setup jar location. 
# 3). Add alias to bashrc: alias omni='cp "path/to/omniadmin-spinner.sh" . && ./omniadmin-spinner.sh'
# 4). Setup a Spinner env (i.e. `./build.sh <lxc-environment>`) and then run `omni`
# (Tip: If you run into permission denied, don't forget to run 'chmod +x omniadmin-spinner.sh')
# -----------------------------------
# Link to OmniAdmin: https://github.com/exela/secret-sauce/releases/tag/v0.1.0-barebones


# VARIABLES
omniadmin_jar_location=$LRDIR

# Determine latest release URL & jar name
curl -s https://api.github.com/repos/exela/secret-sauce/releases/latest > latest_release.json > latest_release.json
latest_release=$(jq -r '.assets[0].browser_download_url' latest_release.json)
latest_jar_name=$(basename $latest_release)
echo -e "Latest Release: $latest_release"
echo -e "Latest Jar Name: $latest_jar_name"

# Fallback 7.4.1 URL & jar name
omniadmin_741_source='https://github.com/exela/secret-sauce/releases/download/v0.1.0-barebones/omni.admin.autologin-barebones-7.4.1.jar'
omniadmin_741_jar_name='omni.admin.autologin-barebones-7.4.1.jar'
destination='liferay_mount/files/deploy/'

add_to_bashrc() {
  local variable_name="$1"
  local value="$2"
  echo "export $variable_name=\"$value\"" >> ~/.bashrc
}

init () {
    # Check env
    echo -e "\n---\n[INIT] Starting setup for Omniadmin..."
    # [CHECK] GLOBAL VARIABLES (set in bashrc)
    echo -e "[CHECK] Check if LRDIR exists; if so, download latest Omniadmin JAR to LRDIR."
    if [ -z ${LRDIR+x} ]; then
        # If no LRDIR, PROJECTDIR, prompt desired path
        # if not selected, by default, create directories in ~/
        defaultLRDIR="$HOME/Liferay/DXP"
        echo -e "[Default] If not specified, LRDIR will be set to $defaultLRDIR"
        read -p 'Input LRDIR path: ' LRDIRinit
        LRDIRinit="${LRDIRinit:-$defaultLRDIR}"
        echo -e "\n# quickLR env variables (github.com/dianaseung/quickLR)" >> ~/.bashrc
        add_to_bashrc LRDIR "$LRDIRinit"
        log_echo "$LINENO LRDIR set to: $LRDIRinit"

        source ~/.bashrc

        # mkdir Liferay/DXP/
        if [[ ! -d "$LRDIRinit" ]]; then
            mkdir -p "$LRDIRinit"
        else
            echo -e "LRDIR already exists"
        fi
    else
        echo -e "[CHECK] LRDIR exists: ${LRDIR}"
    fi

    if [[ ! -f "$LRDIR/$latest_jar_name" ]]; then
        sleep 1
        if [[ -f "latest_release.json" ]]; then
            if [ -z "$latest_release" ]; then
                echo -e "You may need to install jq. Run 'sudo apt install jq'"
            else
                wget -np -nd -nH -q --show-progress $latest_release -P $LRDIR
                if [[ -f "$LRDIR/$latest_jar_name" ]]; then
                    echo -e "[SUCCESS] Omniadmin JAR downloaded!"
                    rm latest_release.json
                else
                    echo -e "[ERROR] Something went wrong downloading the latest release. Downloading 7.4.1..."
                    wget -np -nd -nH -q --show-progress $omniadmin_741_source -P $LRDIR
                fi
            fi
        else
            echo -e "where is latest_release.json"
        fi
    else
        echo -e "Omniadmin jar already exists: $LRDIR/$omniadmin_741_jar_name"
    fi

    echo -e "[COMPLETE] Omniadmin setup completed!"
}

omniInstall () {
    parent_path="$(dirname "$PWD")"
    parent_dir="$(basename "$parent_path")"
    current_dir="$(basename "$PWD")"
    echo -e "\n---\nApplying OmniAdmin to spinner env: $current_dir"
    # if folder starts with env- && parent folder is spinner
    if [[ $current_dir =~ ^env- ]] && [[ "$parent_dir" == "spinner" ]]; then 
        # Place the Omniadmin Jar
        cp $omniadmin_jar_location/$latest_jar_name $destination
        if [[ -e "liferay_mount/files/deploy/$omniadmin_jar_name" ]]; then
            echo -e "[SUCCESS] $latest_jar_name placed in $destination"
        else
            echo -e "[ERROR] Please manually place OmniAdmin jar"
        fi

        # Update docker-compose.yml file with the encryption property to make OmniAdmin work
        sed -i -e "s/extra_hosts:/    - LIFERAY_PASSWORDS_PERIOD_ENCRYPTION_PERIOD_ALGORITHM=NONE\n        extra_hosts:/"  docker-compose.yml
        if grep -q "LIFERAY_PASSWORDS_PERIOD_ENCRYPTION_PERIOD_ALGORITHM" docker-compose.yml; then
            echo -e "[SUCCESS] Added the encryption property to docker-compose.yml file"
            rm omniadmin-spinner.sh
        else
            echo -e "[ERROR] Something went wrong, please add the following manually to the docker-compose.yml file: LIFERAY_PASSWORDS_PERIOD_ENCRYPTION_PERIOD_ALGORITHM=NONE"
        fi

        # Script Completion Notice
        echo "[COMPLETE] OmniAdmin Spinner install end"
    else
        echo "[ERROR] Current dir is not env-*: $current_dir"
        echo "[ERROR] Parent dir is not spinner: $parent_dir"
        echo "[ERROR] Please run 'omni' command inside /spinner/env-* directory"
    fi
}

# Bash Script --------------------------------------
if [[ $1 == "init" ]]; then
    init
else
    if [[ ! -f "$LRDIR/$omniadmin_jar_name" ]]; then
        echo -e "Omniadmin jar missing from $LRDIR"
        init
        omniInstall
    else
        omniInstall
    fi
fi