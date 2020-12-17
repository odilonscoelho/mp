#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
modi.def ()  #
{
	case $@ in 
		console ) echo OK ;;
		terminal ) echo OK ;;
		yad ) echo OK ;;
		rofi ) echo OK ;;
		* ) modi="terminal"
	esac
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
sock.ativo ()  #
{
	[[ -z $(loaded url 2>/dev/null) ]] && return 1 || return 0
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
get.socks ()
{
	print -l /tmp/mpvsock*
} 2>/dev/null
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
get.title () #
{
	youtube-dl --get-title "$@"
}

search ()
{
  
	main ()  #
	{
		
		base="$(youtube-dl --get-title --get-id --get-duration "ytsearch$qt_return:"$@"" |xargs -0)"

		control=1
		controllerT=1
		controllerI=1
		controllerD=1

		typeset -A Titles IDs Durations

		for element in ${${(f)base}[@]}
		{
			case $control in
				1 )
					control=$(($control+1))
					Titles+=([$controllerT]=$element)
					controllerT=$(($controllerT+1)) ;;
				2 ) 
					control=$(($control+1))
					IDs+=([$controllerI]="https://www.youtube.com/watch?v=$element")
					controllerI=$(($controllerI+1)) ;;
				3 ) 
					control=1
					Durations+=([$controllerD]=$element)
					controllerD=$(($controllerD+1)) ;;
			esac
		}

		if [[ $#Titles[@] -gt 1 ]]; then
			for (( i = 1; i <= $#Titles[@]; i++ )); do
			 	[[ $(($i%2)) -eq 0 ]] && \
					{ echo "$(tput sgr0; tput setaf 7; tput setab 8; tput bold;) $(printf '%-'$(($(($(($COLUMNS-8))/4))*2))'s' "${Titles[$i][1,$(($(($(($COLUMNS-8))/4))*2))]}") $(printf '%8s' "$Durations[$i]") $(tput sgr0; tput setaf 12; tput setab 8;) $(printf '%'$(($(($COLUMNS-8))/4))'s' "$IDs[$i]") $(tput sgr0;)" } || \
						{	echo "$(tput sgr0; tput setaf 7; tput setab 0; tput bold;) $(printf '%-'$(($(($(($COLUMNS-8))/4))*2))'s' "${Titles[$i][1,$(($(($(($COLUMNS-8))/4))*2))]}") $(printf '%8s' "$Durations[$i]") $(tput sgr0; tput setaf 12; tput setab 0;) $(printf '%'$(($(($COLUMNS-8))/4))'s' "$IDs[$i]") $(tput sgr0;)"  }
			done
		else
			 echo "$(tput sgr0; tput setaf 7; tput setab 0; tput bold;) $(printf '%-'$(($(($(($COLUMNS-8))/4))*2))'s' "${Titles[1][1,$(($(($(($COLUMNS-8))/4))*2))]}") $(printf '%8s' "$Durations") $(tput sgr0; tput setaf 12; tput setab 0;) $(printf '%'$(($(($COLUMNS-8))/4))'s' "${IDs}") $(tput sgr0;)"
		fi	  
	}


	unset qt_return
	custom_return="false"
	typeset -a parms

	print "Search -> "
	read parms
	print "Return -> "
	read qt_return
	select sel in ${(f)"$(main $parms)"}; do
		[[ -n $sel ]] && { add "${${(s: :)sel}[-2]}" } || break
	done
	exit 0
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
indice.selected () #Argumentos
{
	echo $@|cut -d" " -f1 > $tmpcod
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
format.url () #Argumentos
{
	if [[ "$url" =~ "https://www.youtube.com/playlist?|'https://www.youtube.com.*start_radio'" ]]; then
		declare -x format="best"
		declare -x new_class="youtube"
		elif [[ "$url" =~ "painelcode.me" ]]; then
		declare -x format="best"
		declare -x new_class="iptv"
	else
		case "$url" in;
			*www.xvideos.com* )
				base=$(\
				youtube-dl --list-formats "$url"\
				|grep -Ev "[XV]ideos|format|info|Downloading"\
				|awk '{print $1,$2,$3}'\
				|sed -E 's/ |$/\|/g');;
			*spankbang.com* )
				base=$(\
				youtube-dl --list-formats "$url"\
				|grep -Ev "Spank[b|B]ang|format|info"\
				|awk '{print $1,$2,$3}'\
				|sed -E 's/ |$/\|/g');;
			*youtube.com* )
				base=$(\
				youtube-dl --list-formats "$url"\
				|grep -Ev "Spank[b|B]ang|format|info|youtube|video only"\
				|awk '{print $1,$2,$3}'\
				|sed -E 's/ |$/\|/g');;
			*youtu.be* )
				base=$(\
				youtube-dl --list-formats "$url"\
				|grep -Ev "Spank[b|B]ang|format|info|youtube|video only"\
				|awk '{print $1,$2,$3}'\
				|sed -E 's/ |$/\|/g');;
		esac
		declare -x format=$(yad --list \
		--columns=3 --column "Format Code" --column "Extension" --column "Resolution/Audio Only" \
		--button="BEST":"mp play.best" \
		--title "Opções :" --selectable-labels --search-column=2 --search-column=3 --regex-search \
		--text-align=center --geometry 400x320 --borders=5 ${(s:|:)base} |cut -d'|' -f1|grep -Ev '^$')
		[[ -z $format ]] && exit 0
	fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

loaded ()
{
	unset url title id

	plistCarregada="$(playlist)"

	<<< $plistCarregada| sed 's/,/\n/g'|grep -q '"title":' && \
	{
		for x in ${(f)"$(grep -Ev '^$|error:sucess|current:true|playing:true|id:|title:' <<< "$(sed 's/{\|}\|\[\|\].*\|\"//g;s/,/\n/g;s/data://g;s/filename://g' <<< "$plistCarregada")")"}
		{
			url+=("$x")
		}
		for x in ${(f)"$(grep -Ev '^$|error:sucess|current:true|playing:true|id:|filename:' <<< "$(sed 's/{\|}\|\[\|\].*\|\"//g;s/,/\n/g;s/data://g;s/title://g' <<< "$plistCarregada")")"}
		{
			title+=("$x")
		}
		[[ $#url[@] -ne $#title[@] ]] && \
			{
				for i in {$(($#url[@] - ($#url[@] - $#title[@])))..$#url[@]}
				{
					[[ -z "$(sed -n ''$i'p' /tmp/mptitlesDefault)" ]] && title+=("$(sed -n ''$i'p' /tmp/mptitlesDefault)") || title+=("null")
				}
			}
	} || \
		{
			control=1
			for x in ${(f)"$(grep -Ev '^$|error:sucess|current:true|playing:true|id:|title:' <<< "$(sed 's/{\|}\|\[\|\].*\|\"//g;s/,/\n/g;s/data://g;s/filename://g' <<< "$plistCarregada")")"}
			{
				url+=("$x")
				titlemptitles=$(sed -n ''$control'p' $mptitles)
				[[ -z $titlemptitles ]] && title+=("null") || title+=("$titlemptitles")
				control=$((control+1))
			}
		}

	[[ $# -gt 1 ]] && \
		{
			case $1 in
				url* )
					print -l $url |sed -n ''$2'p';;
				title* ) 
					print -l $title |sed -n ''$2'p';;
			esac
		} || \
			{
				case $1 in
					url ) 
						print -l $url;;
					title ) 
						print -l $title;;
				esac
			}
}


loadeds ()
{
  # grep -Ev 'request_id|error":' <<< $(sed -E 's/,/\n/g;s/\{\"filename\"\://g;s/\"title\"\://g;s/\}//g;s/\]//g' /tmp/playlist)
	case $@ in
		url.iptv )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|title:' \
			|cut -d':' -f2- ;;
		url.iptv* )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|title:' \
			|cut -d':' -f2- \
			|sed -n ''$2'p' ;;
		title.iptv )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|filename:' \
			|cut -d':' -f2- ;;
		title.iptv* )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|filename:' \
			|cut -d':' -f2- \
			|sed -n ''$2'p' ;;
		url )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|title:' \
			|sed 's/\,id\:.*//g' \
			|cut -d':' -f2- ;;
		url* )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|title:' \
			|sed 's/\,id\:.*//g' \
			|cut -d':' -f2- \
			|sed -n ''$2'p' ;;
		title )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|sed 's/\,id\:.*//g' \
			|grep -Ev '^$|filename:' \
			|cut -d':' -f2- ;;
		title* )
			playlist \
			|sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
			|sed -E 's/,$|,,$|,,,$|,,,,$//g' \
			|grep -Ev '^$|filename:' \
			|cut -d':' -f2- \
			|sed -n ''$2'p' \
			|sed 's/\,id\:.*//g'  ;;
	esac
}
