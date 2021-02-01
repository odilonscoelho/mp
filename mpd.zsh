#!/bin/zsh
mpd.pids ()  #
{
	case $@ in
		MPD )
			ps aux|grep '[m]p \-mpd' |awk '{print $2}' ;;
		BASEPL )
			ps aux|grep '[m]p basepl force' |awk '{print $2}' ;;
	esac
}
mpd ()
{
	case $@ in
		start )
			interval
			val "MPD";;
		stop )
			kill "${(f)$(mpd.pids 'MPD')[@]}";;
		* )
			msg "Options:
			mp -mpd start
			mp -mpd stop";;
	esac
}
val ()  #
{
	case ${#$(get.socks)} in
		0 ) limit=3 ;;
		1 ) limit=3 ;;
		2 ) limit=5 ;;
		3 ) limit=6 ;;
		4 ) limit=7 ;;
	esac

	if [[ $(wc -l <<< `mpd.pids "$@"`) -le $limit ]];then
		case $@ in
			MPD )
				statusx="start"
				start &>/tmp/mplog &
				exit 0;;
			BASEPL )
				return 0;;
		esac
	else
		case $@ in
			MPD )
				exit 0 ;;
			BASEPL )
				dstfy "$@ RECHAÇADA!!!"
				return 1 ;;
		esac
	fi
}
start ()  #
{
	while true; do
		backend
		[[ $? -ne 5 ]] && \
			{
				interval &&
			} || \
				{
					polymsg.command &>/dev/null
					icon=""
					dstfy "mp sock stoped"
					break
				}
	done
	exit 0
}

backend ()  #
{
	if sock.ativo; then
		if [[ ${statusx} == "start" ]]; then
			statusx="running"
			current_track=$(trackget)
			number_of_tracks=$(tracks)
			basepl force
			scopeold=$(playlist)
			[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
			[[ $get_thumb == "true" ]] && get.thumb $current_track
			[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
		else
			scopenew=$(playlist)
			if [[ $scopeold != $scopenew ]]; then
				local current_track_new=$(trackget)
				local number_of_tracks_new=$(tracks)
				if [[ $number_of_tracks -lt $number_of_tracks_new ]];then
					basepl
					number_of_tracks=$number_of_tracks_new
			        [[ $polymsg == "true" ]] && polymsg.command &>/dev/null
				elif [[ $current_track != $current_track_new ]];then
					polybar-msg hook mpv 1 &>/dev/null
					current_track=$current_track_new
					[[ $get_thumb == "true" ]] && get.thumb $current_track
			        [[ $polymsg == "true" ]] && polymsg.command &>/dev/null
				elif [[ $(print $scopenew |sed 's/,/\n/g'|grep '"playing":true') ]];then
					[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
				fi
				scopeold=$scopenew
			fi
		fi
	else
		interval &&
		if sock.ativo; then; backend; { [[ $polymsg == "true" ]] && polymsg.command &>/dev/null }; else; return 5; fi
	fi
}

basepl () #
{
	if [[ $@ == "force" ]]; then
	    : > $mpurls
	    for media in ${(f)"$(loadedx)"}
	    {
	    	[[ ${#${(s:|:)media}} -eq 3 ]] && \
	    		{
	    			print $media >> $mpurls 
	    		} || \
	    			{
	    				filename=${${(s:|:)media}[2]}
	    				if [[ -e "~/$filename" || -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
							title=$(echo "$filename" |sed 's/.*\///g;s/\///g;s/\..*$//g')
						elif [[ -e "~/$filename" || -e "$filename" && "$filename" =~ ".m3u" ]]; then
							title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g;s/\..*$//g')
						else
							title="$(get.title "$filename")"
							[[ -z $title ]] && title=$(print "$filename" |sed 's/.*\///g;s/\///g;s/\..*$//g')
						fi
						print "$media|$title" >> $mpurls
	    			}
	    }	
	else
		for (( i=$(( $number_of_tracks + 1 )); i<=$number_of_tracks_new; i++ ))
		{					
			[[ ${#${(s:|:)$(loadedx $i)}} -eq 3 ]] && \
	    		{
	    			loadedx $i >> $mpurls
	    		} || \
						{
							filename=${${(s:|:)$(loadedx $i)}[2]}
							if [[ -e "~/$filename" || -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
								title=$(echo "$filename" |sed 's/.*\///g;s/\///g;s/\..*$//g')
							elif [[ -e "~/$filename" || -e "$filename" && "$filename" =~ ".m3u" ]]; then
								title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g;s/\..*$//g')
							else
								title="$(get.title "$filename")"
								[[ -z $title ]] && title=$(print "$filename" |sed 's/.*\///g;s/\///g;s/\..*$//g')
							fi
							print "$(loadedx $i)|$title" >> $mpurls
						}
		}
	fi
}
