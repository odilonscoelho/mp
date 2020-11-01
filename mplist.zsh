#!/bin/zsh
plistrofi ()
{
	pidfile=$(mktemp)
	genBase () #
	{
		unset i
		while read line; do
			i=$(($i+1))
			printf '%s %s' "$i" "$line ;"
		done < $mptitles
	}

	# basepl $@
	list=$(genBase )

	while true; do
		selRow=$(($(trackget)-1))
		optn=$(echo "$list" | \
		rofi -dmenu -pid $pidfile -sep ";" -line-padding 10 -font "Iosevka Term SS07 Medium 16" \
		-selected-row $selRow -width 90 --xoffset 5 -location 2 -theme-str '#listview { layout: horizontal; }' \
		-theme-str '#inputbar { enabled: false; }' -no-click-to-exit -yoffset 74 -normal-window)
		[[ -n $optn ]] && { mp -track $(cut -d ' ' -f 1 <<< $optn) && continue } || break
	done
	rm -f $mktemp
}
console () #
{
	[[ -f $pidfile ]] || pidfile=$(mktemp)
	[[ -f $tmpfile ]] || tmpfile=$(mktemp)
	COMMANDS+=($(grep "()" $(print $HOME/hdbkp/projetos/shell/mp/*) |sed -E 's/\(\)//g'|cut -d ':' -f2|grep -Ev "#|COMMANDS")) #
	COMMAND=$(print -l $COMMANDS[@] | rofi -dmenu -line-padding 10 -font "Iosevka Term SS07 Medium 16" -width 35 -location 2 -theme-str '#listview { layout: horizontal; }'	-no-click-to-exit -yoffset 74 -normal-window)
	COMPARE=$(cut -d ' ' -f 1 <<<$COMMAND )
	if [[ -n $COMMAND && $COMMANDS[@] =~ $COMPARE ]]; then
		${${(s: :)COMMAND}[@]} &> $tmpfile
		dstfy "$(echo -e "mp console\n -> $COMMAND\n-> $(< $tmpfile)")"
		console
	else
		[[ -n $COMMAND ]] && \
			{
				dstfy "$(echo -e "mp console\n-> $COMMAND\nnão previsto")"
				rm -f $tmpfile $pidfile
				exit 0
			} || \
				{ 
					rm -f $tmpfile $pidfile
					exit 0 
				}
	fi

	rm -f $tmpfile $pidfile
}
controls.rofi ()
{
	#            
	echo " ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  " | \
	rofi -dmenu -sep ";" -line-padding 25 -font "Arimo Nerd Font 35" -width 27 -location 3 \
	-theme-str '#listview { layout: horizontal; }' -theme-str '#inputbar { enabled: false; }' \
	-no-click-to-exit -yoffset 74 -normal-window | read cmd
	case $cmd in
		"" ) mp -console;;
		"" ) mp -stop; selRow=6; controls.rofi ;;
		"" ) save; selRow=4; controls.rofi ;;
		"" ) select.file & selRow=3; controls.rofi;;
		"" ) prev & selRow=10; controls.rofi;;
		"" ) stop & selRow=7; controls.rofi;;
		"" ) pause.toggle & selRow=8; controls.rofi;;
		"" ) psuse.toggle & selRow=9; controls.rofi;;
		"" ) next & selRow=11; controls.rofi;;
		"" ) mp & selRow=2; controls.rofi;;
		"" ) format & selRow=1; controls.rofi;;
		"" ) searchYT; selRow=0; controls.rofi;;
		"" ) plistrofi null; controls.rofi ;;
	esac
}
plistyad ()
{
	baseplyad $@
	tail -F --lines=2000 \
	--sleep-interval=1 $mplistyad \
	|\
	yad --list \
	--icon-size=48 \
	--title="Playlist MPV" \
	--grid-lines=vert \
	--grid-lines=hor \
	--geometry=300x400 \
	--columns 2 \
	--column=COD --column=Title:TEXT \
	--no-buttons --tail \
	--search-column=2 \
	--mouse \
	--grid-horizontal \
	--grid-vertical \
	--regex-search \
	--selectable-labels \
	--select-action="mp -indice %s" \
	--dclick-action="mp -trackgo"
	exit 0
}
controls ()
{
	yad \
	--mouse \
	--geometry 30x50 \
	--borders 5 \
	--form --columns 5 \
	--title=" Controls MPV" \
	--field=" Xclip      !youtube! execute mp xlip -o":FBTN "mp" \
	--field=" Open File  !fileopen!Selecionar arquivos para reprodução":FBTN "mp -select.file" \
	--field=" Stop/Clear !user-trash!Stop MPD MPV e Clear playlist":FBTN "mp -stop" \
	--field=" Del Sel    !remove!Deleta arquivo selecionado na playlist":FBTN "mp -removeyad" \
	--field=" Previous   !go-previous!Previous track":FBTN "mp -prev" \
	--field=" Plist      !open-menu!Abrir a playlist":FBTN "mp -plistyad force" \
	--field=" Play/Pause !player_play!Toggle pause/play":FBTN "mp -pause" \
	--field=" Save Pl    !gtk-save!Salvar playlist carregada":FBTN "mp -save" \
	--field=" Next       !go-next!Next track":FBTN "mp -next" \
	--field=" Format URL !configuration!Escolher resolução/formato":FBTN "mp -format" \
	--no-buttons
}
# Para Terminal
plist ()
{
	basepl "$@"
	rev=$(tput rev;)
	res=$(tput sgr0;)
	bold=$(tput bold;)
	i=1
	scopeold=""
	trcksold="$(tracks)"
	trckold="$(trackget)"
	plistloop && plistloop || plistloop
	plist event
}
plistloop ()  #
{
	if [[ $(tracks) -eq $trcksold && $trckold -eq $(trackget) && $scopeold == $(< $mptitles) ]]; then
		sleep 1
		plistloop
	else
		clear
		while read line; do
			if [[ "$i" -eq "$(trackget)" ]]; then
				echo "$rev $bold|   $(printf '%6s' $i) | $(printf '%-50s' $line|tail -c 50) $res"   
			else
				echo " |  $(printf '%8s' $i) | $(printf '%-50s' $line|tail -c 50) "
			fi
			i=$(( $i + 1 ))
		done < $mptitles
		scopeold=$(< $mptitles)
		trcksold=$(tracks)
		trckold=$(trackget)
		sleep 0.5
		i=1
		plistloop
	fi
}

#爛
