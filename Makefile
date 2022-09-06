VERSION = "v1.7.1"

update:
	# https://knative.dev/docs/install/operator/knative-with-operators/#install-the-knative-operator
	curl https://github.com/knative/operator/releases/download/knative-${VERSION}/operator.yaml -L -o ./default-knative-operator/operator.yaml

download:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm ./knative-standard/*
	wget -P ./knative-standard https://github.com/knative/serving/releases/download/knative-${VERSION}/serving-core.yaml

	# Install a networking layer
	wget -P ./knative-standard https://github.com/knative/net-istio/releases/download/knative-${VERSION}/istio.yaml
	wget -P ./knative-standard https://github.com/knative/net-istio/releases/download/knative-${VERSION}/net-istio.yaml

	# https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml
	# Knative Eventing
	wget -P ./knative-standard https://github.com/knative/eventing/releases/download/knative-${VERSION}/eventing-core.yaml

	# Install a multi-tenant GitHub source run the command
	wget -P ./knative-standard https://github.com/knative-sandbox/eventing-github/releases/download/knative-${VERSION}/mt-github.yaml

download-knative-gateway-api:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-gateway-api/templates/download/*
	wget -P ./knative-gateway-api/templates/download https://github.com/knative/serving/releases/download/knative-${VERSION}/serving-core.yaml

	# net-gateway-api
	wget -P ./knative-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/100-gateway-api.yaml
	wget -P ./knative-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/200-clusterrole.yaml
	wget -P ./knative-gateway-api/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/controller.yaml

	# remove config-domain and config-network
	cat knative-gateway-api/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name != "config-domain") | select(.metadata.name != "config-network")' > knative-gateway-api/templates/download/serving-core2.yaml
	mv knative-gateway-api/templates/download/serving-core2.yaml knative-gateway-api/templates/download/serving-core.yaml
