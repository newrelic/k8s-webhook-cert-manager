FROM alpine:3.13

# This makes it easy to build tagged images with different `kubectl` versions.
ARG KUBECTL_VERSION="v1.13.12"

# Set by docker automatically
ARG TARGETOS
ARG TARGETARCH

RUN apk --upgrade --no-cache add openssl && \
    wget "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

WORKDIR /app
USER 1000

COPY --chmod=755 ./generate_certificate.sh /app/generate_certificate.sh

CMD ["./generate_certificate.sh"]