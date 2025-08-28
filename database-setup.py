import os
import mysql.connector

# Read .env file
env_path = '/var/www/html/.env'
env_vars = {}
with open(env_path, 'r') as f:
    for line in f:
        if '=' in line and not line.startswith('#'):
            key, value = line.strip().split('=', 1)
            env_vars[key] = value

# Get DB info
db_connection = env_vars.get('DB_CONNECTION')
db_host = env_vars.get('DB_HOST')
db_port = int(env_vars.get('DB_PORT', 3306))
db_database = env_vars.get('DB_DATABASE')
db_username = env_vars.get('DB_USERNAME')
db_password = env_vars.get('DB_PASSWORD')

if db_connection != 'mysql':
    print("Only MySQL is supported.")
    exit(1)

# Connect to MySQL server (not to a specific database)
conn = mysql.connector.connect(
    host=db_host,
    port=db_port,
    user=db_username,
    password=db_password
)
cursor = conn.cursor()

# Create database
cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{db_database}`;")
print(f"Database '{db_database}' created or already exists.")

cursor.close()
conn.close()