#!/bin/bash

# Deploy a ConfigMap that has a config property
# that is the contents of the KUBECONFIG file.
# This is handled by kustomize, which deploys
# the ConfigMap to the 'fragmentor' namespace.

if ! test -f ${KUBECONFIG}; then
  echo "KUBECONFIG file (${KUBECONFIG}) does not exist."
fi

cp ${KUBECONFIG} ./kustomization/config
echo "The generated KUBECONFIG ConfigMap: -"
echo
kubectl kustomize kustomization

echo
echo "Do you wish to deploy this KUBECONFIG configuration?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "Deploying..."
kubectl apply -k kustomization

rm ./kustomization/config
