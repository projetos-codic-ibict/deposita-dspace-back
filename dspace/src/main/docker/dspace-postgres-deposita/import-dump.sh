#!/bin/bash

psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "/dump/dump.sql"
