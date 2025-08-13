#!/bin/bash
set -e

echo "Waiting for SQL Server to be ready..."

for i in {1..30}; do
    /opt/mssql-tools/bin/sqlcmd \
        -S sqlserver -U sa -P 'YourStrong!Passw0rd' \
        -Q "SELECT 1" &>/dev/null && break
    echo "Waiting... ($i/30)"
    sleep 2
done

echo "Running initialization script..."
/opt/mssql-tools/bin/sqlcmd \
    -S sqlserver -U sa -P 'YourStrong!Passw0rd' \
    -i /init.sql

echo "Database initialized."