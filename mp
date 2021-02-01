#!/bin/zsh
# Import das funções...
. mp.conf
. mpdef.zsh
. mpc.zsh
. mpd.zsh
. mpfn.zsh
. mplist.zsh
#. mplist.local.zsh # meus themes Depur
# Verifica se recebeu argumentos via pipe:
if [[ -p /dev/stdin ]]; then
	pipeArgs=(${(f)"$(cat -)"})
fi
# Tratativa de argumentos:
args=("-cmd" "--cmd" "--format-go" "-fmtgo" "--indice" "-indice" "--mpd" "-mpd" "--remove" "-rm" "--save-as" "-sas""-s" "--sock" "--source-file" "-sfile" "--track" "-track" "--title-n" "-tn" "--url-n" "-un" "--vol" "-v")

bool=("--controls" "-c" "--controlsr" "-cr" "--console" "-console" "--format" "-fmt" "--get-socks" "-gs" "--get-thumb" "-gt" "--help" "-h" "--next" "-next" "--pause" "-pause" "--playlist" "-pl" "--playlist-rofi" "-plr" "--playlist-yad" "-ply" "--prev" "-prev" "--polybar" "-pb" "--save" "-sv" "--search" "-search" "--select-file" "-sf" "--stop" "-stop" "--track-get" "-tget" "--title" "-title" "--xclip" "-x")

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

[[ -n $cmd ]] && cmd+=(${(s: :)cmd};)
[[ -n $console ]] && cmd+=(console;)
[[ -n ${controls:-$c} ]] && cmd+=(controls;)
[[ -n ${controlsr:-$cr} ]] && cmd+=(controlsr;)
[[ -n ${format:-$fmt} ]] && cmd+=(format;)
[[ -n $formatgo || -n $fmtgo ]] && cmd+=(formatgo ${formatgo:-$fmtgo};)
[[ -n ${getthumb:-$gt} ]] && cmd+=(get.thumb;)
[[ -n ${getsocks:-$gs} ]] && cmd+=(get.socks;)
[[ -n ${help:-$h} ]] && cmd+=(help;)
[[ -n $indice ]] && cmd+=(indice.selected $indice;)
[[ -n $mpd ]] && cmd+=(mpd $mpd;)
[[ -n $next ]] && cmd+=(next;)
[[ -n $pause ]] && cmd+=(pause.toggle;)
[[ -n ${playlist:-$pl} ]] && cmd+=(pl;)
[[ -n ${playlistrofi:-$plr} ]] && cmd+=(plistrofi;)
[[ -n ${playlistyad:-$ply} ]] && cmd+=(plistyad;)
[[ -n $prev ]] && cmd+=(prev;)
[[ -n ${polybar:-$pb} ]] && cmd+=(poly.title;)
[[ -n ${save:-$sv} ]] && cmd+=(save;)
[[ -n ${search:-$sc} ]] && cmd+=(search;)
[[ -n ${saveas:-$sas} ]] && cmd+=(save $saveas;)
[[ -n ${selectfile:-$sf} ]] && cmd+=(select.file;)
[[ -n $sock || -n $s ]] && 
    {
        [[ -n $sock ]] && x=$sock || x=$s
        declare -x sock="/tmp/mpvsocket$x"
        declare -x mpurls="/tmp/mpurls$x"
        declare -x mpurlsold="/tmp/mpurlsold$x"
        declare -x mptitles="/tmp/mptitles$x"
        declare -x mplistyad="/tmp/plistyad$x"
        declare -x tmpcod="/tmp/mpcod$x"
        declare -x mpid="/tmp/mpid$x"        
    }
[[ -n $sourcefile || -n $sfile ]] && cmd+=(source.file ${sourcefile:-$sfile};)
[[ -n $stop ]] && cmd+=(stop;)
[[ -n $remove || -n $rm ]] && cmd+=(remove ${remove:-$rm};)
[[ -n $track ]] && cmd+=(track $track;)
[[ -n $trackget || -n $tget ]] && cmd+=(trackget;)
[[ -n $titlen || -n $tn ]] && cmd+=(;titleN ${titlen:-$tn};)
[[ -n $urln || -n $un ]] && cmd+=(filenameN ${urln:-$un};)
[[ -n $vol || -n $v ]] && cmd+=(vol ${vol:-$v};)
[[ -n $xclip || -n $x ]] && clip="$(xclip -selection clipboard -o)"
# Confirma se a solicitaçao de comando é a requisição de informações sobre os socks abertos, caso seja não atribui temp files a essa solicitação:
if [[ ! $cmd =~ "get.socks" ]]; then
	[[ -z $sock ]] && sock=/tmp/mpvsocketDefault
	[[ -z $mpurls ]] && mpurls=/tmp/mpurlsDefault
	[[ -z $mpurlsold ]] && mpurlsold=/tmp/mpurlsoldDefault
	[[ -z $mptitles ]] && mptitles=/tmp/mptitlesDefault
	[[ -z $mplistyad ]] && mplistyad=/tmp/plistyadDefault
	[[ -z $tmpcod ]] && tmpcod="/tmp/mpcodDefault"
	[[ -z $mpid ]] && mpid="/tmp/mpidDefault"
else
	get.socks || print "Não há socks ativos!"
	exit 0
fi
# Valida os argumentos soltos que podem ser arquivos ou urls para reprodução e atribui ao array correto para execução:
for arg in $urls
{
	if [[ -f $arg ]]; then
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
	add $pipeArgs[@]
	mp -mpd start
fi
if [[ -n $m3us ]]; then
	add $m3us[@]
	mp -mpd start
fi
if [[ -n $files ]]; then
	add $files[@]
	mp -mpd start
fi
if [[ -n $yads ]]; then
	add ${${(s:!:)yads}[@]}
	mp -mpd start
fi
# Para xlip:
if [[ -n $clip ]]; then
	case $clip in
		https://* ) add "$clip";mp -mpd start;;
		* ) printf '%s\n' "Não foi possível resolver '"$clip"'" ;;
	esac
	unset clip
fi
# Valida se há comandos a serem executados e os executa:
if [[ -n $cmd ]]; then
    $cmd
fi
# Finaliza e verifica se o sock usado na chamada do programa está ativo, estando ativo, apenas encerra a chamada, se não limpa os temp files alocados para o sock:
if sock.ativo; then
	exit 0
else
	rm $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod $mpid /tmp/mplog /tmp/thumb.jpg 2>/tmp/null
fi
