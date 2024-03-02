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

if [ $ID -ne 0 ]
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

useradd roboshop

VALIDATE $? "craeting roboshop user"   &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating app directory "  &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application"   &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE "Installing dependencies " &>> $LOGFILE

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue

systemctl start catalogue

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y

mongo --host mongodb.chintu.cloud </app/schema/catalogue.js