#!/bin/sh
export PATH="$HOME/bin:$PATH"
xmodmap ~/.Xmodmaprc
xbattbar &
[ -d "/usr/share/fonts/X11/genera/" ] && xset fp+ "/usr/share/fonts/X11/genera/"
socat -U SYSTEM:"dzen2 -fn genera-jess14",end-close UNIX-LISTEN:"$HOME/.xmonad/dzen2-${DISPLAY//:/\\:}",reuseaddr,fork &
xbattbar-acpi &
xscreensaver -no-splash &
xmonad
exec xterm
#exec startxfce4
