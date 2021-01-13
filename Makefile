DATASET_OPERATOR_NAMESPACE=dlf
GENERATE_ID = $(shell openssl rand -base64 6 | tr [:upper:] [:lower:])
GENERATE_TESTING_NAMESPACE = $(eval DLF_TESTING_NAMESPACE=dlf-testing-$(GENERATE_ID))

.PHONY: tests

manifests:
	helm template --namespace=$(DATASET_OPERATOR_NAMESPACE) --name-template=default chart/ > release-tools/manifests/dlf.yaml
	helm template --set global.sidecars.kubeletPath="/var/data/kubelet" --namespace=$(DATASET_OPERATOR_NAMESPACE) --name-template=default chart/ > release-tools/manifests/dlf-ibm-k8s.yaml
	helm template --set global.type="oc" --set global.sidecars.kubeletPath="/var/data/kubelet" --namespace=$(DATASET_OPERATOR_NAMESPACE) --name-template=default chart/ > release-tools/manifests/dlf-ibm-oc.yaml
	helm template --set global.type="oc" --namespace=$(DATASET_OPERATOR_NAMESPACE) --name-template=default chart/ > release-tools/manifests/dlf-oc.yaml
undeployment:
	kubectl delete -f ./release-tools/manifests/dlf.yaml
	kubectl label namespace default monitor-pods-datasets-
deployment:
	kubectl apply -f ./release-tools/manifests/dlf.yaml
	kubectl label namespace default monitor-pods-datasets=enabled
tests:
	$(GENERATE_TESTING_NAMESPACE)
	@kubectl create namespace $(DLF_TESTING_NAMESPACE)
	@kubectl apply -f ./examples/minio/ -n $(DLF_TESTING_NAMESPACE)
	@export DLF_TESTING_NAMESPACE=$(DLF_TESTING_NAMESPACE) && pipenv run pytest -s . --kube-config ~/.kube/config
	@kubectl delete -f ./examples/minio/ -n $(DLF_TESTING_NAMESPACE)
	@kubectl delete namespace $(DLF_TESTING_NAMESPACE)
