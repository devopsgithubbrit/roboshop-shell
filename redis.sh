#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

echo "script stareted executing at $TIMESTAMP" 

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "Installing remi"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "Enabling redis for packages"

dnf install redis -y

VALIDATE $? "Installing redis"

sed -i  '/s/12127.0.0.1/0.0.0.0'    /etc/redis/redis.conf

VALIDATE $? "Allowing remote connections"

systemctl enable redis

VALIDATE $? "Enabled redis"

systemctl start redis

VALIDATE $? "Started redis"

