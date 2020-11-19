#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

FRAMEWORK_DIR=astrid-framework

#--------------------------------------------------

rm -f $HOME/log/checkout-*.* $HOME/log/pull-*.*

cd "$HOME/$FRAMEWORK_DIR"
git checkout "*" > "$HOME/log/checkout-out.log" 2> "$HOME/log/checkout-err.log"
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
			cat "$HOME/log/${action}-${mode}.log" | convert -extent 200x200 -gravity center label:@- "$HOME/log/${action}-${mode}.png"
			bash "$HOME/$FRAMEWORK_DIR/utils/send2telegram/photo.sh" "$HOME/log/${action}-${mode}.png" "{${location}} [astrid-framework] (${action} - ${mode})"
		fi
		echo -e "\n"
	done
done
