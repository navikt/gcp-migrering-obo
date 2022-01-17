FROM google/cloud-sdk:368.0.0

RUN apt-get update && apt-get install -y \
  postgresql-client \
  postgresql-contrib \ 
  wget

RUN wget https://github.com/mikefarah/yq/releases/download/4.16.2/yq_linux_amd64 -O /usr/local/bin/yq
RUN chmod 755 /usr/local/bin/yq

RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
RUN chmod 755 /usr/local/bin/cloud_sql_proxy

ENV CLOUDSDK_PROXY_TYPE http
ENV CLOUDSDK_PROXY_ADDRESS webproxy.nais
ENV CLOUDSDK_PROXY_PORT 8088
#From NAIS
ENV CLOUDSDK_CORE_CUSTOM_CA_CERTS_FILE /etc/ssl/ca-bundle.pem 

CMD ["sh", "-c", "tail -f /dev/null"]
