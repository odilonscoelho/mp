#!/bin/zsh
save ()
{
	[[ -z $@ ]] && { select.file save |read file } || file=$@
	[[ -z $file ]] && msg "Operação cancelada ! PLaylist não Salva!"
	[[ -d $file ]] && msg "Operação cancelada ! PLaylist não Salva! Foi selecionado apenas o diretório"
	echo "#EXTM3U" > $file
	i=1
	while read line; do
		print "#EXTINF:\" \", ${${(s:|:)line}[3]}\n${${(s:|:)line}[2]}" >> $file &&
		#printf %b "#EXTINF:'" "', ${{(s:|:)line}[3]}\n$HOME/${{(s:|:)line}[2]}" >> $file &&
		i=$(( $i + 1 ))
	done < $mpurls
	dstfy "$file"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
select.file ()
{
	[[ -z $1 ]] && \
		file="$(yad --separator=\! --text="Select files....$ _>" --file --multiple --geometry=600x800)"
		[[ -n $file ]] && { add "${(s:!:)file}" ; mpd start }
	[[ -n $1 ]] && yad --text="Select files....$\_>" --file --multiple --save
}
#--------------------------------------------------\---------------------------------------------------------------------------------------------------------------------------------------------------#
play.best ()  #
{
	[[ -n $(loadedx) ]] && add.url || rm -f $sock && mpv --x11-name="$new_class" $url --input-ipc-server=$sock &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
pause.toggle ()
{
	if [[ $(echo '{ "command": ["get_property", "pause"] }' |socat - $sock |grep 'true') ]];then
		echo '{ "command": ["set_property", "pause", false] }' |socat - $sock
	else
		echo '{ "command": ["set_property", "pause", true] }' |socat - $sock
	fi
	[[ $polymsg == "true" ]] && polymsg.command >/dev/null
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
msg () #Argumentos
{
	yad --form --button=yad-ok --borders=5 --mouse --geometry=700x300 --title "Information:" --field=CONTEUDO:TXT "$@"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
poly.title ()   #
{
    local limit_title=20
	local limit_artist=15
    
    # local trck=$(trackget)
    local TITLE=$(title)
    # local ARTTIST=$(get.artist $trck)
    
    local icon_playing=" "
    local icon_stoped=" "
    local icon_paused=" "
    
    if sock.ativo; then
        trck=$(trackget)
        ARTIST="$(get.artist $(trackget))"
        if sock.ativo; then
        	if [[ $(playlist |sed 's/,/\n/g'|grep '"playing":true') ]]; then
        		if [[ $(echo '{ "command": ["get_property", "pause"] }' |socat - $sock |grep 'true') ]];then
        			printf '%'$limit_title's %'$limit_artist's' "${TITLE[1,$limit_title]},%{F#E78F8F}%{T5} ${ARTIST[1,$limit_artist]}%{T0}" "%{F$mprefixcolor}%{T7}   %{T0}%{F$color4}$trck "
        		else
        			trck=$(trackget)
        			printf '%'$limit_title's %'$limit_artist's' "${TITLE[1,$limit_title]},%{F#E78F8F}%{T5} ${ARTIST[1,$limit_artist]}%{T0}" "%{F$mprefixcolor}%{T7}   %{T0}%{F$color4}$trck "
        		fi
        	else
        		printf '%s %s' " ... " "%{T7}%{F$mprefixcolor}   %{T0}%{F$color4}$(tracks) "
        	fi
        fi
    else
        printf '%s %s' " ... " "%{T7}%{F$mprefixcolor}   %{T-}%{F-}"
    fi
}
dstfy ()   #
{
	[[ -z $icon ]] && { icon="${${(f)"$(print -l $HOME/.icons/${${(s:=:)${(f)"$(< ~/.config/gtk-3.0/settings.ini)"}[3]}[2]}/apps/scalable/mpv*)"}[1]}" }
	[[ -z $@ ]] && dunstify -t 10000 -i $icon "$(title)" || dunstify -t 5000 -i $icon "$@"
}

help () #
{
    .foreground () print -P %F{foreground}"$@"%f
    .black () print -P %F{black}"$@"%f
    .red () print -P %F{red}"$@"%f
    .green () print -P %F{green}"$@"%f
    .yellow () print -P %F{yellow}"$@"%f
    .blue () print -P %F{blue}"$@"%f
    .magenta () print -P %F{magenta}"$@"%f
    .cyan () print -P %F{cyan}"$@"%f
    .white () print -P %F{white}"$@"%f
    .bold () print -P %B"$@"%b
    
    .bold "`.green "Usage :"`"
    printf %b '\n'
    .bold "`.red "mp"` `.green "[options]"` `.blue "<files/urls>"`"
	printf %b '\n'
	.bold "`.green ls` `.blue "<path/*.mp3>"` `.foreground "|"` `.red mp` `.green "[options]"`"
	printf %b '\n'
	.bold "`.green "Options :"`"
	printf %b "`.green "-c          --controls"`\t\t`.foreground "- Abre controls em yad (Requer Yad) "`\n"
	printf %b "`.green "-console    --console"`\t\t`.foreground "- Abre console em modo comando (Requer Rofi) "`\n"
	printf %b "`.green "-fmt 	    --format"`\t\t`.foreground "- Lista de formatos disp (somente urls, Requer Yad) "`\n"
	printf %b "`.green "-fmtgo 	    --format-go <cod>"`\t`.foreground "- Altera o formato do video em execuçao (mesmo cod disponivel em -fmt/--format) "`\n"
	printf %b "`.green "-gt         --get-thumb"`\t\t`.foreground "- Notificação com a thumb da música ou vídeo (pesquisa online, requer Dunst, Wget e yt-dl)"`\n"
	printf %b "`.green "-mpd 	    --mpd [start/stop]"`\t`.foreground "- Toggle start/stop manual do daemon do mp (necessario para reconstruir playlist) "`\n"
	printf %b "`.green "-next 	    --next"`\t\t`.foreground "- Next Faixa "`\n"
	printf %b "`.green "-pause 	    --pause"`\t\t`.foreground "- Toggle Pause/Play "`\n"	
	printf %b "`.green "-pl         --playlist"`\t\t`.foreground "- Playlist no Terminal "`\n"	
	printf %b "`.green "-ply        --playlist-yad"`\t`.foreground "- Playlist em Yad (Requer Yad)"`\n"	
	printf %b "`.green "-plr        --playlist-rofi"`\t`.foreground "- Playlist em Rofi (Requer Rofi)"`\n"	
	printf %b "`.green "-prev       --prev"`\t\t`.foreground "- Prev Faixa "`\n"
	printf %b "`.green "-pb         --polybar"`\t\t`.foreground "- Saida para modulo polybar "`\n"
	printf %b "`.green "-sv         --save"`\t\t`.foreground "- Salvar a playlist (Requer Yad)"`\n"
	printf %b "`.green "-sva        --save-as file.m3u"`\t`.foreground "- Salvar como a playlist (Terminal) "`\n"
	printf %b "`.green "-sf         --select-file"`\t`.foreground "- Selecionar arquivos para reproduçao (Requer Yad) "`\n"
	printf %b "`.green "-sc         --search"`\t\t`.foreground "- Search Videos no youtube "`\n"
	printf %b "`.green "-s          --sock <sock>"`\t`.foreground "- Iniciar uma nova sessao com o sock fornecido "`\n"
	printf %b "`.green "-stop       --stop"`\t\t`.foreground "- Encerra a sessao atual do mp"`\n"
}

get.artist () #
{
	[[ -z $url ]] && url=${${(s:|:)$(loadedx $@)}[2]}
	if [[ -e $url ]]; then
		case ${#${(s:/:)url}[@]} in
			1) artist="$url";;
			2) artist="${${(s:/:)url}[1]}";;
			3) artist="${${(s:/:)url}[2]}";;
			4) artist="${${(s:/:)url}[3]}";;
			5) artist="${${(s:/:)url}[4]}";;
			6) artist="${${(s:/:)url}[5]}";;
			7) artist="${${(s:/:)url}[6]}";;
			8) artist="${${(s:/:)url}[7]}";;
			8) artist="${${(s:/:)url}[7]}";;
		esac
		Online=false
	else
		if [[ $url =~ //spankbang\|//.*videos.com ]]; then
			artist=" "
		elif [[ $url =~ //.*youtube ]]; then
			artist=" "
		else
			artist=" "
		fi
		Online=true
	fi
	<<< $artist
}

get.thumb () 
{
    _gt ()
    {
    	[[ $Online == "true" ]] && \
    		{ search_online=$(youtube-dl --get-thumbnail "$url" 2>/dev/null) } || \
    			{ [[ $artist != acervo ]] && { search_online=$(youtube-dl --get-thumbnail "$engine_search:$artist $title" 2>/dev/null) } || { search_online="" } }
        
    	[[ -z $search_online ]] && { icon="" } || \
    			{
    				[[ $search_online =~ .jpg ]] && \
    					{
    						[[ $search_online =~ .jpg$ ]] && \
    							{
    								wget --quiet $search_online --output-document /tmp/thumb.jpg
    							} || \
    								{
    									search_online=$(sed 's/\.jpg?.*/.jpg/' <<< $search_online)
    									wget --quiet $search_online --output-document /tmp/thumb.jpg
    								}
    					} || \
    						{
    							wget --quiet $search_online --output-document /tmp/thumb.webp
    							convert /tmp/thumb.webp /tmp/thumb.jpg
    							rm /tmp/thumb.webp
    						}
    				icon=/tmp/thumb.jpg
    			}        
    }
    unset infom_album infom_genre infom_title infom_artist infom_Duration
	url=${${(s:|:)$(loadedx $@)}[2]}
	url=${url:-${${(s:|:)$(loadedx $(trackget))}[2]}}
	engine_search=ytsearch
	if [[ -e $url  ]];then
		[[ "$(file $url)" =~ "MP4" ]] && \
			{ 
				ffmpegthumbnailer -m -s0 -q10 -i $url -o /tmp/thumb.jpeg
				icon=/tmp/thumb.jpeg
				<<< $url | sed 's/.*\///g;s/\..*$//g' |read title
				artist=$(get.artist)
				duration="$(print 'scale=2;'$(duration)'' / 60 |bc |sed 's/\./:/' )"
				dstfy "$(printf '%s\n' "$artist" "$title")" "Time : ${duration:-unknow}"
				rm /tmp/thumb.jpeg
				return 0
			}
			
    	ffprobe "$url" 2>&1 |grep -E 'title|artist|album|genre|Duration'|sed -E 's/ *\:/\=/1;s/\= /="/;s/\..*//;s/^ *//g;s/$/"/;s/^/infom_/' > /tmp/mpimportinfo
    	
        . /tmp/mpimportinfo
        
        [[ -z $infom_artist || $infom_artist == $infom_title ]] && artist="$(get.artist)" || artist="$infom_artist"
        [[ -z $infom_album ]] && album="Unknow" || album="$infom_album"
        [[ -z $infom_genre ]] && genre="Unknow" || genre="$infom_genre"
        [[ -z $infom_Duration ]] && duration="$(print 'scale=2;'$(duration)'' / 60 |bc |sed 's/\./:/' )" || duration="${infom_Duration//00:/}"
        [[ -z $infom_title ]] && title="$(sed 's/.*\///g;s/\..*$//g' <<< $url)" || title="$infom_title"
        
        _gt			  
        dstfy "$(printf '%s\n' "$artist" "$title")" "$(printf '%s\n' "Album : $album"   "Genre : $genre" "Time : $duration")"
    	rm /tmp/thumb.jpg
    	rm /tmp/mpimportinfo
	else
	    sed -n $@'p' $mpurls |cut -d '|' -f 3 |read title
		artist="$(get.artist)"
		duration=$(youtube-dl --get-duration "ytsearch:"$url"")
		_gt			  
        dstfy "$(printf '%s\n' "$artist" "$title")" "Time : $duration"
    	rm /tmp/thumb.jpg
	fi
}
