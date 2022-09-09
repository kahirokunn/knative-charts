VERSION = "v1.7.1"

download-knative-serving:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-serving/templates/*
	wget -P ./knative-serving/templates https://github.com/knative/serving/releases/download/knative-${VERSION}/serving-core.yaml

	# remove config-domain and config-network
	cat knative-serving/templates/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-domain|config-network") | not)' > knative-serving/templates/serving-core2.yaml
	mv knative-serving/templates/serving-core2.yaml knative-serving/templates/serving-core.yaml

download-knative-serving-net-gateway-api:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-serving-net-gateway-api/templates/download/*

	# net-gateway-api
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/100-gateway-api.yaml
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/200-clusterrole.yaml
	wget -P ./knative-serving-net-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/controller.yaml
