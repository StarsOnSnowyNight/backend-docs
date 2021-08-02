DATE=$(date +%Y-%m-%d_%H:%M:%S)
FILE_DIR=/data/server/$1
BAK_DIR=$FILE_DIR/bak
FILE_NAME=$1-$2-SNAPSHOT.jar
BAK_FILE_NAME=$FILE_NAME.bak$DATE
echo "备份文件开始..."
if [ ! -d $BAK_DIR ];then
   mkdir -p $BAK_DIR
fi
mv $FILE_DIR/$FILE_NAME $BAK_DIR/$BAK_FILE_NAME
echo "备份文件结束"

