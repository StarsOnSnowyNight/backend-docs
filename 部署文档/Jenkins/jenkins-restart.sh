FILE_DIR=/data/server/$1
FILE_NAME=$1-$2-SNAPSHOT.jar
pid=`ps -ef | grep "$1" | grep "java" | awk '{print $2}'`
echo “旧进程id:$pid”
if [ -n "$pid" ]
then
	echo "kill -15 杀死旧进程,并睡眠10秒，进程id:$pid"
	kill -15 $pid
	sleep 10s
fi
echo "再次查询进程，如果进程存在，就执行kill -9"
pid2=`ps -ef | grep "$1" | grep "java" | awk '{print $2}'`
echo “旧进程id:$pid2”
if [ -n "$pid2" ]
then
	echo "进程还在，kill -9，进程id:$pid2"
	kill -9 $pid2
fi
cd $FILE_DIR
echo "删除nohup.out"
rm nohup.out
echo "启动进程，睡眠20s..."
nohup java -jar $FILE_NAME >> nohup.out &
sleep 20s
npid=`ps -ef | grep $1 | grep -v grep | awk '{print $2}'`
echo "打印最后100行日志"
tail -n 100 nohup.out
echo "打印完毕，新的进程id:$npid:$?"




