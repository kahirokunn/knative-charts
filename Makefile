update:
	# https://knative.dev/docs/install/operator/knative-with-operators/#install-the-knative-operator
	curl https://github.com/knative/operator/releases/download/knative-v1.6.0/operator.yaml -L -o ./default-knative-operator/operator.yaml

download:
	# https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml
	# Knative Serving
	rm ./knative-standard/*
	wget -P ./knative-standard https://github.com/knative/serving/releases/download/knative-v1.6.0/serving-core.yaml

	# Install a networking layer
	wget -P ./knative-standard https://github.com/knative/net-istio/releases/download/knative-v1.6.0/istio.yaml
	wget -P ./knative-standard https://github.com/knative/net-istio/releases/download/knative-v1.6.0/net-istio.yaml

	# https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml
	# Knative Eventing
	wget -P ./knative-standard https://github.com/knative/eventing/releases/download/knative-v1.6.0/eventing-core.yaml

	# Install a multi-tenant GitHub source run the command
	wget -P ./knative-standard https://github.com/knative-sandbox/eventing-github/releases/download/knative-v1.6.0/mt-github.yaml
