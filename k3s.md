k3s不同网络完整安装


## 安装K3S 准备工作

#### 如果是云平台，配置好公网IP在VPS上

```bash
cat /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
            addresses:
                  - 175.178.5.29/25
                  - 10.0.8.5/25
            match:
                macaddress: 52:54:00:62:99:be
            set-name: eth0
netplan apply
```

#### 安装wireguard
```bash

apt-get update && apt-get install wireguard resolvconf -y
 
```

#### 打开IP转发

```bash
//sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf 
sysctl -p
```

#### 如果离线安装
 ```bash
# 在官网上下载k3s-airgap-images-amd64.tar和k3s
# 创建目录
   sudo mkdir -p /var/lib/rancher/k3s/agent/images/
# 复制离线镜像到指定目录
   sudo cp k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
# 复制k3s并授权
   sudo cp ./k3s /usr/local/bin && sudo chmod 755 /usr/local/bin/k3s
# 下载安装脚本,并重新命名为install.sh
   wget get.k3s.io && mv index.html install.sh
# 授权install
   chmod +x install.sh
```

## 开始安装Server

#### 本地安装
  ```bash
    INSTALL_K3S_SKIP_DOWNLOAD=true  INSTALL_K3S_EXEC="--node-external-ip="服务器上的公网IP" --flannel-backend=wireguard-native --flannel-external-ip" ./install.sh
   ```
#### 在线安装
   ```bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=toke sh -s - \
    --node-external-ip="服务器上的公网IP" \
    --flannel-backend=wireguard-native \
    --flannel-external-ip
   ```


## 开始安装NODE
#### 获取token,在服务器端执行
  ```bash
cat /var/lib/rancher/k3s/server/node-token
  ```
#### 本地安装
  ```bash
  
  INSTALL_K3S_SKIP_DOWNLOAD=true  K3S_URL=https://服务器上的公网IP:6443 K3S_TOKEN=K10493ee94ca172fa0ba4e0cd1acdc1a0f8cb1f5444eadd852dc1775ef0f0908ac4::server:toke INSTALL_K3S_EXEC="--node-external-ip=本地的公网IP" ./install.sh
  
   ```
#### 在线安装
```bash
curl -sfL https://get.k3s.io | \
    K3S_URL=https://服务器上的公网IP:6443 \
    K3S_TOKEN=K10493ee94ca172fa0ba4e0cd1acdc1a0f8cb1f5444eadd852dc1775ef0f0908ac4::server:toke sh -s - \
    --node-external-ip="本地的公网IP"
 ```


## 常用命令

* 获取节点信息 kubectl get nodes -o wide
* 删除节点 kubectl delete node vm-8-5-ubuntu
* 日志查看 journalctl -xeu k3s.service

## 卸载k3s

### 卸载

```bash
/usr/local/bin/k3s-uninstall.sh #服务端
/usr/local/bin/k3s-agent-uninstall.sh #node端
 ```
