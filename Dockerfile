FROM lokori/clamav-rest
MAINTAINER gr4per

COPY entrypoint.sh entrypoint.sh

RUN yum install epel-release -y 
RUN yum install -y clamav clamd

HEALTHCHECK --interval=15s --timeout=3s --retries=12 \
  CMD freshclam status | tail -n1 | grep -e "up to date" || exit 1

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
#ENTRYPOINT ["whoami"]
