-- Least-privilege MySQL user for App3 (UMS).
-- Normally applied by: ./ops/phase-a-create-app3-user.sh (SSM SendCommand as dbadmin).
-- Placeholder APP3_DB_PASSWORD is filled from secrets.tfvars app3_db_password
-- and must match Parameter Store /<env>/app3/db/password.
-- Do not commit real passwords.

CREATE USER IF NOT EXISTS 'app3'@'%' IDENTIFIED BY 'APP3_DB_PASSWORD';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX
  ON webappdb.*
  TO 'app3'@'%';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'app3'@'%';
