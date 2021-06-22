#!/bin/bash
if [ -f "/var/opt/mssql/data/.sql-created" ]; then
    echo "Already initialized"
    exit 0
fi

echo "Waiting for MS SQL to be available ⏳"

# wait for MSSQL server to start
export STATUS=1
i=0

while [[ $STATUS -ne 0 ]] && [[ $i -lt 30 ]]; do
	i=$i+1
	/opt/mssql-tools/bin/sqlcmd -t 1 -U sa -P $SA_PASSWORD -Q "select 1" >> /dev/null
	STATUS=$?
done

if [ $STATUS -ne 0 ]; then
	echo "Error: MSSQL SERVER took more than thirty seconds to start up."
	exit 1
fi

echo =============== MSSQL STARTED                     ==========================

if [ ! -z $MSSQL_USER ]; then
    echo "MSSQL_USER: $MSSQL_USER"
else
    MSSQL_USER=example
    echo "MSSQL_USER: $MSSQL_USER"
fi

if [ ! -z $MSSQL_PASSWORD ]; then
    echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
else
    MSSQL_PASSWORD=Password1!
    echo "MSSQL_PASSWORD: $MSSQL_PASSWORD"
fi

if [ ! -z $MSSQL_DB ]; then
    echo "MSSQL_DB: $MSSQL_DB"
else
    MSSQL_DB=exampleDB
    echo "MSSQL_DB: $MSSQL_DB"
fi

echo =============== CREATING INIT DATA                ==========================



cat <<-EOSQL > init.sql
CREATE DATABASE $MSSQL_DB;
GO
USE $MSSQL_DB;
GO
CREATE LOGIN $MSSQL_USER WITH PASSWORD = '$MSSQL_PASSWORD';
GO
CREATE USER $MSSQL_USER FOR LOGIN $MSSQL_USER;
GO
ALTER SERVER ROLE sysadmin ADD MEMBER [$MSSQL_USER];
GO
EOSQL

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -t 30 -i"./init.sql" -o"./initout.log"

echo =============== INIT DATA CREATED                    ==========================
echo =============== MSSQL SERVER SUCCESSFULLY STARTED ==========================
touch /var/opt/mssql/data/.sql-created

