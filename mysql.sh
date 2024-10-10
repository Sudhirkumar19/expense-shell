#!/bin/bash

LOGS_FOLDER="/var/log/expense"

SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#echo "user ID is: $USERID"  # CHECKROOT is a function call here
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo  -e "$R please run script with roogt permissions $N" | tee -a $LOG_FILE

    exit 1
fi
}

# VALIDATE is a function call here
VALIDATE(){
    #echo "exit status : $1"
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R failed $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    fi
}

echo -e "$G script started executing at: $N $(date)" | tee -a $LOG_FILE 

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql Server" 

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabled mysql server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "starting of mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
VALIDATE $? "setting root pw"


