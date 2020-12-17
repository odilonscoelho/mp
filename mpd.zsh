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
				declare -x statusx="start"
				start &>/dev/null & ;;
			BASEPL )
				return 0
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
		[[ $? -ne 5 ]] && 
			{ 
				declare -x statusx="restart"; interval 
			} || \
				{
					mp -stop
					polybar-msg hook mpv 1
				}
	done
}
backend ()  # 
{
	if sock.ativo; then
		if [[ ${statusx} == "start" ]]; then
			declare -x scopeold="$(playlist)"
			basepl force
			# poly.title > /tmp/mpinfo
			polybar-msg hook mpv 1
			dstfy "$(tracks) Files Add
			Play $(title)"
		else
			if [[ "$scopeold" != "$(playlist)" ]]; then
				if [[ $(wc -c <<< "$scopeold") != "$(playlist |wc -c)" ]]; then
					basepl event &&
					# poly.title > /tmp/mpinfo
					polybar-msg hook mpv 1
					declare -x scopeold="$(playlist)"
				else
					# poly.title > /tmp/mpinfo
					polybar-msg hook mpv 1
					dstfy "$(tracks) Files loaded"
					declare -x scopeold="$(playlist)"
				fi
			fi
		fi
	else
		mp -stop
		# poly.title > /tmp/mpinfo
		polybar-msg hook mpv 1
		dstfy "mp sock stoped"
		exit 5
	fi
}

basepl ()  
{
	[[ -n $@ ]] && \
		{
			case "$@" in
				force || event )
					< $mpurls > $mpurlsold
					loaded url > $mpurls;;
				* ) return 0;;
			esac
			
			fmpurlold=$(wc -l < $mpurlsold|grep -Ev '^$')
			fmpurl=$(wc -l < $mpurls|grep -Ev '^$')

			case "$@" in
				force )
				    : > $mptitles
				    j=1
				    while read line; do
						filename="$line"
						if [[ -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
							title=$(echo "$line" |sed 's/.*\///g;s/\///g')
						elif [[ -e "$filename" && "$filename" =~ ".m3u" ]]; then
							title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
						else
							titlepl="$(loaded title $j)"
							if [[ "$titlepl" == "null" || -z "$titlepl" ]]; then
								title="$(get.title "$filename")"
								[[ -z $title ]] && title="$filename"
							else
								title="$titlepl"
							fi
						fi
						print $title >> $mptitles
						print "$j\n$title" >> $mplistyad
						j=$((j+1))
				    done < $mpurls
				    dstfy "$(printf %b "$(tracks) -Files Add/Loaded\nPlaying -> $(trackget) $(sed -n ''$(trackget)'p' $mptitles)")";;
				event )
				    if [[ $fmpurl -gt $fmpurlold ]]; then
						for (( i=$(( $fmpurlold + 1 )); i<=$fmpurl; i++ ))
						{
							filename=$(loaded url $i)
							if [[ -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
								title=$(echo "$filename" |sed 's/.*\///g;s/\///g')
							elif [[ -e "$filename" && "$filename" =~ ".m3u" ]]; then
								title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
							else
								titlepl="$(loaded title $i)"
								if [[ "$titlepl" == "null" || -z "$titlepl" ]]; then
									title="$(get.title "$filename")"
									[[ -z $title ]] && title="$filename"
								else
									title="$titlepl"
								fi
							fi
							print $title >> $mptitles
							print "$j\n$title" >> $mplistyad
						}
						dstfy "$(printf %b "$(tracks) $title ...Loaded\nPlaying -> $(trackget) $(sed -n ''$(trackget)'p' $mptitles)")"
				    else
						return 0
				    fi;;
				   * ) 
						return 0 ;;
			esac		
		} || \
			{
				return 0
			}
}
