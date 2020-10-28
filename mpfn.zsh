#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
save ()
{
	# File="$(yad --text="Select files....$\_>" --file --save)"
	select.file save |read file
	[[ -z $file ]] && msg "Operação cancelada ! PLaylist não Salva!"
	[[ -d $file ]] && msg "Operação cancelada ! PLaylist não Salva! Foi selecionado apenas o diretório"
	t=1;while read line; do; export title[$t]=$line;t=$t+1;done < $mptitles
	echo "#EXTM3U" >| $file
	i=1
	while read line
	do
		echo "#EXTINF:'" "', $line\n$(< $mpurls| sed -n ''$i'p')" >> $file &&
		i=$(( $i + 1 ))
	done < $mptitles
	dstfy "$file"
}

add.to ()
{
	if [[ $1 =~ "essa" ]]; then
		url=$(loaded url "$(trackget)")
		title=$(loaded title "$(trackget)")
	else
		url=$(loaded url $1)
		url=$(loaded title $1)
	fi
	if [[ -z $2 ]]; then
		file="$(select.file save)"
		[[ -z $file ]] && msg "Operação cancelada ! PLaylist não Salva!"
		[[ -d $file ]] && msg "Operação cancelada ! PLaylist não Salva! Foi selecionado apenas o diretório"
	else
		file="$2"
	fi
	[[ -z $title ]] && title=$(loaded title.iptv $1)
	[[ -z $title ]] && title=$(get.title $1)
	
	echo "#EXTINF:' ', $title\n"$url"" >> $file
	exit 0
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
select.file () 
{
	[[ -z $1 ]] && \
		file="$(yad --separator=\! --text="Select files....$ _>" --file --multiple --geometry=600x800)" && \
			[[ -n $file ]] && mp "$file" #url file &&
	[[ -n $1 ]] && yad --text="Select files....$\_>" --file --multiple --save
}
#--------------------------------------------------\---------------------------------------------------------------------------------------------------------------------------------------------------#
play.best ()  #
{
	[[ -n $(loaded url) ]] && add.url || rm -f $sock && mpv --x11-name="$new_class" $url --input-ipc-server=$sock &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
pause.toggle ()
{
	if [[ $(echo '{ "command": ["get_property", "pause"] }' |socat - $sock |grep 'true') ]];then
		echo '{ "command": ["set_property", "pause", false] }' |socat - $sock
	else
		echo '{ "command": ["set_property", "pause", true] }' |socat - $sock
	fi
	polybar-msg hook mpv 1
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
msg () #Argumentos
{
	yad --form --button=yad-ok --borders=5 --mouse --geometry=700x300 --title "Information:" --field=CONTEUDO:TXT "$@"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
poly.title ()   #
{
	if [[ ${#$(get.socks)} -gt 0 ]]; then
		for x in $(get.socks)
		{
			sock=$x
			if sock.ativo; then
				if [[ $(playlist |sed 's/,/\n/g'|grep '"playing":true') ]]; then
					if [[ $(echo '{ "command": ["get_property", "pause"] }' |socat - $sock |grep 'true') ]];then
						trck=$(trackget)
						printf '%-20s %10s' "  $(title|tail -c 12)" "| %{F$mprefixcolor}%{F-} $trck |  "
					else
						trck=$(trackget)
						printf '%-20s %10s' "  $(title|tail -c 20)" "| %{F$mprefixcolor}%{F-} $trck |  "					
					fi
				else
					printf '%-20s %10s' "           " "|  |  "
					continue
				fi
			fi
		}
	else
		printf '%-10s %10s' "      " "|  |  "
	fi
}
dstfy ()   #
{
	[[ -n $1 ]] &&  dunstify -t 5000 "$@" ||dunstify -t 5000 "$(poly.title)"
}

help ()
{
	<<- doc

		`tput rev; tput bold`MP - Media Player with MPV `tput setab 1;`®`tput sgr0;tput rev;tput bold`AllScripts`tput setab 1;`®`tput sgr0;`
	Por `tput bold;`Odilon Coelho`tput sgr0;`
	odilon.coelho@oulook.com
	@t.me/losaoall

	$(tput bold)$(tput setaf 3)USO:$(tput sgr0;) 	
	
	`tput bold`mp [options] <files/urls>`tput sgr0`

	`tput bold`Options:`tput sgr0`

	`tput bold`-bpl 	-basepl`echo -e '\t\t'` - Atualiza a base de dados para playlists (terminal)
	`tput bold`-bply 	-baseplyad`echo -e '\t'` - Atualiza a base de dados para playlistyad *deprecate
	`tput bold`-c 	-controls`echo -e '\t'` - Abre controls em yad
	`tput bold`-cr 	-controlsr`echo -e '\t'` - Abre controls em rofi
	`tput bold`-console`echo -e '\t\t'` - Abre o modo console em rofi
	`tput bold`-f 	-format`echo -e '\t\t'` - Alterar format do video/áudio do yt (terminal, console e controlsr)
	`tput bold`-gs 	-get-socks`echo -e '\t'` - Verificar quais os nomes dos socks abertos (terminal)
	`tput bold`-h 	-help`echo -e '\t\t'` - Esse menu de ajuda (terminal)
	`tput bold`-mpd`echo -e '\t\t\t'` - start / stop - para iniciar ou parar o daemon (terminal e console)
	`tput bold`-nx 	-next `echo -e '\t\t'` - Next track (terminal e console)
	`tput bold`-p 	-pause `echo -e '\t\t'` - Toggle Pause/Play (terminal e console)
	`tput bold`-pb 	-polybar `echo -e '\t'` - Label para módulo polybar
	`tput bold`-pv 	-prev `echo -e '\t\t'` - Prev track (terminal e console)
	`tput bold`-pl 	-plist `echo -e '\t\t'` - Playlist no terminal (terminal)
	`tput bold`-plr 	-plistrofi `echo -e '\t'` - Playlist no rofi (terminal e console)
	`tput bold`-ply 	-plistyad `echo -e '\t'` - PLaylist no yad *deprecate
	`tput bold`-rm 	-remove `echo -e '\t'` - Remove a track informada (terminal e console).
	`tput bold`-rmy 	-removeyad `echo -e '\t'` - Remove a track selecionada na playlist com yad
	`tput bold`-S 	-Save `echo -e '\t\t'` - Salve a playlist atual - Requer yad
	`tput bold`-svf 	-save-file `echo -e '\t'` - Salve a playlist com o nome informado (terminal e console)
	`tput bold`-s 	-sock `echo -e '\t\t'` - Inicie o MP com o socket informado
	`tput bold`-st 	-stop `echo -e '\t\t'` - Stop e clear playlist (terminal e console)
	`tput bold`-sf 	-selfile `echo -e '\t'` - Selecionar arquivos para execução - Requer yad
	`tput bold`-t 	-track `echo -e '\t\t'` - Vá para a track informada
	`tput bold`-tget 	-trackget `echo -e '\t'` - Informa qual a track em execução (terminal)
	`tput bold`-tt 	-title `echo -e '\t\t'` - Retorna o título do arquivo/url 'N' solicitada (terminal)
	`tput bold`-u 	-url `echo -e '\t\t'` - Retorna o nome do arquivo/url 'N' solicitada (terminal)
	`tput bold`-v 	-vol `echo -e '\t\t'` - Seta o volume do mpv no valor informado`tput sgr0`

	doc
}