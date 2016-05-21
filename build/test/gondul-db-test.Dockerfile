FROM debian:jessie
RUN apt-get update && apt-get install -y postgresql-9.4
ADD build/test/pg_hba.tail /pg_hba.tail
RUN cat /pg_hba.tail >> /etc/postgresql/9.4/main/pg_hba.conf
RUN service postgresql start && su postgres -c "psql --command=\"CREATE ROLE nms PASSWORD 'risbrod' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\"" && su postgres -c "createdb -O nms nms" && service postgresql stop
ADD build/schema.sql /schema.sql
RUN service postgresql start && su postgres -c "cat /schema.sql | psql nms" && service postgresql stop
ADD build/test/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
CMD pg_ctlcluster --foreground 9.4 main start
EXPOSE 5432
