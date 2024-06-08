#!/bin/bash

# Database Configuration
DB_NAME="engweb_dev"
DB_USER="postgres"
DB_PASSWORD="postgres"
DB_HOST="localhost"
DB_PORT="5432"
EXPORT_FILE="./backups/backup.sql"

# Check if the database exists
if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
  echo "Database $DB_NAME exists."
else
  echo "Database $DB_NAME does not exist. Creating database and setting it up..."
  PGPASSWORD=$DB_PASSWORD createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME
  mix ecto.create
  mix ecto.migrate
  echo "Database $DB_NAME created and migrations run."
fi

# Import the database
PGPASSWORD=$DB_PASSWORD pg_restore --verbose --clean --no-owner --if-exists -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME $EXPORT_FILE

echo "Database import completed: $DB_NAME"