FROM quay.io/tembo/standard-cnpg:15-ed6e9e9

USER root

RUN apt-get update && \
    apt-get install -y git vim openssl && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN chown -R postgres:postgres $PGDATA && \
    chmod -R 0700 $PGDATA
# Set up the environment for the data directory
ENV PGDATA /var/lib/postgresql/data2
RUN mkdir -p $PGDATA && \
    chown -R postgres:postgres $PGDATA && \
    chmod -R 0700 $PGDATA

# Generate self-signed certificate
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/CN=*.local.tembo.io" \
    -keyout /var/lib/postgresql/server.key \
    -out /var/lib/postgresql/server.crt && \
    chown postgres:postgres /var/lib/postgresql/server.* && \
    chmod 600 /var/lib/postgresql/server.key

# Copy the init_pgdata.sh script to the correct location
COPY init_pgdata.sh /docker-entrypoint-initdb.d/init_pgdata.sh

# Set permissions for the init_pgdata.sh script
RUN chmod +x /docker-entrypoint-initdb.d/init_pgdata.sh

USER postgres

# Initialize the database if not already initialized
RUN if [ ! -s "$PGDATA/PG_VERSION" ]; then pg_ctl -c init; fi

# Set permissive authentication (for local testing)
RUN echo "hostssl all all 0.0.0.0/0 trust" >> ${PGDATA}/pg_hba.conf
RUN echo "include_dir = 'extra-configs'" >> ${PGDATA}/postgresql.conf
RUN mkdir -p $PGDATA/extra-configs

# Set environment variables
ENV PGHOST=localhost
ENV PGPORT=5432
ENV PGDATABASE=postgres
ENV PGUSER=postgres



RUN trunk install --version 1.10.0 pg_stat_statements



# Optional:
# Specify extra Postgres configurations by copying into this directory
COPY postgres.conf $PGDATA/extra-configs/postgres.conf

CMD ["postgres"]
