#!/bin/zsh
# verificar pois pode exminir muitos comandos clear, atualmente usado só em local file 'lfs'.
add () #
{
	if sock.ativo; then
		# print "add"
		for arg in $@
		{
		 echo '{ "command": ["loadfile", "'"$arg"'", "append-play"], "request_id": 0}' |socat - $sock & #adicionar File individualmente
		}
	else
		# print "add.clear"
		rm -f $sock 2> /dev/null
		mpv $@ --input-ipc-server=$sock &> /dev/null &
	fi
}

add.yad () #
{
	if sock.ativo; then
		# dstfy "YADs requisitado"
		# print "add.yad"
		if [[ ${#${(s:!:)yads}} -ne 1 ]]; then
			urlx="$(print -l $yads|sed 's/\!/\n/g'|grep -Ev '^$')"
			for (( i=1; i<=${#${(f)urlx}}; i++ ));do
		 		echo '{ "command": ["loadfile", "'${${(f)urlx}[$i]}'", "append-play"], "request_id": 0}' |socat - $sock &
			done
		else
		 	urlx="$(print -l $yads|sed 's/\!//g')"
		 	echo '{ "command": ["loadfile", "'$urlx'", "append-play"], "request_id": 0}' |socat - $sock &
		fi
	else
		if [[ ${#${(s:!:)yads}} -gt 1 ]]; then
			urlx="$(print -l $yads|sed 's/\!/\n/g'|grep -Ev '^$')"
			mpv ${${(f)urlx}[1]} --input-ipc-server=$sock &> /dev/null & PID=$!
			echo $PID >| $mpid
			for (( i=2; i<=${#${(f)urlx}}; i++ ));do
				#mpv -add ${${(f)urlx}[$i]} --input-ipc-server=$sock &> /dev/null &
		 		echo '{ "command": ["loadfile", "'${${(f)urlx}[$i]}'", "append-play"], "request_id": 0}' |socat - $sock &
			done
		else
			rm -f $sock
			mpv ${(s:!:)url} --input-ipc-server=$sock &> /dev/null & PID=$!
			echo $PID >| $mpid
		fi
	fi
}
duration ()
{
	echo '{ "command": ["get_property", "duration"], "request_id": 0}' |socat - $sock |sed -E 's/.*data\":|,\".*//g' #duração #Verificar
}
filenameN ()
{
	echo '{ "command": ["get_property", "playlist/'"$@"'/filename"], "request_id": 0}' |socat - $sock|sed -E 's/.*data":|,".*|\"//g' #nome/url do arquivo na pos $2 da playlist #Ajuste
}
filename ()
{
	echo '{ "command": ["get_property", "filename"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|"//g'
}
format ()
{
	if [[ -z $format ]]; then
		declare url=${${(s:|:)$(loadedx $(trackget))}[2]}
		format.url
		echo "set ytdl-format $format" |socat - $sock
		reload
	else
		echo "set ytdl-format $format" |socat - $sock
		reload
	fi
}
formatgo ()
{
    format=$@
    format
}
commands () #
{
	echo '{ "command": ["get_property", "command-list"], "request_id": 0}' |socat - $sock |sed -E 's/\{*:|,.*//'
}
next ()
{
	echo '{ "command": ["playlist-next", "force"], "request_id": 0}' |socat - $sock
}
stop ()
{
	echo 'stop' |socat - $sock #Funcional
	rm -f $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod
	kill $(< $mpid)
	polymsg.command &>/dev/null
}
trackgo () #
{
	< $tmpcod |read cod
	# cod=$@
	echo '{ "command": ["set_property", "playlist-pos-1", '"$cod"'], "request_id": 0}' |socat - $sock
}
track ()
{
	echo '{ "command": ["set_property", "playlist-pos-1", '"$1"'], "request_id": 0}' |socat - $sock
}
trackget ()
{
	echo '{ "command": ["get_property", "playlist-pos-1"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|\"//g;s/\{request_id\:0//g;s/\"playing\"\:true\}//g'
}
tracks ()
{
	echo '{ "command": ["get_property_string", "playlist-count"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|\"//g' #Nº faixas na Playlist Funcional
}
title ()
{
	echo '{ "command": ["get_property", "media-title"], "reqsuest_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|"//g' #titulo atual Funcional usado na polybar
}
titleN ()
{
	echo '{ "command": ["get_property_string", "playlist/'"$@"'/media-title"], "request_id": 0}' |socat - $sock|sed -E 's/.*data":|,".*|\"//g' #titulo do arquivo na pos $2 da playlist #Ajuste
}
prev ()
{
	echo '{ "command": ["playlist-prev", "force"], "request_id": 0}' |socat - $sock
}
position ()
{
	echo '{ "command": ["get_property", "time-pos"], "request_id": 0}' |socat - $sock #posição Verifica além de tudo se o socket está ativo
}
positionget ()
{
	echo '{ "command": ["set_property", "time-pos", '"$1"'], "request_id": 0}' |socat - $sock #posição Verifica além de tudo se o socket está ativo
}
remove ()
{
	trackremoved="$@"
	dunstify -t 5000 "Removed" "$trackremoved"
	echo "playlist-remove $(( $trackremoved - 1 ))" |socat - $sock #funcional
}
removeyad () #Argumentos
{
	remove "$(< $tmpcod)"
}
remaining () #
{
	echo '{ "command": ["set_property", "playtime-remaining"], "request_id": 0}' |socat - $sock #time restante Verificar
}
reload ()
{
	track "$(trackget)"
}
vol ()
{
	echo '{ "command": ["set_property", "volume", '"$@"'], "request_id": 0}' |socat - $sock #volume Funcional
}
playlist () #
{
	echo '{ "command": ["get_property", "playlist"], "request_id": 0}' |socat - $sock 2>/dev/null
}
status () #
{
	echo '{ "command": ["get_property", "playlist"], "request_id": 0}' |socat - $1
}
playlist.clear () 
{
	echo "playlist-clear" |socat - $sock #funcional
}
change () #
{
	echo '"change_list", "playlist/'$1'/title, set, '$2'"' |socat - $sock
}
teste () #
{
	echo '{ "command": ["get_property", "metadata/by-key/1"], "reqsuest_id": 0}' |socat - $sock
}
xclip_clipboard ()
{
    mp -x
}
