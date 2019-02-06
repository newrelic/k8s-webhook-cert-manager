#!/usr/bin/env sh
# This file is a copy of https://github.com/newrelic/k8s-metadata-injection/blob/master/e2e-tests/k8s-e2e-bootstraping.sh

E2E_KUBERNETES_VERSION=${E2E_E2E_KUBERNETES_VERSION:-v1.10.0}
E2E_MINIKUBE_VERSION=${E2E_E2E_MINIKUBE_VERSION:-v0.33.1}
E2E_SETUP_MINIKUBE=${E2E_SETUP_MINIKUBE:-}
E2E_SETUP_KUBECTL=${E2E_SETUP_KUBECTL:-}
E2E_START_MINIKUBE=${E2E_START_MINIKUBE:-}
E2E_MINIKUBE_DRIVER=${E2E_MINIKUBE_DRIVER:-virtualbox}
E2E_SUDO=${E2E_SUDO:-}

setup_minikube() {
    curl -sLo minikube https://storage.googleapis.com/minikube/releases/"$E2E_MINIKUBE_VERSION"/minikube-linux-amd64 \
        && chmod +x minikube \
        && $E2E_SUDO mv minikube /usr/local/bin/
}

setup_kubectl() {
    curl -sLo kubectl https://storage.googleapis.com/kubernetes-release/release/"$E2E_KUBERNETES_VERSION"/bin/linux/amd64/kubectl \
        && chmod +x kubectl \
        && $E2E_SUDO mv kubectl /usr/local/bin/
}

start_minikube() {
    $E2E_SUDO minikube start --vm-driver="$E2E_MINIKUBE_DRIVER" --bootstrapper=kubeadm --kubernetes-version="$E2E_KUBERNETES_VERSION" --logtostderr
}

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
        exit 1
    fi
    set -e
}

### Bootstraping

cd "$(dirname "$0")"

[ -n "$E2E_SETUP_MINIKUBE" ] && setup_minikube

minikube version

[ -n "$E2E_SETUP_KUBECTL" ] && setup_kubectl

export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir "$HOME"/.kube || true
touch "$HOME"/.kube/config
export KUBECONFIG=$HOME/.kube/config

[ -n "$E2E_START_MINIKUBE" ] && start_minikube

minikube update-context

is_kube_running="false"

set +e
# this for loop waits until kubectl can access the api server that Minikube has created
i=1
while [ "$i" -ne 90 ] # timeout for 3 minutes
do
   kubectl get po 1>/dev/null 2>&1
   if [ $? -ne 1 ]; then
      is_kube_running="true"
      break
   fi

   printf "waiting for Kubernetes cluster up\n"
   sleep 2
   i=$((i + 1))
done

if [ $is_kube_running = "false" ]; then
   minikube logs
   printf "Kubernetes did not start within 3 minutes. Something went wrong.\n"
   exit 1
fi
set -e

kubectl version
