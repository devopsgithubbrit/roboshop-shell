#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR:: $2 ... $R FAILED $N"
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

cp /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "Repository Setup"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "Installing MOngoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod  &>> $LOGFILE

VALIDATE $ "Starting MongoDB"

sed -i "/s/127.0.0.1 to 0.0.0.0"  /etc/mongod.conf  &>> $LOGFILE

VALIDATE $? "port change"

systemctl restart mongod    &>> $LOGFILE

VALIDATE $? "Restarting MongoDB"