FROM alpine:latest

# This makes it easy to build tagged images with different `kubectl` versions.
ARG KUBECTL_VERSION="v1.13.0"

RUN apk add --update openssl
RUN wget https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

COPY ./generate_certificate.sh /app/generate_certificate.sh
RUN chmod +x /app/generate_certificate.sh

WORKDIR /app

USER 1000

CMD ["./generate_certificate.sh"]
