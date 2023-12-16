#!/bin/sh

. /etc/revshell

IFCE=${IFACE:-$(ip --oneline ro get 8.8.8.8 | cut -f 5 -d ' ')}
MAC=$(cat /sys/class/net/${IFCE}/address)
HST=$(echo ${MAC} | tr ':' '-')
FQDN=${HST}.${ENDPOINT}
LISTENIPDEFNS=$(dig +short ${FQDN} 2> /dev/null | grep -v ';;')
LISTENIP8888=$(dig @8.8.8.8 +short ${FQDN} 2> /dev/null | grep -v ';;')
LISTENIP=${LISTENIP8888:-${LISTENIPDEFNS}}

umask 0077
cat <<EOF > /root/.ssh/known_hosts.revshell
${ENDPOINTHOSTKEY}
EOF

cat <<EOF > /root/.ssh/privkey.revshell
${SSHPRIVKEY}
EOF

/usr/bin/ssh -v -g -N -T -o "ServerAliveInterval 10" -o "ExitOnForwardFailure yes" -o "UserKnownHostsFile /root/.ssh/known_hosts.revshell" -i /root/.ssh/privkey.revshell -R ${LISTENIP}:${ENDPOINTPORT}:localhost:${LOCALSSHPORT} ${ENDPOINTUSR}@${ENDPOINT}

