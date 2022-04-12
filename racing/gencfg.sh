#!/bin/sh
# generate map rotation for racing server from files list in folder and update server

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
		if [ -r "./${line}.count" ]; then
			local count
			count=`cat "${line}.count"`
			local i
			i=0
			while [ $i -lt $count ]; do
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
	echo 'maprotation "1" [' > /tmp/_rot.cfg
	ls -A1 | mapsfilter | multicount | sauerstrfilter | sed -r 's/.*/	\"&\"/' >> /tmp/_rot.cfg
	echo ']' >> /tmp/_rot.cfg
}

gentestcfg ()
{
	echo 'maprotation "1" [' > /tmp/_rot.cfg
	ls -A1 | mapsfilter | sauerstrfilter | sed -r 's/.*/	\"&\"/' >> /tmp/_rot.cfg
	echo ']' >> /tmp/_rot.cfg
}

checkserv ()
{
	if ! cmp -s rot.cfg /tmp/_rot.cfg; then
		cp -f /tmp/_rot.cfg rot.cfg.new
		mv -f rot.cfg.new rot.cfg
		#chown root:root rot.cfg
		chmod 0644 rot.cfg
		#killall -q -USR1 $1
		svc -h "$1"
	fi
}

cleanup ()
{
	rm -f /tmp/_rot.cfg
}

#cd ~ftp/racing/testing
#gentestcfg
#checkserv sauer_testracing

cd /racing/maps
gencfg
checkserv /home/zero/sv/racing-srv

cleanup
