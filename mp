#!/bin/zsh
# Import das funções...
 . mp.conf
 . mpdef.zsh
 . mpc.zsh
 . mpd.zsh
 . mpfn.zsh
 # . mplist.zsh
. mplist.local.zsh # meus themes Depur
# Verifica se recebeu argumentos via pipe:
if [[ -p /dev/stdin ]]; then
	pipeArgs=(${(f)"$(cat -)"})
fi
# Tratativa de argumentos:
# Array para opções que recebem argumentos 
args=("-cmd" "--cmd" "-depur" "--depur" "--format-go" "-fmtgo" "--indice" "-indice" "--mpd" "-mpd" "--remove" "-rm" "--save-as" "-sas""-s" "--sock" "--source-file" "-sfile" "--track" "-track" "--title-n" "-tn" "--url-n" "-un" "--vol" "-v" "--iptv" "-iptv")
# Array para opções que não recebem argumentos
bool=("--controls" "-c" "--controlsr" "-cr" "--console" "-console" "--format" "-fmt" "--get-socks" "-gs" "--get-thumb" "-gt" "--help" "-h" "--next" "-next" "--pause" "-pause" "--playlist" "-pl" "--playlist-rofi" "-plr" "--playlist-yad" "-ply" "--prev" "-prev" "--polybar" "-pb" "--save" "-sv" "--search" "-search" "--select-file" "-sf" "--stop" "-stop" "--track-get" "-tget" "--title" "-title" "--xclip" "-x" "--plistiptv" "-pli")
# Associação de parâmetros recebidos aos arrays, 
# Cada possível parâmetro será salvo em uma variável
# de mesmo nome do parâmetro, parâmetros que não
# recebem argumentos serão salvos como "true"
for arg in $@
{
	(( control = control + 1 ))

	nextArgv="${(P)$((control+1))}"

	if [[  $args =~ $arg ]];then
		for ARG in $args[@]
		{
			[[ "$ARG" == "$arg" ]] && { read ${arg//-/} <<< $nextArgv; ignoreds+=($nextArgv); break }
		}
	elif [[ $args =~ ${${(s:=:)arg}[1]} ]];then
		for ARG in $args[@]
		{
			[[ "$ARG" == "${${(s:=:)arg}[1]}" ]] && { read "${${(s:=:)${arg//-/}}[1]}" <<< "${${(s:=:)arg}[2,-1]}"; ignoreds+=($arg); break }
		}
	fi

	if [[ $bool =~ $arg ]];then
	    for ARG in $bool[@]
	    {
	        [[ "$ARG" == "$arg" ]] && { read "${arg//-/}" <<< "true"; ignoreds+=($arg) }
	    }
	fi
	
	[[ "$ignoreds" =~ "$arg" ]] && continue || urls+=("$arg")
}
# Verifica se foi informado sock para a sessão, caso não, atribui os temp files defatult à sessão única
# Analisar se realmente vai manter suporte a multi socks ativos, sinceramente não vejo necessidade
[[ -n $sock || -n $s ]] &&
    {
        [[ -z $sock ]] && sock=$s
        declare -x sock="/tmp/mpvsocket$sock"
        declare -x mpurls="/tmp/mpurls$sock"
        declare -x mpurlsold="/tmp/mpurlsold$sock"
        declare -x mptitles="/tmp/mptitles$sock"
        declare -x mplistyad="/tmp/plistyad$sock"
        declare -x tmpcod="/tmp/mpcod$sock"
        declare -x mpid="/tmp/mpid$sock"
    } ||
        {
            declare -x sock="/tmp/mpvsocket"
            declare -x mpurls="/tmp/mpurls"
            declare -x mpurlsold="/tmp/mpurlsold"
            declare -x mptitles="/tmp/mptitles"
            declare -x mplistyad="/tmp/plistyad"
            declare -x tmpcod="/tmp/mpcod"
            declare -x mpid="/tmp/mpid"
        }
# Valida os argumentos soltos que podem ser arquivos ou urls para reprodução e atribui ao array correto para execução:
for arg in $urls
{
	if [[ -f $arg || $arg =~ ^http[s]?:// ]]; then
		if [[ $arg =~ '.m3u$' ]]; then
			m3us+=("$arg")
			shift
		else
			files+=("$arg")
			shift
		fi
	else
		if [[ $arg =~ '!' ]]; then
			yads+=("$arg")
			shift
		fi
	fi
}
# Verifica se os array correspondente a cada tipo de arquivo está vazio, se houver valores esses serão executados e uma chamada para o mpd start para iniciar o daemon caso esteja desligado:
if [[ -n $pipeArgs ]]; then
	add $pipeArgs[@] 2>/dev/null
	mpd start 2>/dev/null
fi
if [[ -n $m3us ]]; then
	add $m3us[@] 2>/dev/null
	mpd start 2>/dev/null
fi
if [[ -n $files ]]; then
	add $files[@] 2>/dev/null
	mpd start 2>/dev/null
fi
if [[ -n $yads ]]; then
	add ${${(s:!:)yads}[@]} 2>/dev/null
	mpd start 2>/dev/null
fi
#Para xclip:
[[ -n $xclip || -n $x ]] && clip="$(xclip -selection clipboard -o)"
if [[ -n $clip ]]; then
	case $clip in
		http* ) add $clip; mpd start;;
		* ) printf '%s\n' "Não foi possível resolver '"$clip"'" ;;
	esac
	unset clip
fi
# Valida se há comandos a serem executados e os executa:
[[ -n ${help:=$h} ]] && help 2> /dev/null
[[ -n $mpd ]] && mpd $mpd 2>/dev/null
[[ -n $next ]] && next 2>/dev/null
[[ -n $prev ]] && prev 2> /dev/null
[[ -n $pause ]] && pause.toggle 2> /dev/null
[[ -n ${polybar:=$pb} ]] && poly.title 2>/dev/null 
[[ -n $indice ]] && indice.selected $indice 2> /dev/null
[[ -n ${save:=$sv} ]] && save 2> /dev/null
[[ -n ${search:=$sc} ]] && search 2> /dev/null
[[ -n ${saveas:=$sas} ]] && save $saveas 2> /dev/null
[[ -n ${selectfile:=$sf} ]] && select.file 2> /dev/null
[[ -n ${sourcefile:=$sfile} ]] && source.file ${sourcefile} 2> /dev/null
[[ -n $stop ]] && { stop ; pkill mpv } 2> /dev/null
[[ -n ${remove:=$rm} ]] && remove ${remove} 2> /dev/null
[[ -n $track ]] && track $track 2> /dev/null
[[ -n ${trackget:=$tget} ]] && trackget 2> /dev/null
[[ -n ${titlen:=$tn} ]] && titleN ${titlen} 2> /dev/null
[[ -n ${urln:=$un} ]] && filenameN ${urln} 2> /dev/null
[[ -n ${vol:=$v} ]] && vol ${vol} 2> /dev/null
[[ -n $depur ]] && $depur 2> /dev/null
[[ -n $cmd ]] && ${(s: :)cmd} 2> /dev/null
[[ -n $console ]] && console 2> /dev/null
[[ -n ${controls:=$c} ]] && controls 2> /dev/null
[[ -n ${controlsr:=$cr} ]] && controlsr 2> /dev/null
[[ -n ${format:=$fmt} ]] && format 2> /dev/null
[[ -n ${formatgo:=$fmtgo} ]] && formatgo ${formatgo} 2> /dev/null
[[ -n ${getthumb:=$gt} ]] && get.thumb 2> /dev/null
[[ -n ${playlist:=$pl} ]] && pl 2> /dev/null
[[ -n ${playlistrofi:=$plr} ]] && plistrofi 2> /dev/null
[[ -n ${playlistyad:=$ply} ]] && plistyad 2> /dev/null
[[ -n ${plistiptv:=$pli} ]] && plistiptv 2>/dev/null
[[ -n $iptv ]] && 
{
    add "$iptv" 2>/dev/null
    interval
    loadedx > $mpurls
}
# Finaliza e verifica se o sock usado na chamada do programa está ativo, estando ativo, apenas encerra a chamada, se não limpa os temp files alocados para o sock:
if sock.ativo; then
	exit 0
else
	rm $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod $mpid /tmp/mplog /tmp/thumb.jpg &>/dev/null
fi

