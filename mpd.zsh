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
					polybar-msg hook mpv 1 &>/dev/null
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
			statusx="restart"
			scopeold="$(playlist)"
			[[ -e /tmp/mpbasepllock ]] && wait $(< /tmp/mpbasepllock)
			basepl force
			print $! > /tmp/mpbasepllock
			dstfy "$(tracks) Files Add
			Play $(title)"
			polybar-msg hook mpv 1 &>/dev/null
		else
			if [[ "$scopeold" != "$(playlist)" ]]; then
				if [[ $(wc -c <<< "$scopeold") != "$(playlist |wc -c)" ]]; then
					[[ -e /tmp/mpbasepllock ]] && wait $(< /tmp/mpbasepllock)
					basepl event
					print $! > /tmp/mpbasepllock
					polybar-msg hook mpv 1 &>/dev/null
					scopeold="$(playlist)"
				else
					polybar-msg hook mpv 1 &>/dev/null
					dstfy "$(trackget) $(loaded title $(trackget))"
					scopeold="$(playlist)"
				fi
			fi
		fi
	else
		interval &&
		if sock.ativo; then; backend; else; polybar-msg hook mpv 1 &>/dev/null; return 5; fi
	fi
}
basepl ()
{
	[[ -n $@ ]] && \
		{
			case "$statusx" in
				restart )
					< $mpurls >| $mpurlsold
					loadeds url >| $mpurls;;
				start )
					: > $mpurls
					loadeds url > $mpurls;;
			esac

			fmpurlold=$(wc -l < $mpurlsold|grep -Ev '^$')
			fmpurl=$(wc -l < $mpurls|grep -Ev '^$')
			case "$@" in
				force )
				    : > $mptitles
				    j=1
				    while read line; do
						filename="$line"
						if [[ -e "~/$filename" || -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
							title=$(echo "$line" |sed 's/.*\///g;s/\///g')
						elif [[ -e "~/$filename" || -e "$filename" && "$filename" =~ ".m3u" ]]; then
							title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
						else
							titlepl="$(loadeds title $j)"
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
				    rm /tmp/mpbasepllock
				    dstfy "$(printf %b "$(tracks) -Files Add/Loaded\nPlaying -> $(trackget) $(sed -n ''$(trackget)'p' $mptitles)")"
				    interval &&
				    interval &&
				    polybar-msg hook mpv 1;;
				event )
				    if [[ $fmpurl -gt $fmpurlold ]]; then
						for (( i=$(( $fmpurlold + 1 )); i<=$fmpurl; i++ ))
						{
							filename=$(loadeds url $i)
							if [[ -e "~/$filename" || -e "$filename" && ! "$filename" =~ ".m3u" ]]; then
								title=$(echo "$filename" |sed 's/.*\///g;s/\///g')
							elif [[ -e "~/$filename" || -e "$filename" && "$filename" =~ ".m3u" ]]; then
								title=$(< "$filename" |sed -n '2p'|sed 's/.*\,\ //g')
							else
								titlepl="$(loadeds title $i)"
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
						rm /tmp/mpbasepllock
						polybar-msg hook mpv 1 &>/dev/null
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
