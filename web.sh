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

dnf install nginx -y

VALIDATE $? "Install nginx"

systemctl enable nginx

VALIDATE $? "Enanle nginx"

systemctl start nginx

VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Downloaded Web application"

cd /usr/share/nginx/html

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "Copied roboshop reverse proxy config"

systemctl restart nginx 

VALIDATE $? "Restart nginx"