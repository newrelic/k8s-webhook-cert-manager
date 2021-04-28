# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.5.0
- Add the `--webhook-number` option to specified how many webhook to certify. Defaults to
  1.

## 1.4.0
- Support multiarch images

## 1.3.0
- Update to alpine 3.12.0

## 1.2.1
- Revert to using the full service name for the CN. There is an open issue in
  EKS in which the SAN is not added to the signed certificates, making the
  TLS requests from the apiserver to the webhook fail.
  https://github.com/awslabs/amazon-eks-ami/issues/341
- Validate that the length of the string "${service}.${namespace}.svc", which
  is used for the CN, is not greater than 64 characters as specified in the
  x509 spec.
- Use ca bundle to patch the webhook from the service account secret instead
  of fetching via kubectl.
- Set the number of retries for retrieving the issued certificate to 10 like
  the error message.
- Add the `--webhook-kind` option to specified between
  MutatingWebhookConfiguration or ValidatingWebhookConfiguration. Defaults to
  MutatingWebhookConfiguration.

## 1.2.0

- Use a much shorter common name for the certificate (only the Service's name)
  to avoid problems due to the character limit in CNs.

## 1.1.1

- Updated musl library to avoid security vulnerability: https://app.snyk.io/vuln/SNYK-LINUX-MUSL-458116

## 1.1.0

### Changed

- Container user is now is `1000` instead of `root`

## 1.0.1

### Added

- Better compatibility with Openshift by patching the webhook configuration json with an `add` operation instead of `replace`.

## 1.0.0
- Initial version of the Kubernetes Webhook Certificate Manager.
