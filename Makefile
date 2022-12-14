KNATIVE_OPERATOR_VERSION = "v1.8.0"
KNATIVE_SERVING_VERSION = "v1.8.0"
CONTOUR_OPERATOR_VERSION = "v1.23.0"

setup-mac:
	brew install sponge

download-all:
	$(MAKE) download-knative-serving
	$(MAKE) download-knative-serving-net-gateway-api
	$(MAKE) download-contour-gateway
	$(MAKE) download-knative-operator

download-knative-serving:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	-rm -rf ./knative-serving/templates/download/*
	wget -P ./knative-serving/templates/download https://github.com/knative/serving/releases/download/knative-${KNATIVE_SERVING_VERSION}/serving-core.yaml

	$(MAKE) update-knative-serving-values

	# remove all config
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-.*") | not)' | sponge knative-serving/templates/download/serving-core.yaml
	# remove all secret
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.kind | test("Secret") | not)' | sponge knative-serving/templates/download/serving-core.yaml
	# replace namespace
	cat knative-serving/templates/download/serving-core.yaml | yq '.metadata.namespace = "{{ .Release.Namespace }}"' | sponge knative-serving/templates/download/serving-core.yaml

update-knative-serving-values:
	# update config-deployment
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-deployment")) | { "configDeployment": .data }' > config-deployment.yaml
	yq '*. load("knative-serving/values.yaml")' config-deployment.yaml | sponge knative-serving/values.yaml
	rm config-deployment.yaml

	# update config-autoscaler
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-autoscaler")) | { "configAutoscaler": .data }' > config-autoscaler.yaml
	yq '*. load("knative-serving/values.yaml")' config-autoscaler.yaml | sponge knative-serving/values.yaml
	rm config-autoscaler.yaml

	# update config-defaults
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-defaults")) | { "configDefaults": .data }' > config-defaults.yaml
	yq '*. load("knative-serving/values.yaml")' config-defaults.yaml | sponge knative-serving/values.yaml
	rm config-defaults.yaml

	# update config-gc
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-gc")) | { "configGc": .data }' > config-gc.yaml
	yq '*. load("knative-serving/values.yaml")' config-gc.yaml | sponge knative-serving/values.yaml
	rm config-gc.yaml

	# update config-leader-election
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-leader-election")) | { "configLeaderElection": .data }' > config-leader-election.yaml
	yq '*. load("knative-serving/values.yaml")' config-leader-election.yaml | sponge knative-serving/values.yaml
	rm config-leader-election.yaml

	# update config-logging
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-logging")) | { "configLogging": .data }' > config-logging.yaml
	yq '*. load("knative-serving/values.yaml")' config-logging.yaml | sponge knative-serving/values.yaml
	rm config-logging.yaml

	# update config-observability
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-observability")) | { "configObservability": .data }' > config-observability.yaml
	yq '*. load("knative-serving/values.yaml")' config-observability.yaml | sponge knative-serving/values.yaml
	rm config-observability.yaml

	# update config-tracing
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-tracing")) | { "configTracing": .data }' > config-tracing.yaml
	yq '*. load("knative-serving/values.yaml")' config-tracing.yaml | sponge knative-serving/values.yaml

	# update config-features
	cat knative-serving/templates/download/serving-core.yaml | yq eval '. | select(.metadata.name | test("config-features")) | { "configFeatures": .data }' > config-features.yaml
	yq '*. load("knative-serving/values.yaml")' config-features.yaml | sponge knative-serving/values.yaml
	rm config-features.yaml

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

download-grpc-web-gateway:
	# https://github.com/knative-sandbox/net-gateway-api#contour
	-rm -rf ./grpc-web-gateway/templates/download/*
	wget -P ./grpc-web-gateway/templates/download https://raw.githubusercontent.com/projectcontour/contour-operator/${CONTOUR_OPERATOR_VERSION}/examples/operator/operator.yaml

	# replace namespace
	gsed -z "s/namespace: contour-operator\n/namespace: {{ .Values.contourOperator.namespace }}\n/g" grpc-web-gateway/templates/download/operator.yaml | sponge grpc-web-gateway/templates/download/operator.yaml

download-contour-gateway:
	# https://github.com/knative-sandbox/net-gateway-api#contour
	-rm -rf ./contour-gateway/templates/download/*
	wget -P ./contour-gateway/templates/download https://raw.githubusercontent.com/projectcontour/contour-operator/${CONTOUR_OPERATOR_VERSION}/examples/operator/operator.yaml

	git clone https://github.com/knative-sandbox/net-gateway-api.git net-gateway-api-tmp
	ko resolve -f net-gateway-api-tmp/third_party/contour/gateway/ | sed 's/LoadBalancerService/NodePortService/g' > contour-gateway/templates/download/gateway.yaml
	rm -rf net-gateway-api-tmp

	# net-gateway-api
	wget -P ./contour-gateway/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/100-gateway-api.yaml
	wget -P ./contour-gateway/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/200-clusterrole.yaml
	wget -P ./contour-gateway/templates/download https://raw.githubusercontent.com/knative-sandbox/net-gateway-api/main/config/controller.yaml

	# resolve image
	cat contour-gateway/templates/download/controller.yaml | yq '.spec.template.spec.containers[0].image = "gcr.io/knative-releases/knative.dev/net-gateway-api/cmd/controller:latest"' | sponge contour-gateway/templates/download/controller.yaml

download-knative-operator:
	# https://github.com/knative-sandbox/net-gateway-api#contour
	-rm ./knative-operator/operator/*
	wget -P ./knative-operator/operator https://github.com/knative/operator/releases/download/knative-${KNATIVE_SERVING_VERSION}/operator.yaml
	cat knative-operator/operator/operator.yaml | sed 's/namespace: default/namespace: knative-operator/g' | sponge knative-operator/operator/operator.yaml
