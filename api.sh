#!/bin/sh
APP_NAME="api.jar"

echo "============= $APP_NAME =============="

#启动服务前，先看看是否在运行

pid=$(ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}')
#如果服务存在，就杀掉
if [ $pid ]; then

	echo kill $pid
	kill -9 $pid
fi

nohup /usr/lib/jvm/jdk-20.0.1/bin/java -jar -Xms1024m -Xmx1024m -Xmn700m -Xss16m /root/$APP_NAME --spring.profiles.active=prod >api.log 2>&1 &

sleep 2

pid=&(ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}')

if [ $pid ]; then
	echo "$APP_NAME start success ..."
	echo "pid is: $pid"
	tail -f /root/api.log
else
	echo "$APP_NAME start fail ..."
fi
exit 0
