# ssh-revshell
A reverse shell based on ssh and systemd for many devices like an IoT farm.

## WARNING
This is WORK IN PROGRESS.
This is WORK IN PROGRESS.
This is WORK IN PROGRESS.

## TL;DR
If you have a device behind a NAT router and want to expose the ssh service/port of that device in the internet you can use a ssh remote port forwarding to do so. You neither need a VPN, nor a port-forward on the NAT router. The device itself initiates the connection to the server in the inernet and "forwards" the ssh port onto the internet server and thus creates a "reverse shell".

This repo was created for running a fleet of IoT devices behind firewalls, CGNAT or mobile networks. 

Some ideas where taken from https://blog.stigok.com/2018/04/22/self-healing-reverse-ssh-systemd-service.html
 
## Prepare the Endpoint Server
Keep in mind that each device will need an own port on an own IP to listen on. We decided to listen on _localhost_ or the endpoint server only. That increases security. We created a bunch of IPs on the lo interface with systemd:

```
cat /etc/systemd/network/lo.network
[Match]
Name=lo

[Network]
Address=127.0.1.10/8
Address=127.0.1.11/8
...
```

Each device will have an DNS A record, so the known_hosts file will be happy to save one hostkey per device. You can listen to other IPs on that server if you like, maybe RC1918 IPs like 192.168.x.y, if you want to make the stuff available with your office oe such.

In any case to have to add the following option to the sshd on the endpoint server, like /etc/ssh/sshd_config:
```
GatewayPorts clientspecified
```

Furthermore you need to create a ssh user on the endpoint server which should be limited to port forward only:

1. Create the user, like adduser reverseshell
2. sudo -iu reverseshell
3. ssh-keygen -t ed25519
then choose a path for kes the IoT devives will use, e.g.  /home/reverseshell/.ssh/id_ed25519_clients
4. Create a /home/reverseshell/.ssh/authorized_keys file with a line like
echo command="echo 'Port forwarding only account.'",agent-forwarding,port-forwarding ssh-ed25519 AAAACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
(This limits the user to port-forwarding only and no reall on the endpoint server)

## Prepare DNS entries
You need to create a DNS Entry for the the endpoint server, e.g. CNAME for revshell.services.example.com .

Additionally For each exposed device you need a DNS entry for it's MAC address (yes, really!), like 00-30-be-ef-f0-0d.revshell.services.example.com

You can access the device from outside via ssh 00-30-be-ef-f0-0d.revshell.services.example.com then. (cool, heh ?)

## Prepare /etc/revshell
The client needs a config file. The cool thing is, that you only need the same config file for all devices, so you can put it on the baseimage of you devices.
See etc-revshell.sample, rename it to etc-revshell and adapt the values,

Hint: To fetch the hostkey of th endpoint server you can use something like
ssh-keyscan revshell.services.example.com 2>/dev/null | grep 'ssh-ed25519'

