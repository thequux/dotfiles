# Development for tal.es; source is in ~/Projects/tales

case "$1" in
    enable)
	export GOPATH=$HOME/Projects/tales
	;;
    disable)
	unset GOPATH
	;;
esac
