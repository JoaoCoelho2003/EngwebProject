#!/bin/bash

# Database Configuration
DB_NAME="engweb_dev"
DB_USER="postgres"
DB_PASSWORD="postgres"
DB_HOST="localhost"
DB_PORT="5432"
EXPORT_FILE="./backups/backup.sql"

# Create backup directory if it doesn't exist
mkdir -p ./backups

# Export the password for non-interactive use
export PGPASSWORD=$DB_PASSWORD

# Export the database
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -F c -b -v -f $EXPORT_FILE $DB_NAME

echo "Database export completed: $EXPORT_FILE"
