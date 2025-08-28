import os
import subprocess

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

# Create database and user
mysql_commands = f"""
CREATE DATABASE IF NOT EXISTS `{db_database}`;
CREATE USER IF NOT EXISTS '{db_username}'@'%' IDENTIFIED BY '{db_password}';
GRANT ALL PRIVILEGES ON `{db_database}`.* TO '{db_username}'@'%';
FLUSH PRIVILEGES;
"""

subprocess.run([
    "mariadb",
    "-u", "root",
    "-e", mysql_commands
], check=True)

# Update root password

mysql_commands = f"""
ALTER USER 'root'@'localhost' IDENTIFIED BY '{db_password}';
FLUSH PRIVILEGES;
"""

subprocess.run([
"mariadb",
"-u", "root",
"-e", mysql_commands
], check=True)