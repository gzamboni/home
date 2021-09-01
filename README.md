# home

🚶‍♂️ Staying home...

---

# setting up new cluster

Nodes are `zberry3p` and `zberry3b`, IPs `192.168.0.11` and `192.168.0.12` respectively.

## setup hosts

```sh
# export IP=192.168.0.11
# export IP=192.168.0.12

# will ask to change password et al
ssh pi@$IP

# copy ssh pubkey
ssh-copy-id pi@$IP

# ssh again
ssh pi@$IP

# sudo hostname zberry3p
sudo hostname zberry
hostname | sudo tee /etc/hostname
sudo sed -i'' "s/127.0.0.1 localhost/127.0.0.1 localhost $(hostname)/" /etc/hosts
sudo apt update
sudo apt install -qy avahi-daemon # makes zberry3p.local and zberry3b.local work :)
sudo reboot
```

## adguard needs to listen on port 53

```sh
ssh pi@$IP

echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved.service
```

## setup k3s

```sh
k3sup install --user pi --host zberry3p.local --ip 192.168.0.11 --local-path kubeconfig
k3sup join --user pi --host zberry3b.local --ip 192.168.0.12 --server-ip 192.168.0.11

set -xg KUBECONFIG $PWD/kubeconfig
kubectl get nodes -w -owide
```

## install stuff

```
terraform apply
```
