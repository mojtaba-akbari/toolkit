#!/usr/bin/python3

import boto
import boto.s3.connection
import boto3
import configparser
import os
import sys
import time
import getpass

access_key = '462cd1b1f8f4fd079f9578a01fddea24716cb78c'
secret_key = '86ad03e5140b0983075d8eec49a47561aa5731e6fc62c46fc0d9639552bc677c95112291582c3a60'
s3_host = 'kise-thr-nd-1.sotoon.cloud'

conn = boto.connect_s3(aws_access_key_id='462cd1b1f8f4fd079f9578a01fddea24716cb78c',
                       aws_secret_access_key='86ad03e5140b0983075d8eec49a47561aa5731e6fc62c46fc0d9639552bc677c95112291582c3a60',
                       host='kise-thr-nd-1.sotoon.cloud',
                       is_secure=False,
                       calling_format=boto.s3.connection.OrdinaryCallingFormat())
s3 = boto3.resource('s3',
                    endpoint_url='https://kise-thr-nd-1.sotoon.cloud',
                    aws_access_key_id='462cd1b1f8f4fd079f9578a01fddea24716cb78c',
                    aws_secret_access_key='86ad03e5140b0983075d8eec49a47561aa5731e6fc62c46fc0d9639552bc677c95112291582c3a60')


HOST = "10.0.0.103"
USER = "zooket"
PORT = "31309"
PASSWORD = "pZUqdZDd2u"
DATABASES = "search_db"
TYPEDB= "PS"

def get_dump(filestamp, type):
    
    if(type == "my"):
        print(" MySQL EndPoint Backup....")
        conn = "mysqldump -h "+HOST+" -P "+PORT+" -u"+USER + \
            " -p"+PASSWORD+" "+DATABASES+" > "+DATABASES+"_"+filestamp+".sql"
    elif(type == "ps"):
        print(" PSql EndPoint Backup....")
        conn = "PGPASSWORD='"+PASSWORD+"' pg_dump -h "+HOST+" -p "+PORT+" -U "+USER+" -Z 9 "+DATABASES+" >"+DATABASES+"_"+filestamp+".ps"

    os.popen(conn)

if __name__ == "__main__":

    filestamp = time.strftime('%Y-%m-%d')

    print(sys.argv)

    if(len(sys.argv)<6):
        print("Less Arg : HOST USER PORT PASSWORD DATABASE TYPE(ps,my)")

    else:
        HOST=sys.argv[1]
        USER=sys.argv[2]
        PORT=sys.argv[3]
        PASSWORD=sys.argv[4]
        DATABASES=sys.argv[5]
        TYPEDB=sys.argv[6]


        get_dump(DATABASES,filestamp)

        s3.Bucket("backup-db-search").upload_file(DATABASES+"_"+filestamp+"."+TYPEDB, DATABASES+"_"+filestamp+"."+TYPEDB)


