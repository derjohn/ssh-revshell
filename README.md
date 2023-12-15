# ssh-revshell
A reverse shell based on ssh and systemd for many devices like an IoT farm.

## WARNING
This is WORK IN PROGRESS.

## TL;DR
If you have a device behind a nat router and want to expose the servic/port of that device in the internet you can use a ssh remote port forwarding to do so.
You do not need a VPN.

This repo helps to create a "reverse shell" from an linux device behind a firewall. It runs as a systemd service and conencts outbounf through the NAT router, forwarding the devices ssh shell, so that you can access the device from the internet.

This was created for running a fleet of IoT devices behind firewalls which are managed by others and still having access to the IoT boxens.

Some ideas when taken from https://blog.stigok.com/2018/04/22/self-healing-reverse-ssh-systemd-service.html
 
## Prepare DNS entries
You need to create a DNS Entry for the the endpoint (a.k.a. ssh-server). In my case it's a CNAME for revshell.services.example.com .
Additionally For each exposed host you need a DNS entry for it's MAC address, like 00-30-be-ef-f0-0d.revshell.services.example.com
This way we do not need to configure each IoT device by itself.

## Prepare the ssh Server
On the server you need to create a user and a ssh-key that clients willl use to connect.
It's something like
adduser reverseshell
sudo -iu reverseshell
ssh-keygen -t ed
ssh-keygen -t ed25519
... /home/reverseshell/.ssh/id_ed25519_clients

Create a /home/reverseshell/.ssh/authorized_keys file with a line like
echo command="echo 'Port forwarding only account.'",agent-forwarding,port-forwarding  ssh-ed25519 AAAACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

## Prepare /etc/revshell
See etc-revshell.sample, rename it to etc-revshell and adapt the values

Hint: To fetch the hostkey you can use somethine like
ssh-keyscan revshell.services.example.com 2>/dev/null | grep 'ssh-ed25519'

