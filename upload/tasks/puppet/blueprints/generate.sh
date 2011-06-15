#!/bin/bash

sudo blueprint create -P -m 'create server:`hostname -s` confs' `hostname -s`

