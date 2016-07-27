#!/bin/bash
DEPLOY_HOME="/data/app/deploy/"
PROJECT="$1"
ENV_TYPE="$2"
JENKINS_HOME="$3"
PROJECT_NAME="${PROJECT}_${ENV_TYPE}"
WORKSPACE_HOME="$JENKINS_HOME/workspace/"
BUILD_HOME="$WORKSPACE_HOME/$PROJECT_NAME/target/${PROJECT}-1.0.0-BUILD-SNAPSHOT/"
USER_DIR="$ENV_TYPE"
CHANG_LIST_DIR="$DEPLOY_HOME/project_changed_lists/$USER_DIR"
CHANG_LIST="${PROJECT}_${ENV_TYPE}_changed_list.txt"
EXTACT_DIR="$DEPLOY_HOME/extract_files"
SCRIPT_DIR="$DEPLOY_HOME/scripts"
LOG_DIR="$SCRIPT_DIR"
LOG_FILE="extract_file.log"
SVN_URL=$4
SVN_REVISION=$5
UPDATE_TYPE=${6:-INC}
UPDATE_TYPE=$(echo -e $UPDATE_TYPE|tr '[a-z]' '[A-Z]')
ECHO_PREFIX=""
ECHO_SUFFIX="\033[0m"
FILE_FLAG=0
TEMP_DIR=$SCRIPT_DIR/temp
TEMP_FILE="temp_${PROJECT}_${ENV_TYPE}_`date +%Y%m%d_%H%M%S`"
# echo -e "${ECHO_PREFIX}rm -r $EXTACT_DIR/$PROJECT_NAME${ECHO_SUFFIX}"
[ -d $EXTACT_DIR/$PROJECT_NAME ]&&rm -r $EXTACT_DIR/$PROJECT_NAME
[ ! -d $EXTACT_DIR/$PROJECT_NAME ]&&mkdir -p $EXTACT_DIR/$PROJECT_NAME
cd $BUILD_HOME

echo -e "${ECHO_PREFIX}${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}时间:`date`${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}##### $PROJECT_NAME  #####${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}JENKINS_HOME:$JENKINS_HOME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}PROJECT_NAME:$PROJECT_NAME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}BUILD_HOME:$BUILD_HOME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}USER_DIR:$USER_DIR${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}CHANG_LIST:$CHANG_LIST${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}SVN URL:$SVN_URL${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}SVN REVISION:$SVN_REVISION${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE

if [ x"$UPDATE_TYPE" == x"INC" ];then
	[ `cat $CHANG_LIST_DIR/$CHANG_LIST|grep -v "^#"|grep -v "^$"|grep -vE "^[[:space:]]+$"|wc -l` -eq 0 ]&&echo -e "\033[40;31m错误:变更申请单数据为空!!!${ECHO_SUFFIX}"|tee -a $LOG_DIR/$LOG_FILE&&exit 1
	echo -e "\033[40;33m注意:根据变更申请单${CHANG_LIST}抽取文件!!!${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE	
	echo -e "${ECHO_PREFIX}++++++++++++++++++++++++++++++++++++++++++++${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
	cat $CHANG_LIST_DIR/$CHANG_LIST|grep -v "^#"|grep -v "^$"|grep -vE "^[[:space:]]+$"|sed 's/^\///g' >$TEMP_DIR/$TEMP_FILE
	while read file;do
		echo -e "\033[32m抽取文件 /$file ${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE 
		cp -r --parents $file $EXTACT_DIR/$PROJECT_NAME
		[ $? -ne 0 ]&&FILE_FLAG=1
	done < $TEMP_DIR/$TEMP_FILE
elif [ x"$UPDATE_TYPE" == x"ALL" ];then
	echo -e "\033[40;33m注意:进行全量抽取!!!${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
	echo -e "${ECHO_PREFIX}++++++++++++++++++++++++++++++++++++++++++++${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
	echo -e "\033[32m抽取文件 $BUILD_HOME/* ${ECHO_SUFFIX}"
	cp -r * $EXTACT_DIR/$PROJECT_NAME
	
else
	echo -e "\033[40;31m错误:输入的最后一位参数是$UPDATE_TYPE,不是ALL或者INC.${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
	exit 1
fi
if [ $FILE_FLAG -ne 0 ];then
	echo -e "\033[40;31m错误:读取变更申请单${CHANG_LIST}遇到问题，脚本终止.${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
	exit 1
fi
echo -e "${ECHO_PREFIX}++++++++++++++++++++++++++++++++++++++++++++${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
cd $EXTACT_DIR/$PROJECT_NAME
echo -e "\033[34m抽取出文件树结构:${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "\033[34m`tree *`${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
