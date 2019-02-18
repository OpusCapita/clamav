FROM lokori/clamav-rest
MAINTAINER gr4per

RUN yum install epel-release -y 
RUN yum install -y clamav clamd
RUN yum install -y nc

HEALTHCHECK --interval=15s --timeout=3s --retries=12 \
  CMD ./healthcheck.sh || exit 1

COPY entrypoint.sh entrypoint.sh
COPY refresh.sh refresh.sh
COPY healthcheck.sh healthcheck.sh

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
