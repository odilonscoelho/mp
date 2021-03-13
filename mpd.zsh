#!/bin/zsh
mpd.pids ()  #
{
	case $@ in
		MPD )
			ps aux |grep -E '\/bin\/zsh.*mp$' | awk '{print $2}';;
		BASEPL )
			ps aux|grep '[m]p basepl force' |awk '{print $2}' ;;
	esac
}
mpd ()
{
	case $@ in
		start )
			interval
			if [[ -e /tmp/mpid ]]; then
    		    return 0
    		else
                statusx="start"
    			start & 
    			print "$!" > /tmp/mpid
			fi;;
			# val "MPD";;
		stop )
            kill $(< /tmp/mpid)
			kill "${(f)$(mpd.pids 'MPD')[@]}";;
		* )
			msg "Options:
			mp -mpd start
			mp -mpd stop";;
	esac
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
					rm -f /tmp/mpid 2>/dev/null
					break
				}
	done
	exit 0
}

backend.m3u ()
{
    loadedx > $mpurls 
}

backend ()  #
{
	if sock.ativo; then
		if [[ ${statusx} == "start" ]]; then
			statusx="running"
			current_track=$(trackget)
			number_of_tracks=$(tracks)
            #[[ -n $m3us ]] && {  backend.m3u } || { basepl force }
            basepl force
			scopeold=$(playlist |xargs -0)
			[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
			[[ $get_thumb == "true" ]] && get.thumb $current_track
			[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
		else
			scopenew=$(playlist |xargs -0)
			if [[ $scopeold != $scopenew ]]; then
				current_track_new=$(trackget)
				number_of_tracks_new=$(tracks)
				# Adicionou faixa:
				if [[ $number_of_tracks -lt $number_of_tracks_new ]];then
					basepl
					number_of_tracks=$number_of_tracks_new
			        [[ $polymsg == "true" ]] && polymsg.command &>/dev/null
			    # Removeu faixa:
				elif [[ $number_of_tracks -gt $number_of_tracks_new ]];then
				    basepl force
   					current_track=$current_track_new
   					number_of_tracks=$number_of_tracks_new
                    [[ $polymsg == "true" ]] && polymsg.command &>/dev/null
				# Apenas alterou a faixa em execução:
				elif [[ $number_of_tracks -eq $number_of_tracks_new && $current_track != $current_track_new ]];then
					[[ $polymsg == "true" ]] && polymsg.command &>/dev/null 
					current_track=$current_track_new
					[[ $get_thumb == "true" ]] && get.thumb $current_track
			        [[ $polymsg == "true" ]] && polymsg.command &>/dev/null
			    # O player foi pausado
				elif [[ $(print $scopenew |sed 's/,/\n/g'|grep '"playing":true') ]];then
					[[ $polymsg == "true" ]] && polymsg.command &>/dev/null
				fi
				scopeold=$scopenew
			fi
		fi
	else
		interval
		if sock.ativo; then
		    backend
        else
		    polymsg.command &>/dev/null
            return 5
        fi
	fi
}

basepl () #
{
	if [[ $@ == "force" ]]; then
	    cp $mpurls $mpurlsold
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
						    { grep -q $filename $mpurlsold } && title=${${(s:|:)$(grep $filename $mpurlsold)}[3]} || title="$(get.title "$filename")"
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
