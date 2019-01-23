FROM alpine:latest

# This makes it easy to build tagged images with different `kubectl` versions.
ARG KUBECTL_VERSION="v1.13.0"

USER root
RUN apk add --update openssl curl bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

COPY ./generate_certificate.sh /app/generate_certificate.sh
RUN chmod +x /app/generate_certificate.sh

WORKDIR /app

ENTRYPOINT "/bin/ash"
CMD ["./generate_certificate.sh"]
