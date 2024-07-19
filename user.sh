#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.chintu.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling nodejs:10 version"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "enabling nodejs:18 version"

dnf install nodejs -y   &>> $LOGFILE

VALIDATE $? "installing nodejs"

id roboshop 
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app    &>> $LOGFILE

VALIDATE $? "Creating directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip      &>> $LOGFILE

VALIDATE $? "Downloading the user directory"

cd /app     &>> $LOGFILE

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install     &>> $LOGFILE

VALIDATE $? "Installing packages"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "setting user-service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reloading"

systemctl enable user   &>> $LOGFILE

VALIDATE $? "Enabled user"

systemctl start user    &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo   &>> $LOGFILE

VALIDATE $? "setting up mongo repo"

dnf install mongodb-org-shell -y    &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGDB_HOST </app/schema/user.js  &>> $LOGFILE

VALIDATE $? "loading schema"