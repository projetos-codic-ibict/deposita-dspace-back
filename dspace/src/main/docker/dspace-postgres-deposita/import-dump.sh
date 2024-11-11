#!/bin/bash

psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/dump/dump.sql"
# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/dump/dump.sql"
