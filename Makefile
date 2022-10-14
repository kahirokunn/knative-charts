VERSION = "v1.7.2"

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

download-contour-gateway:
	# https://projectcontour.io/guides/gateway-api
	# Option #2: Dynamically provisioned
	-rm -rf ./contour-gateway/templates/download/*
	wget -P ./contour-gateway/templates/download https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
