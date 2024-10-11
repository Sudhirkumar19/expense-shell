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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodes:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$G user expense is not available $G creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating expense user"
else
    echo -e "$G user is already exist $Y skipping it $N"
fi

# useradd expense &>>$LOG_FILE
# VALIDATE $? "creating expense user"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "create app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "dowloading zip backend application  code "

cd /app
VALIDATE $? "change directory "
rm -rf /app/* # remove the existing files/code  for new files deployment
unzip /tmp/backend.zip
VALIDATE $? "Unzip backend code file "








# mysql -h 172.31.18.98 -u root -pExpenseApp@1 -e 'show databases;'  &>>$LOG_FILE
# if [ $? -ne 0 ] 
# then
#     echo "MYSQL root password is not setup, setting now"&>>$LOG_FILE
#     mysql_secure_installation --set-root-pass ExpenseApp@1
#     VALIDATE $? "setting up root password"
# else
#     echo -e "MYSQL root password is already setup ...$Y SKKIPPING $N" | tee -a $LOG_FILE
# fi
