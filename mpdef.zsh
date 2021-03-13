#!/bin/zsh
sock.ativo ()  #
{
	[[ -z $(loadedx) ]] && return 1 || return 0
    #[[ -e /tmp/mpid ]] && return 1 || return 0
} 2>/dev/null
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
get.socks () #
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
    _select () #
    {
    	select sel in ${(f)"$(main $parms)"}; do
    		[[ -n $sel ]] && { add "${${(s: :)sel}[-2]}"; mpd start & } || break
    	done
    	printf '%s\n' "continuar com a mesma pesquisa? [s/n]:" 
    	read select_continue
    	while true; do
        	if [[ $select_continue == "s" || $select_continue == "S" ]]; then
        	    clear
        	    _select
            elif [[ $select_continue == "n" || $select_continue == "N" ]]; then
                break
                return 0
            else
                printf '%s\n' "E necessario informar s|S para continuar ou n|N para sair da pesquisa atual"
                printf '%s\n' "continuar com a mesma pesquisa? [s/n]:" 
                read select_continue
                continue
            fi
        done
    }
	unset qt_return
	custom_return="false"
	typeset -a parms
	print "Search -> "
	read parms
	print "Return -> "
	read qt_return
	_select
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

		format=$(yad --list \
		--columns=3 --column "Format Code" --column "Extension" --column "Resolution/Audio Only" \
		--button="BEST":"mp play.best" \
		--title "Opções :" --selectable-labels --search-column=2 --search-column=3 --regex-search \
		--text-align=center --geometry 400x320 --borders=5 ${(s:|:)base} |cut -d'|' -f1|grep -Ev '^$')
		
		[[ -z $format ]] && exit 0
	fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

loadedx ()
{ 
	base=(${(f)"$(playlist |sed 's/'}','{'/\n/g;s/\]\|\[\|{\|}//g;s/,\"request_id".*//g;s/,\"current\":true\|,\"playing\":true//g;s/\"data\":\|\"filename\":\|\"title\":\|\"id\"://g;s/\",/\"|/g;s/\"//g'| sed 's/|[[:digit:]].*//g')"})
	if [[ -z $@ ]];then
		unset control
		for media in $base[@]
		{
			(( control = control + 1 ))
			print "$control|$media"
		}
	else
		print "$@|$base[$@]"
	fi
}

source.file ()
{
	add ${(f)"$(<$@)"}
	mpd start &
}
