#!bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CB_PATH="/opt/cb-manager/"

if [ "$1" == "cb-manager" ]; then
	echo "$1 - Update repo"
	rm -f "$HOME/log/checkout-*.*" "$HOME/log/pull-*.*" "$HOME/log/screen-ls.png"

	cd "$CB_PATH"
	git checkout '*' > "$HOME/log/checkout-out.log" 2> "$HOME/log/checkout-err.log"
	git pull > "$HOME/log/pull-out.log" 2> "$HOME/log/pull-err.log"

	ACTIONS="checkout pull"
	MODE="out err"

	for action in $ACTIONS; do
		for mode in $MODE; do
			echo $action $mode

			CONTENT="$(cat $HOME/log/${action}-${mode}.log)"
			if [ ! -z "$CONTENT" ]; then
				location="unknown"
				[ -f "$HOME/at-azure" ] && location="azure"
				[ -f "$HOME/at-cnit_openstack" ] && location="CNIT-openstack"
				[ -f "$HOME/at-cnit_k8s" ] && location="CNIT-k8s"

				echo "Send notification via Telegram"
				bash "$HOME/$FRAMEWORK_DIR/utils/send2telegram/message.sh" "${location} ${action} - ${mode}"
				cat $HOME/log/${action}-${mode}.log | convert label:@- "$HOME/log/${action}-${mode}.png"
				bash "$HOME/$FRAMEWORK_DIR/utils/send2telegram/photo.sh" "$HOME/log/${action}-${mode}.png"
			fi
		done
	done

	echo "$1 - Restart"
	bash "$WORK_DIR/service.sh" "$1" stop
	bash "$WORK_DIR/service.sh" "$1" start

	echo "Send notification via Telegram"
	bash "$WORK_DIR/../send2telegram/message.sh" "@cnit-openstack"
	screen -ls | convert label:@- "$HOME/log/screen-ls.png"
	bash "$HOME/$FRAMEWORK_DIR/utils/send2telegram/photo.sh" "$HOME/log/screen-ls.png"
else
	echo "Error: unknown service, must be: cb-manager"
fi
