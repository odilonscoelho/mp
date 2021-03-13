#!/bin/zsh
### Yads
plistyad ()
{
    while read line; do; print "${${(s:|:)line}[1]} \n${${(s:|:)line}[2]}"; done < $mpurls > /tmp/mplistyad
	tail -F --lines=2000 \
	--sleep-interval=1 /tmp/mplistyad | \
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
	--select-action="mp --indice %s" \
	--dclick-action="mp --track-go"
	
	rm /tmp/mplistyad
	exit 0
} &>/dev/null

controls ()
{
	yad \
	--mouse \
	--geometry 30x50 \
	--borders 5 \
	--form --columns 5 \
	--title=" Controls MPV" \
	--field=" Xclip      !youtube! execute mp xlip -o":FBTN "mp -x" \
	--field=" Open File  !fileopen!Selecionar arquivos para reprodução":FBTN "mp -sf" \
	--field=" Stop/Clear !user-trash!Stop MPD MPV e Clear playlist":FBTN "mp -stop" \
	--field=" Del Sel    !remove!Deleta arquivo selecionado na playlist":FBTN "mp -removeyad" \
	--field=" Previous   !go-previous!Previous track":FBTN "mp -prev" \
	--field=" Plist      !open-menu!Abrir a playlist":FBTN "mp -plistyad" \
	--field=" Play/Pause !player_play!Toggle pause/play":FBTN "mp -pause" \
	--field=" Save Pl    !gtk-save!Salvar playlist carregada":FBTN "mp -S" \
	--field=" Next       !go-next!Next track":FBTN "mp -next" \
	--field=" Format URL !configuration!Escolher resolução/formato":FBTN "mp -cmd format" \
	--no-buttons
}
# Para Terminal
pl () #
{
	impress () #
	{
		local col1=$((COLUMNS/10))
		local col2=$(((COLUMNS/10)*8))
		local limit_line=$((LINES-2))
		if [[ "$(tracks)" -gt $limit_line ]];then
			if [[ $trck -gt $limit_line ]];then
				in=$(( trck - (LINES/2) ))
				end=$(( trck + (LINES/2) ))
			else
				in=1
				end=$limit_line
			fi	
		else
			in=1
			end=$(tracks)
		fi
		clear
		while read line; do
			[[ -n "${${(s:|:)line}[3]}" ]] && local title="${${(s:|:)line}[3]}" || local title="${${${(s:|:)line}[2]//.*/}//*\//}"
			[[ "${${(s:|:)line}[1]}" == $trck ]] && 
				{
					print -P %K{black}%F{red}%B"$(printf '%'$col1's | %'-$col2's\n' " ${${(s:|:)line}[1]}" "$title[1,$col2]")"%k%f%b
				} ||
					{
						printf '%'$col1's | %'-$col2's\n' "${${(s:|:)line}[1]}" "$title[1,$col2]"
					}
		done < $mpurls| sed -n "$in,$end"'p'
	}

	if [[ -e $mpurls ]]; then
		if [[ -z $pass ]]; then 
			scopeold="$(< $mpurls)"
			trck=$(trackget)
			impress
			pass=restart
			pl
		else
			sleep 1
			[[ "$(< $mpurls)" != "$scopeold" ]] && { pass=""; pl }
			sleep 1
			[[ $trck != $(trackget) ]] && { trck=$(trackget); impress }
			pl
		fi
	else
		print -P %K{black}%F{red}%B" mpv stoped "%b%f%k
	fi
} 2>/dev/null

### Rofi
plistrofi ()
{
	_genBase () #
	{
		while read line; do
			[[ -n "${${(s:|:)line}[3]}" ]] && local title="${${(s:|:)line}[3]}" || local title="${${${(s:|:)line}[2]//.*/}//*\//}"
			printf '%s %s' "${${(s:|:)line}[1]}" "$title ;"
		done < $mpurls
	}

	_window () #
	{
		while true; do
			selRow=$(($(trackget)-1))
			
			optn=$(echo "$list" | \
			rofi -dmenu -sep ";" -line-padding 2 -padding 10 \
			-selected-row $selRow -width 15 -xoffset -25 -location 3 -theme-str '#listview { layout: vertical; }' \
			-no-click-to-exit -yoffset 84 -normal-window -window-title "MP Plist")
			[[ -n $optn ]] && { track $(cut -d '|' -f 1 <<< $optn) && continue } || exit 0
		done
	}
	
	list=$(_genBase )
	scopeold=$(playlist)
	_window &
	sleep 0.5
	PID=$(ps aux |grep '[t]itle\ MP' |awk '{print $2}')
	while true; do
		sleep 1
		scopenew=$(playlist)

		[[ "${scopenew}" != "${scopeold}" ]] && \
			{
				[[ ${#scopenew} -ne ${#scopeold} ]] && list=$(_genBase)
				scopeold=$scopenew
				kill "$PID"
				_window &
				sleep 1
				bspc node older.local -f
				PID=$(ps aux |grep '[t]itle\ MP' |awk '{print $2}')
			}
		
		ps aux |grep '[t]itle\ MP' && { continue } || { break }
	done
	exit 0
} &>/dev/null


console () #
{
		COMMANDS=(controls format formatgo get.thumb mpd next pause.toggle playlist.clear plistrofi plistyad prev remove save select.file source.file stop track vol xclip_clipboard)
	
	COMMAND=$(print -l $COMMANDS | rofi -dmenu -line-padding 2 -width 15 -location 3 -theme-str '#listview { layout: vertical; }' -no-click-to-exit -yoffset 84 -xoffset -65 -normal-window -window-title "MP Console")
	
	COMPARE=$(cut -d ' ' -f 1 <<<$COMMAND )
	if [[ -n $COMMAND && $COMMANDS[@] =~ $COMPARE ]]; then
		${${(s: :)COMMAND}[@]}
		console
    fi
}

controls.rofi ()
{
	echo " ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  " | \
	rofi -dmenu -sep ";" -line-padding 25 -font "Arimo Nerd Font 25" -location 3 \
	-theme-str '#listview { layout: horizontal; }' -theme-str '#inputbar { enabled: false; }' \
	-no-click-to-exit -yoffset 84 -xoffset -25 -width 36 -normal-window -window-title "MP Control" | read cmd
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
		"" ) mp -xclip & selRow=2; controls.rofi;;
		"" ) format & selRow=1; controls.rofi;;
		"" ) searchYT; selRow=0; controls.rofi;;
		"" ) plistrofi null; controls.rofi ;;
	esac
}
