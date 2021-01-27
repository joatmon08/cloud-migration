FROM alpine

ARG VERSION

COPY consul-terraform-sync /usr/local/bin/consul-terraform-sync

RUN apk add -u bash git
    # wget https://releases.hashicorp.com/consul-terraform-sync/${VERSION}/consul-terraform-sync_${VERSION}_linux_amd64.zip \
	# -O /tmp/cts.zip && \
    # unzip /tmp/cts.zip -d /tmp && \
    # mv /tmp/consul-terraform-sync /usr/local/bin/consul-terraform-sync && \
    # rm -f /tmp/cts.zip

ENTRYPOINT ["consul-terraform-sync"]