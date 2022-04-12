#!/bin/sh
# generate map rotation for racing server from files list in folder and update server

USAGE="Usage: $0 [-m] [workdir] [notifyscript]"

MULTICOUNT=0
WORKDIR='.'
SCRIPT=''

if [ x"$1" = x"-h" -o x"$1" = x"--help" ]
then
	printf "%s\n" "$USAGE"
	exit
fi

if [ x"$1" = x"-m" ]
then
	MULTICOUNT=1
	shift
fi

if [ -n "$1" ]
then
	WORKDIR="$1"
	shift
fi

if [ -n "$1" ]
then
	SCRIPT="$1"
	shift
fi

ROTFILE="$WORKDIR/rot.cfg"
TMPFILE=`mktemp`

mapsfilter ()
{
	grep '^[][_'"'"'"`~!?@#$%^&*()=+{},.a-zA-Z0-9:;| -]\+\.ogz$' | sed -r 's/\.ogz$//'
}

sauerstrfilter ()
{
	sed -e 's/\^/\^\^/g' | sed -e 's/"/\^"/g'
}

multicount ()
{
	while read -r line; do
		if [ -r "$WORKDIR/${line}.count" ]; then
			local count
			count=`cat "$WORKDIR/${line}.count"`
			[ -z "$count" ] && count=1
			local i
			i=0
			while [ $i -lt "$count" ]; do
				printf "%s\n" "$line"
				i=`expr $i + 1`
			done
		else
			printf "%s\n" "$line"
		fi
	done
}

gencfg ()
{
	echo 'maprotation "1" [' > "$TMPFILE"
	if [ $MULTICOUNT -eq 1 ]
	then
		ls -A1 -- "$WORKDIR" | mapsfilter | multicount | sauerstrfilter | sed -r 's/.*/	\"&\"/' >> "$TMPFILE"
	else
		ls -A1 -- "$WORKDIR" | mapsfilter | sauerstrfilter | sed -r 's/.*/	\"&\"/' >> "$TMPFILE"
	fi
	echo ']' >> "$TMPFILE"
}

checkserv ()
{
	if ! cmp -s "$ROTFILE" "$TMPFILE"
	then
		cp -f "$TMPFILE" "$ROTFILE.new"
		rm -f "$TMPFILE"
		chmod 0644 "$ROTFILE.new"
		mv -f "$ROTFILE.new" "$ROTFILE"
		[ -n "$SCRIPT" ] && eval "$SCRIPT"
	else
		rm -f "$TMPFILE"
	fi
}

gencfg
checkserv
