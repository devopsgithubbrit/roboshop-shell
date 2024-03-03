#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]   #if roboshop user does not exist, then it is failure
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
else
    echo "You are root user"
fi

dnf module disable nodejs -y

VALIDTE $? "Disabling current NODEJS" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling NodeJS:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing NodeJS application"  &>> $LOGFILE

useradd roboshop                            &>> $LOGFILE

VALIDATE $? "craeting roboshop user"   

mkdir -p/app

VALIDATE $? "Creating app directory "  

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application"   &>> $LOGFILE

cd /app 

unzip /tmp/user.zip  $LOGFILE

VALIDATE "unzipping user" &>> 

npm install &>> $LOGFILE

VALIDATE "Installing dependencies " &>> $LOGFILE

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user   &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user   &>> $LOGFILE

VALIDATE "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y  & >> LOGFILE

VALIDATE $? "Installed mongodb client"

mongo --host mongodb.chintu.cloud </app/schema/user.js  & >> LOGFILE

VALIDATE $? "Loading user data into MOngoDb"