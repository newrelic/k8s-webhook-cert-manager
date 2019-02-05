# Kubernetes Webhook Certificates Manager

Script to generate a certificate suitable for use with any Kubernetes Mutating
Webhook. 

To be able to execute the script in a Kubernetes cluster, it's released as a
docker image and can be executed, for instance, as a Kubernetes Job. 

This is a detailed list of steps the script is executing:

- Generate a server key.
- If there is any previous CSR (certificate signing request) for this key, it is deleted.
- Generate a CSR for such key.
- The signature of the key is then approved.
- The server's certificate is fetched from the CSR and then encoded.
- A secret of type tls is created with the server certificate and key.
- The k8s extension api server's CA bundle is fetched.
- The mutating webhook configuration for the webhook server is patched with the k8s api server's CA bundle from the previous step. This CA bundle will be used by the k8s extension api server when calling our webhook.

If you wish to learn more about TLS certificates management inside Kubernetes, check out the official documentation for [Managing TLS Certificate in a Cluster](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificate-signing-request-object-to-send-to-the-kubernetes-api).

## Usage example

The script expects multiple mandatory arguments. This is an example:

``` sh
./generate_certificate.sh --service ${WEBHOOK_SERVICE_NAME} --webhook
${WEBHOOK_NAME} --secret ${SECRET_NAME} --namespace ${WEBHOOK_NAMESPACE} 
```

## Development setup

This script is designed to run in Kubernetes clusters. For development purposes,
we recommend using [Minikube](https://github.com/kubernetes/minikube).

## Contributing

We welcome code contributions (in the form of pull requests) from our user community. Before submitting a pull request please review [these guidelines](./CONTRIBUTING.md)

Following these helps us efficiently review and incorporate your contribution and avoid breaking your code with future changes.
