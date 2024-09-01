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

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enable nodejs20"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Install nodejs"

id expense &>>LOG_FILE
if [ $? -ne 0 ]
then
    echo "Expense user not created.creating now"
    useradd expense
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created.$Y skipping now $N" &>>$LOG_FILE
fi

mkdir -p /app
VALIDATE $? "Creating /app folder"

