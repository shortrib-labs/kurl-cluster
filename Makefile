tfvars=${SECRETS_DIR}/terrform.tfvars
params_yaml=${SECRETS_DIR}/params.yaml

hostname := $(shell yq .hostname $(params_yaml))
kurl_script := curl https://kurl.sh/latest | sudo bash

define TFVARS
hostname	       = "$(hostname)"
domain					 = "$(shell yq e .domain $(params_yaml))"
project_root		 = "${PROJECT_DIR}"

remote_ovf_url   = "$(shell yq .remote_ovf_url $(params_yaml))"

ssh_authorized_keys = $(shell yq --output-format json .ssh.authorized_keys $(params_yaml))

vsphere_server	 = "$(shell yq .vsphere.server $(params_yaml))"
vsphere_username = "$(shell yq .vsphere.username $(params_yaml))"
vsphere_password = "$(shell yq .vsphere.password $(params_yaml))"

vsphere_datacenter    = "$(shell yq .vsphere.datacenter $(params_yaml))"
vsphere_cluster				= "$(shell yq .vsphere.cluster $(params_yaml))"
vsphere_host				  = "$(shell yq .vsphere.host $(params_yaml))"
vsphere_resource_pool = "$(shell yq .vsphere.resource_pool $(params_yaml))"

vsphere_network				 = "$(shell yq .vsphere.network $(params_yaml))"
vsphere_datastore			 = "$(shell yq .vsphere.datastore $(params_yaml))"

vsphere_folder	       = "$(shell yq .vsphere.folder $(params_yaml))"

kurl_script = "$(kurl_script)"
endef

.PHONY: tfvars
tfvars: $(tfvars)

export TFVARS
$(tfvars): $(params_yaml)
	echo "$$TFVARS" > $@

.PHONY: node
node: create

.PHONY: create
create: $(tfvars)
	(cd ${SOURCE_DIR}/terraform && terraform apply -var-file $(tfvars) --auto-approve)

.PHONY: test
test: $(tfvars)
	(cd ${SOURCE_DIR}/terraform && terraform plan -var-file $(tfvars))

.PHONY: destroy
destroy: $(tfvars)
	(cd ${SOURCE_DIR}/terraform && terraform destroy -var-file $(tfvars) --auto-approve)

.PHONY: encrypt
encrypt: 
	secrets encrypt --all

.PHONY: decrypt
decrypt: 
	secrets decrypt --all
