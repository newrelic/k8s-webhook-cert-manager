[![New Relic Community Plus header](https://raw.githubusercontent.com/newrelic/open-source-office/master/examples/categories/images/Community_Plus.png)](https://opensource.newrelic.com/oss-category/#community-plus)

# Kubernetes Webhook Certificate Manager

[![Build Status](https://travis-ci.com/newrelic/k8s-webhook-cert-manager.svg?branch=master)](https://travis-ci.com/newrelic/k8s-webhook-cert-manager)

Script to generate a certificate suitable for use with any Kubernetes Mutating or Validating Webhook.

To be able to execute the script in a Kubernetes cluster, it's released as a Docker image and can be executed, for instance, as a Kubernetes Job. 

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

This script is designed to run in Kubernetes clusters. For development purposes, we recommend using [Minikube](https://github.com/kubernetes/minikube).

## Support

Should you need assistance with New Relic products, you are in good hands with several support channels.

If the issue has been confirmed as a bug or is a feature request, file a GitHub issue.

**Support Channels**

* [New Relic Documentation](https://docs.newrelic.com): Comprehensive guidance for using our platform
* [New Relic Community](https://discuss.newrelic.com): The best place to engage in troubleshooting questions
* [New Relic Developer](https://developer.newrelic.com/): Resources for building a custom observability applications
* [New Relic University](https://learn.newrelic.com/): A range of online training for New Relic users of every level
* [New Relic Technical Support](https://support.newrelic.com/) 24/7/365 ticketed support. Read more about our [Technical Support Offerings](https://docs.newrelic.com/docs/licenses/license-information/general-usage-licenses/support-plan).

## Privacy

At New Relic we take your privacy and the security of your information seriously, and are committed to protecting your information. We must emphasize the importance of not sharing personal data in public forums, and ask all users to scrub logs and diagnostic information for sensitive information, whether personal, proprietary, or otherwise.

We define “Personal Data” as any information relating to an identified or identifiable individual, including, for example, your name, phone number, post code or zip code, Device ID, IP address, and email address.

For more information, review [New Relic’s General Data Privacy Notice](https://newrelic.com/termsandconditions/privacy).

## Contribute

We encourage your contributions to improve this project! Keep in mind that when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project.

If you have any questions, or to execute our corporate CLA (which is required if your contribution is on behalf of a company), drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](/security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

If you would like to contribute to this project, review [these guidelines](./CONTRIBUTING.md).

To all contributors, we thank you!  Without your contribution, this project would not be what it is today.

## License

This project is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.
