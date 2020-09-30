#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
mpd.pids ()
{
	case $@ in
		MPD )
			ps aux|grep '[m]p mpd' |awk '{print $2}' ;;
		BASEPL )
			ps aux|grep '[m]p basepl force' |awk '{print $2}' ;;
	esac
}
mpd ()
{
	case $@ in
		start )
			sock
			interval
			val "MPD";;
		stop )
			kill "${(f)$(mpd.pids 'MPD')[@]}";;
		* )
			msg "Options: 
			mp mpd start
			mp mpd stop";;
		esac
}
val ()
{
	if [[ $(wc -l <<< `mpd.pids "$@"`) -le 3 ]];then
		case $@ in
			MPD )
				declare -x statusx="start"
				start &>/dev/null & ;;
			BASEPL )
				return $(( 0 + 0 ))
		esac
	else
		case $@ in
			MPD )
				exit 0 ;;
			BASEPL )
				dstfy "$@ RECHAÇADA!!!" 
				return $(( 0 + 1 )) ;;
		esac
	fi
}
start () 
{
	while true; do
		backend
		[[ $? -ne 5 ]] && { declare -x statusx="restart"; interval } || mp clear			
	done
}
backend () 
{
	if sock.ativo; then
		if [[ ${statusx} == "start" ]]; then
			declare -x scopeold="$(playlist)"
			mp basepl force &&
			baseplyad force &&
			sleep 3 &&
			polybar-msg hook mpv 1
		else
			if [[ "$scopeold" != "$(playlist)" ]]; then
				if [[ $(wc -c <<< "$scopeold") != "$(playlist |wc -c)" ]]; then
					basepl event
					polybar-msg hook mpv 1
					baseplyad event
					declare -x scopeold="$(playlist)"
				else
					polybar-msg hook mpv 1
					declare -x scopeold="$(playlist)"
				fi
			fi
		fi
	else
		declare -x scopeold="$(playlist)"
		mp clear
		exit 5
	fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
baseplyad ()
{
	base
	case $@ in
	null ) return $(( 0 + 0 ));;
	event ) return $(( 0 + 0 ));;
	force )
	    :> $mplistyad
	    i=1
	    while read line; do
			echo "$i\n$line" >> $mplistyad
			i=$(( $i + 1 ))
	    done < $mptitles;;
	removed ) 
	 	:> $mplistyad
	    i=1
	    while read line; do
			echo "$i\n$line" >> $mplistyad
			i=$(( $i + 1 ))
	    done < $mptitles;;
	esac
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
base ()
{
	case "$@" in
		null ) return $(( 0 + 0 ));;
		force || event || ajuste )
			< $mpurls > $mpurlsold
			test.loaded url > $mpurls;;
		* ) return $(( 0 + 0 ));;
	esac
	[[ -e $mptitle ]] && return $(( 0 + 0 )) || touch $mptitles
	declare -x fmpurlold=$(wc -l < $mpurlsold|grep -Ev '^$')
	declare -x fmpurl=$(wc -l < $mpurls|grep -Ev '^$')
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
baseplloop ()
{
	[[ $(val "BASEPL") == "1" ]] && sleep 2 && baseplloop || return $(( 0 + 0 ))
}
basepl ()
{
	# baseplloop
	base $@
	case "$@" in
		null ) return $(( 0 + 0 ));;
		force )
		    :> $mptitles
		    i=0
		    j=1
		    while read line; do
				filename="$(filenameN $i)"
				if [[ -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
					title=$(echo "$line" |sed 's/.*\///g;s/\///g')
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				elif [[ -e "$filename" && "$filename" =~ ".m3u" ]]; then
					title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				else
					titlepl="$(test.loaded title $j)"
					[[ -z $titlepl ]] && titlepl="$(test.loaded title.iptv $j)"
					filenamepl="$(test.loaded url $j)"
					[[ -z $filenamepl ]] && filenamepl="$(test.loaded url.iptv $j)"
					if [[ -z "$titlepl" ]]; then
						title="$(get.title "$line")"
						[[ -z $title ]] && title=$filename
					else
						if [[ "$filenamepl" == "$filename" ]]; then
							title=$titlepl
						else
							title="Verificar filenamepl != filename"
						fi
					fi
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				fi
				i=$(( $i + 1 ))
				j=$(( $j + 1 ))
		    done < $mpurls;;
		event )
		    dstfy "EVENT PLIST"
		    if [[ $fmpurl -gt $fmpurlold ]]; then
				for (( i=$(( $fmpurlold + 1 )); i<=$fmpurl; i++ ))
				{
					filename=$(filenameN $(( $i - 1 )))
					if [[ -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
						title=$(echo "$line" |sed 's/.*\///g;s/\///g')
						echo $title >> $mptitles
						echo "$j\n$title" >> $mplistyad
					elif [[ -e "$filename" && "$filename" =~ ".m3u" ]]; then
						title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
						echo $title >> $mptitles
						echo "$j\n$title" >> $mplistyad
					else
						title=$(titleN $(( $i - 1 )))
						if [[ $title == "null" ]]; then
							titlepl=$(test.loaded title $i)
							if [[ -z "$titlepl" ]]; then
								title=$(get.title "$(< $mpurls|sed -n ''$i'p')")
								echo $title >> $mptitles
								echo "$i\n$title" >> $mplistyad
							else
								echo $titlepl >> $mptitles
								echo "$i\n$titlepl" >> $mplistyad
							fi
						else
							echo $title >> $mptitles
							echo "$i\n$title" >> $mplistyad
						fi
					fi	
				}
		    else
				return $(( 0 + 0 ))
		    fi;;
		ajuste )
		    dstfy "AJUSTANDO PLAYLIST"
		    :> $mptitles
		    i=0
		    j=1
			while read line; do
				filename=$(filenameN $i)
				if [[ -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
					title=$(echo "$line" |sed 's/.*\///g;s/\///g')
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				elif [[ -e "$filename" && "$filename" =~ ".m3u" ]]; then
					title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				else
					# titlepl=$(test.loaded title $j)
					filenamepl=$(test.loaded url $j)
					title=$(get.title $filenamepl)
					echo $title >> $mptitles
					echo "$j\n$title" >> $mplistyad
				fi
				i=$(( $i + 1 ))
				j=$(( $j + 1 ))
		    done < $mpurls;;
		   * ) return $(( 0 + 0 ));;
	esac
}
