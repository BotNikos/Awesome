#!/bin/bash

sh ~/Wallpapers/imageSetter.sh
/usr/bin/setxkbmap -option "ctrl:nocaps"
/usr/bin/emacs --daemon

killall compfy
compfy --daemon
