#!/usr/bin/env sh
set -e

SECRET_NAME="e2e-test-cert-manager-secret"
WEBHOOK_NAME="e2e-test-cert-manager-webhook"
JOB_NAME="e2e-test-cert-manager-setup"

# shellcheck disable=SC1090
. "$(dirname "$0")/k8s-e2e-bootstraping.sh"

get_pod_name_by_label() {
    pod_name=""
    i=1
    while [ "$i" -ne 10 ]
    do
        pod_name=$(kubectl get pods -l "$1" -o name | sed 's/pod\///g; s/pods\///g')
        if [ "$pod_name" != "" ]; then
            break
        fi
        sleep 1
        i=$((i + 1))
    done
    printf "%s" "$pod_name"
}

wait_for_pod() {
    set +e
    desired_status=${2:-'Running'}
    is_pod_in_desired_status=false
    i=1
    while [ "$i" -ne 30 ]
    do
        pod_status="$(kubectl get pod "$1" -o jsonpath='{.status.phase}')"
        if [ "$pod_status" = "$desired_status" ]; then
            is_pod_in_desired_status=true
            printf "pod %s is %s\n" "$1" "$desired_status"
            break
        fi

        printf "Waiting for pod %s to be %s\n" "$1" "$desired_status"
        sleep 3
        i=$((i + 1))
    done
    if [ $is_pod_in_desired_status = "false" ]; then
        printf "pod %s does not transition to %s within 1 minute 30 seconds\n" "$1" "$desired_status"
        kubectl get pods
        kubectl describe pod "$1"
        kubectl logs "$1"
        exit 1
    fi
    set -e
}

finish() {
    printf "calling cleanup function\n"
    kubectl delete -f manifests/ || true
}

# build container
(
    cd ..
    make build-container-e2e
    cd -
)

trap finish EXIT

kubectl create -f manifests/webhook.yaml
# add imagePullPolicy=Never in the manifest.
awk '/image: / { print; print "        imagePullPolicy: Never"; next }1' manifests/cert-manager-job.yaml | kubectl create -f -

label="job-name=${JOB_NAME}"
job_pod_name=$(get_pod_name_by_label "$label")
if [ "$job_pod_name" = '' ]; then
    printf 'pod with label %s not found\n' "$label"
    kubectl describe job $JOB_NAME
    exit 1
fi
wait_for_pod "$job_pod_name" "Succeeded"

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
