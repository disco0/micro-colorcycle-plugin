#!/usr/bin/env zsh 
script_path=${0:a:h}

MICRO_PLUGIN_PATH=${MICRO_PLUGIN_PATH-${HOME}/.config/micro/plugins}

[[ -d $MICRO_PLUGIN_PATH ]] && ln -s $script_path/colorcycle $MICRO_PLUGIN_PATH