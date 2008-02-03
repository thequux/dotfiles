#!/bin/sh
export PATH="$HOME/bin:$PATH"
xmodmap ~/.Xmodmaprc
xmonad
exec xterm
#exec startxfce4
