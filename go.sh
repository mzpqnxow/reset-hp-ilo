#!/bin/bash
export LD_LIBRARY_PATH=$PWD/lib64
export PATH=$PWD/bin:$PATH

DHCP_FILE=enable_dhcp.xml
PASS_FILE=reset_password.xml
HPONCFG=hponcfg

function die() {
    echo "FATAL: $1"
    exit 1
}

function dump_users {
    echo "Enumerating existing users..."
    $HPONCFG -w current.xml || die "Failed to get running iLO configuration !!"
    for user in $(grep 'LOGIN USER_LOGIN' current.xml | cut -d '"' -f 2)
    do
        echo "- Valid user found: ${user}"
    done
}

dump_users

echo -n "Please enter the username of an existing account: "
read USERNAME
echo -n "Please enter the new password you'd like to set for that account: "
read PASSWORD

sed -e "s/%%USERNAME%%/${USERNAME}/" \
    -e "s/%%PASSWORD%%/${PASSWORD}/" \
    templates/${PASS_FILE} > ${PASS_FILE} || die "Failed to regex Password file !!"

echo Password Reset XML file created @ reset_password.xml

sed -e "s/%%USERNAME%%/${USERNAME}/" \
    -e "s/%%PASSWORD%%/${PASSWORD}/" \
    templates/${DHCP_FILE} > ${DHCP_FILE} || die "Failed to regex DHCP file !!"

echo DHCP Enable XML file created @ reset_password.xml

echo "Press enter to apply the changes to the iLO"
echo "WARN: THIS WILL PERMANENTLY CHANGE THE PASSWORD OF THE ACCOUNT !!"
echo -n "Continue?"
read ya
echo "Resetting password for user ${USERNAME} to ${PASSWORD}..."
$HPONCFG -f ${PASS_FILE} || die "Failed to set password !!"
echo "Setting iLO into full DHCP mode..."
$HPONCFG -f ${DHCP_FILE} || die "Failed to set DHCP mode !!"
echo "Successfully set iLO into full DHCP mode with specified password !!"
grep "<IP_ADDRESS VALUE" | cut -d '"' -f 2
$HPONCFG -w current.xml || die "Failed to get running iLO configuration !!"
ip_address=$(grep '<IP_ADDRESS VALUE' current.xml | cut -d '"' -f 2)
echo "You can now access the iLO via SSH or HTTPS @ ${ip_address}"
echo
echo "FIN"
