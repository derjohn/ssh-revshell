help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install: ## Installs and enabled the systemd service and the config file in /etc/revshell
	sudo cp -p revshell.sh /usr/local/sbin
	sudo cp -p systemd-unit-service-reverseshell /lib/systemd/system/revshell.service
	sudo cp -p etc-revshell /etc/revshell
	sudo systemctl daemon-reload
	sudo systemctl enable --now revshell.service

