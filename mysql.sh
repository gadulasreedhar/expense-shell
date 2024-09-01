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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL server" 

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enable MYSQL Server" 

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Start MYSQL server" 

mysql -h  mysql.dev2011.online -u root -pExpenseApp@1 -e 'show databases'; &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    echo "MySql root password not set up.setting up now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 
    VALIDATE $? "Setting up root password"
else
    echo -e c "Mysql root password already set up.$Y skipping now $N" | tee -a $LOG_FILE
fi
