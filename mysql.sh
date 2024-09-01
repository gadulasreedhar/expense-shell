#!/bin/bash
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


CHKROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root privilages. $N" | tee -a $LOG_FILE
        exit 1 
    # else
    #     echo "Used id is: $USERID"
   fi
}
VALIDATE(){
if [ $1 -ne 0 ] 
then 
    echo -e  "$2 is ... $R FAILED $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$2 is ...  $G SUCCESS $N" | tee -a $LOG_FILE
fi
}

echo "Scipt started executed at:$(date)"  | tee -a $LOG_FILE

CHKROOT

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL server" &>>$LOG_FILE

systemctl enable mysqld
VALIDATE $? "Enable MYSQL Server" &>>$LOG_FILE

systemctl start mysqld
VALIDATE $? "Start MYSQL server" &>>$LOG_FILE

mysql_secure_installation --set-root-pass ExpenseApp@1
