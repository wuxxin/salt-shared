#!/bin/sh
### BEGIN INIT INFO
# Provides:          knot-{{ identity }}
# Required-Start:    $network $local_fs $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: authoritative domain name server
# Description:       Knot DNS is a authoritative-only domain name server
### END INIT INFO

# Author: Ondřej Surý <ondrej@debian.org>

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Knot DNS server {{ identity }}" # Introduce a short description here
NAME=knotd             # Introduce the short server's name here
DAEMON=/usr/sbin/$NAME # Introduce the server's location here
PIDFILE=/run/knot/knot-{{ identity }}.pid
SCRIPTNAME=/etc/init.d/knot-{{ identity }}
KNOTC=/usr/sbin/knotc

# Exit if the package is not installed
[ -x $DAEMON ] || exit 0

KNOTD_ARGS="-c /etc/knot/knot-{{ identity }}.conf"

# Read configuration variable file if it is present
[ -r /etc/default/knot-{{ identity }} ] && . /etc/default/knot-{{ identity }}

DAEMON_ARGS="-d $KNOTD_ARGS"

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started

    $KNOTC $KNOTD_ARGS status >/dev/null 2>/dev/null \
	&& return 1

    start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
	|| return 1
    start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- \
	$DAEMON_ARGS \
	|| return 2
}

#
# Function that stops the daemon/service
#
do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred

    $KNOTC $KNOTD_ARGS status >/dev/null 2>/dev/null \
	|| return 1

    $KNOTC $KNOTD_ARGS stop >/dev/null
    RETVAL="$?"
    [ $? = 1 ] && return 2

    # Many daemons don't delete their pidfiles when they exit.
    rm -f $PIDFILE
    return 0
}

do_reload() {
    $KNOTC $KNOTD_ARGS reload >/dev/null
    return $?
}

do_tmpfiles() {
    local type path mode user group age argument
    if [ -r "$1" ]; then
	if [ -x /bin/systemd-tmpfiles ]; then
	    /bin/systemd-tmpfiles --create "$1"
	else
	    while read type path mode user group age argument; do
		case "$type" in
		    d)
			mkdir -p "$path";
			chmod "$mode" "$path";
			chown "$user:$group" "$path";
			;;
		    \#*)
			;;
		    *)
			log_warning_msg "tmpfile.d type '$type' is not supported yet"
			;;
		esac
	    done < "$1"
	fi
    else
	log_warning_msg "tmpfiles.d file '$1' doesn't exist or is not readable"
    fi
}

case "$1" in
    start)
	do_tmpfiles /usr/lib/tmpfiles.d/knot.conf
	log_daemon_msg "Starting $DESC " "$NAME"
	do_start
	case "$?" in
	    0|1) log_end_msg 0 ;;
	    2) log_end_msg 1 ;;
	esac
	;;
    stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
	    0|1) log_end_msg 0 ;;
	    2) log_end_msg 1 ;;
	esac
	;;
    status)
	STATUS=$($KNOTC $KNOTD_ARGS status 2>&1 >/dev/null)
	RETVAL=$?
	if [ $RETVAL = 0 ]; then
	    log_success_msg "$NAME is running"
	else
	    log_failure_msg "$NAME is not running ($STATUS)"
	fi
	exit $RETVAL
	;;
    reload|force-reload)
	log_daemon_msg "Reloading $DESC" "$NAME"
	do_reload
	log_end_msg $?
	;;
    restart)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	    0|1)
		do_start
		case "$?" in
		    0) log_end_msg 0 ;;
		    1) log_end_msg 1 ;; # Old process is still running
		    *) log_end_msg 1 ;; # Failed to start
		esac
		;;
	    *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
    *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|reload|force-reload}" >&2
	exit 3
	;;
esac

:
