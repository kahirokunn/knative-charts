VERSION = "v1.7.1"

setup-mac:
	brew install sponge

download-all:
	$(MAKE) download-knative-serving
	$(MAKE) download-knative-serving-net-gateway-api
	$(MAKE) download-contour-gateway

download-knative-serving:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-serving/templates/download/*
	wget -P ./knative-serving/templates/download https://github.com/knative/serving/releases/download/knative-${VERSION}/serving-core.yaml

	# remove all config
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-.*") | not)' | sponge knative-serving/templates/download/serving-core.yaml
	# remove all secret
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.kind | test("Secret") | not)' | sponge knative-serving/templates/download/serving-core.yaml
	# replace namespace
	cat knative-serving/templates/download/serving-core.yaml | yq '.metadata.namespace = "{{ .Release.Namespace }}"' | sponge knative-serving/templates/download/serving-core.yaml

download-knative-serving-net-gateway-api:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-serving-net-gateway-api/templates/download/*

	# net-gateway-api
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/100-gateway-api.yaml
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/200-clusterrole.yaml
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/controller.yaml

	# replace namespace
	cat knative-serving-net-gateway-api/templates/download/controller.yaml | yq '.metadata.namespace = "{{ .Release.Namespace }}"' | sponge knative-serving-net-gateway-api/templates/download/controller.yaml
	# resolve image
	cat knative-serving-net-gateway-api/templates/download/controller.yaml | yq '.spec.template.spec.containers[0].image = "gcr.io/knative-releases/knative.dev/net-gateway-api/cmd/controller:latest"' | sponge knative-serving-net-gateway-api/templates/download/controller.yaml

download-contour-gateway:
	# https://projectcontour.io/guides/gateway-api
	# Option #2: Dynamically provisioned
	-rm -rf ./contour-gateway/templates/download/*
	wget -P ./contour-gateway/templates/download https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
