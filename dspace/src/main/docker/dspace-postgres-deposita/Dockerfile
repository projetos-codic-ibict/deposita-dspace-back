#
# The contents of this file are subject to the license and copyright
# detailed in the LICENSE and NOTICE files at the root of the source
# tree and available online at
#
# http://www.dspace.org/license/
#

ARG POSTGRES_VERSION=15
ARG POSTGRES_PASSWORD=dspace

FROM postgres:${POSTGRES_VERSION}

ENV POSTGRES_DB dspace
ENV POSTGRES_USER dspace
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD}

# Importa dump do banco de dados para desenvolvimento
COPY import-dump.sh /docker-entrypoint-initdb.d/

# Copy over script which will initialize database and install pgcrypto extension
COPY --from=pgcrypto install-pgcrypto.sh /docker-entrypoint-initdb.d/
