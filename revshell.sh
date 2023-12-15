#!/bin/sh

. /etc/revshell

IFCE=${IFACE:-$(ip --oneline ro get 8.8.8.8 | cut -f 5 -d ' ')}
MAC=$(cat /sys/class/net/${IFCE}//address)
HST=$(echo ${MAC} | tr ':' '-')
FQDN=${HST}.${ENDPOINT}
LISTENIP=$(dig +short ${FQDN})

umask 0077
cat <<EOF > ~/.ssh/known_hosts.revshell
${ENDPOINTHOSTKEY}
EOF

cat <<EOF > ~/.ssh/privkey.revshell
${SSHPRIVKEY}
EOF

/usr/bin/ssh -vvv -g -N -T -o "ServerAliveInterval 10" -o "ExitOnForwardFailure yes" -o "UserKnownHostsFile ~/.ssh/known_hosts.revshell" -i ~/.ssh/privkey.revshell -R ${LISTENIP}:${ENDPOINTPORT}:localhost:${LOCALSSHPORT} ${ENDPOINTUSR}@${ENDPOINT}

