#!/bin/bash

sudo blueprint create -S -m 'create server:`hostname -s` confs' `hostname -s`
[ -e `hostname -s`.sh ] && sudo mv `hostname -s`.sh `hostname -s`

