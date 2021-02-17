FROM alpine:3.13

# This makes it easy to build tagged images with different `kubectl` versions.
ARG KUBECTL_VERSION="v1.13.12"

# Set by docker automatically
# If building with `docker build`, make sure to set GOOS/GOARCH explicitly when calling make:
# `make compile GOOS=something GOARCH=something`
# Otherwise the makefile will not append them to the binary name and docker build wil fail.
ARG TARGETOS
ARG TARGETARCH

RUN apk add --update openssl
RUN wget https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/$TARGETOS/$TARGETARCH/kubectl \
    && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

COPY ./generate_certificate.sh /app/generate_certificate.sh
RUN chmod +x /app/generate_certificate.sh

WORKDIR /app

USER 1000

CMD ["./generate_certificate.sh"]
