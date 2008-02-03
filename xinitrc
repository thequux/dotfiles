#!/bin/sh
export PATH="$HOME/bin:$PATH"
xmodmap ~/.Xmodmaprc
function first_executable() {
    for x in "$@"; do
	if command which "$x" &>/dev/null; then
	    echo "$x"
	    return 1;
	fi
    done
}
vvvvvvvvvvvvvvvvvvvv

case `hostname -f` in
    peewee.dorm-thequux.com)
	xbattbar &
	[ -d "/usr/share/fonts/X11/genera/" ] && xset fp+ "/usr/share/fonts/X11/genera/"
	socat -U SYSTEM:"dzen2 -fn genera-jess14",end-close UNIX-LISTEN:"$HOME/.xmonad/dzen2-${DISPLAY//:/\\:}",reuseaddr,fork &
	xbattbar-acpi &
	xscreensaver -no-splash &
	WM=xmonad
	;;
    krogoth.dorm-thequux.com)
	WM=xmonad
	;;
    *)
	WM="`first_executable xmonad ion3 fluxbox twm`"
	;;
esac
	
$WM
^^^^^^^^^^^^^^^^^^^^

exec xterm
#exec startxfce4
