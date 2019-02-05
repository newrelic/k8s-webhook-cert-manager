#!/usr/bin/env sh
set -e

SECRET_NAME="e2e-test-cert-manager-secret"
WEBHOOK_NAME="e2e-test-cert-manager-webhook"
JOB_NAME="e2e-test-cert-manager-setup"

# shellcheck disable=SC1090
. "$(dirname "$0")/k8s-e2e-bootstraping.sh"

finish() {
    printf "calling cleanup function\n"
    kubectl delete -f manifests/ || true
}

# build container
(
    cd ..
    make build-container
    cd -
)

trap finish EXIT

kubectl create -f manifests/webhook.yaml
awk '/image: / { print; print "        imagePullPolicy: Never"; next }1' manifests/cert-manager-job.yaml | kubectl create -f -

label="job-name=${JOB_NAME}"
job_pod_name=$(get_pod_name_by_label "$label")
if [ "$job_pod_name" = '' ]; then
    printf 'pod with label %s not found\n' "$label"
    kubectl describe job $JOB_NAME
    exit 1
fi
wait_for_pod "$job_pod_name"

printf 'secret:\n'
kubectl describe secret $SECRET_NAME
printf '\n'

printf 'mutating webhook configurations:\n'
kubectl get mutatingwebhookconfiguration
printf '\n'

caBundle=$(kubectl get mutatingwebhookconfiguration $WEBHOOK_NAME -o jsonpath='{.webhooks[0].clientConfig.caBundle}')
if [ "$caBundle" = '' ]; then
    printf "caBundle not found for %s\n" "$WEBHOOK_NAME"
    printf "webhook object:\n"
    kubectl describe mutatingwebhookconfiguration $WEBHOOK_NAME
    printf "job logs:\n"
    kubectl logs job/$JOB_NAME
else
    printf "caBundle found in %s object\n" "$WEBHOOK_NAME"
    printf "Tests are passing successfully\n\n"
fi
