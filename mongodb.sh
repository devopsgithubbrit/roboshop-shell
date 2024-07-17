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

cp mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "Copied mongo"

dnf install mongodb-org -y 

VALIDATE $? "Installing mongodb"

systemctl enable mongod

VALIDATE $? "Enabling Mongod"

systemctl start mongod

VALIDATE $? "Starting Mongod"

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "PORTS"

systemctl restart mongod

VALIDATE $? "Restarting mongodb"