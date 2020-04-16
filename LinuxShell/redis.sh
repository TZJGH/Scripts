#! /bin/bash
# redis cluster create

if [ ! -e /root/redis-5.0.5.tar.gz ]
then
echo "下载文件"
wget "http://download.redis.io/releases/redis-5.0.5.tar.gz"
fi
if [ ! -e/root/redis-5.0.5 ]
then
echo "解压文件"
tar xzf redis-5.0.5.tar.gz
fi
if [ ! -e /root/redis-5.0.5/src ]
then
echo "编译中........"
cd /root/redis-5.0.5
make
cd /root
fi
if [ -e /root/redis-5.0.5/ ]
then
echo "准备部署"
portsDics=(7000 7001 7002 7003 7004 7005)
#--------
for dicname in ${portsDics[@]}
do
mkdir /root/$dicname
#echo "bind 0.0.0.0" >> /root/$dicname/redis.conf
echo "port $dicname" >> /root/$dicname/redis.conf
echo "cluster-enabled yes" >> /root/$dicname/redis.conf
echo "cluster-config-file nodes.conf" >> /root/7000/redis.conf
echo "cluster-node-timeout 5000" >>/root/$dicname/redis.conf
echo "appendonly yes" >> /root/$dicname/redis.conf
echo "protected-mode no" >> /root/$dicname/redis.conf
#--------
cp -rp /root/redis-5.0.5/src /root/$dicname
#--------
echo "[Unit]" >> /etc/systemd/system/redis$dicname.service
echo "Description=redis cluster node $dicname" >> /etc/systemd/system/redis$dicname.service
echo "" >> /etc/systemd/system/redis$dicname.service
echo "[Service]" >> /etc/systemd/system/redis$dicname.service
echo "WorkingDirectory=/root/$dicname" >> /etc/systemd/system/redis$dicname.service
echo "ExecStart=/root/$dicname/src/redis-server /root/$dicname/redis.conf" >> /etc/systemd/system/redis$dicname.service
echo "Restart=always" >> /etc/systemd/system/redis$dicname.service
echo "RestartSec=10" >> /etc/systemd/system/redis$dicname.service
echo "killSignal=SIGINT" >> /etc/systemd/system/redis$dicname.service
echo "SyslogIdentifier=redis_node_log_$dicname" >> /etc/systemd/system/redis$dicname.service
echo "User=root" >> /etc/systemd/system/redis$dicname.service
echo "" >> /etc/systemd/system/redis$dicname.service
echo "[Install]" >> /etc/systemd/system/redis$dicname.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/redis$dicname.service
#--------
sudo systemctl enable redis$dicname.service
sudo systemctl start redis$dicname.service
sleep 3
sudo systemctl status redis$dicname.service
done
fi
#--------
echo "yes" | /root/redis-5.0.5/src/redis-cli --cluster create $1:7000 $1:7001 $1:7002 $1:7003 $1:7004 $1:7005 --cluster-replicas 1

