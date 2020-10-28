#!/bin/zsh

# Interval para mpd
interval () {sleep 1} #

# Import das funções...
. mpdef.zsh
. mpc.zsh
. mpd.zsh
. mpfn.zsh
. mplist.zsh

# TRATATIVA DE ARGUMENTOS
. allopts \
-bpl: -basepl: --basepl: \
-bply: -baseplyad: --baseplyad: \
-c! -controls! --controls! \
-cr! -controlsr! --controlsr! \
-console! --console! \
-f! -format! \
-gs! -get-socks! --get-socks! \
-h! -help! \
-indice: \
-md: -modi: --modi: \
-mpd: \
-nx! -next! --next! \
-p! -pause! --pause! -play! --play! \
-pb! -polybar! --polybar! \
-pv! -prev! --prev! \
-pl: -plist: --plist: \
-plr! -plistrofi! --plistrofi! \
-ply: -plistyad: --plistyad: \
-rm: -remove: --remove: \
-rmy! -removeyad! --removeyad! \
-S! -Save! --Save! \
-svf: -save-file: --save-file: \
-s: -sock: --sock: \
-st! -stop! --stop! \
-sf! -selfile! --selfile! \
-t: -track: --track: \
-tgo! -trackgo! --trackgo! \
-tget! -trackget! --trackget! \
-tt: -title: --title: \
-u: -url: --url: \
-v: -vol: --vol: \
-depur! \
$@

for i in $@
{
	[[ "$ARGREFUSED" =~ "$i" ]] && shift
}

for x in $ARGUMENTOS[@] 
{
	case $x in
		$ARGUMENTOS[basepl] || $ARGUMENTOS[bpl] ) cmd+=(basepl $x) ;;
		$ARGUMENTOS[baseplyad] || $ARGUMENTOS[bply] ) cmd+=(baseplyad $x) ;;
		$ARGUMENTOS[console] ) cmd+=(console) ;;
		$ARGUMENTOS[controls] || $ARGUMENTOS[c] ) cmd+=(controls) ;;
		$ARGUMENTOS[controlsr] || $ARGUMENTOS[cr] ) cmd+=(controls.rofi) ;;
		$ARGUMENTOS[format] || $ARGUMENTOS[f] ) cmd+=(format) ;;
		$ARGUMENTOS[help] || $ARGUMENTOS[h] ) cmd+=(help) ;;
		$ARGUMENTOS[getsocks] || $ARGUMENTOS[gs] ) cmd+=(get.socks) ;;
		$ARGUMENTOS[indice] ) cmd+=(indice.selected $x) ;;
		$ARGUMENTOS[mpd] ) cmd+=(mpd $x) ;;
		$ARGUMENTOS[modi] || $ARGUMENTOS[m] ) modi.def $x ;;
		$ARGUMENTOS[next] || $ARGUMENTOS[nx] ) cmd+=(next $x) ;;
		$ARGUMENTOS[prev] || $ARGUMENTOS[pv] ) cmd+=(prev $x) ;;
		$ARGUMENTOS[play] || $ARGUMENTOS[pause] || $ARGUMENTOS[p] ) cmd+=(pause.toggle) ;;
		$ARGUMENTOS[polybar] || $ARGUMENTOS[pb] ) cmd+=(poly.title) ;;
		$ARGUMENTOS[plist] || $ARGUMENTOS[pl] ) cmd+=(plist $x) ;;
		$ARGUMENTOS[plistrofi] || $ARGUMENTOS[plr] ) cmd+=(plistrofi null) ;;
		$ARGUMENTOS[plistyad] || $ARGUMENTOS[ply] ) cmd+=(plistyad $x) ;;
		$ARGUMENTOS[remove] || $ARGUMENTOS[rm] ) cmd+=(remove $x) ;;
		$ARGUMENTOS[removeyad] || $ARGUMENTOS[rmy] ) cmd+=(removeyad) ;;
		$ARGUMENTOS[Salve] || $ARGUMENTOS[S] ) cmd+=(save $x) ;;
		$ARGUMENTOS[savefile] || $ARGUMENTOS[svf] ) cmd+=(save $x) ;;
		$ARGUMENTOS[sock] || $ARGUMENTOS[s] ) 
			declare -x sock="/tmp/mpvsocket$x"
		 	declare -x mpurls="/tmp/mpurls$x"
		 	declare -x mpurlsold="/tmp/mpurlsold$x"
		 	declare -x mptitles="/tmp/mptitles$x"
		 	declare -x mplistyad="/tmp/plistyad$x"
		 	declare -x tmpcod="/tmp/mpcod$x"
		 	declare -x mpid="/tmp/mpid$x" ;;
		$ARGUMENTOS[selfile] || $ARGUMENTOS[sf] ) cmd+=(select.file) ;; 	
		$ARGUMENTOS[stop] || $ARGUMENTOS[st] ) cmd+=(stop) ;;
		$ARGUMENTOS[trackgo] || $ARGUMENTOS[tgo] ) cmd+=(trackgo) ;;
		$ARGUMENTOS[trackget] || $ARGUMENTOS[tget] ) cmd+=(trackget) ;;
		$ARGUMENTOS[track] || $ARGUMENTOS[t] ) cmd+=(track $x) ;;
		$ARGUMENTOS[title] || $ARGUMENTOS[tt] ) cmd+=(loaded title $x) ;;
		$ARGUMENTOS[url] || $ARGUMENTOS[u] ) cmd+=(loaded url $x) ;;
		$ARGUMENTOS[vol] || $ARGUMENTOS[v] ) cmd+=(vol $x) ;;
		$ARGUMENTOS[depur] ) cmd+=(playlist) ;;
		esac
}

if [[ ! $cmd =~ "get.socks" ]]; then	
	[[ -z $sock ]] && declare -x sock=/tmp/mpvsocketDefault
	[[ -z $mpurls ]] && declare -x mpurls=/tmp/mpurlsDefault
	[[ -z $mpurlsold ]] && declare -x mpurlsold=/tmp/mpurlsoldDefault
	[[ -z $mptitles ]] && declare -x mptitles=/tmp/mptitlesDefault
	[[ -z $mplistyad ]] && declare -x mplistyad=/tmp/plistyadDefault
	[[ -z $tmpcod ]] && declare -x tmpcod="/tmp/mpcodDefault"
	[[ -z $mpid ]] && declare -x mpid="/tmp/mpidDefault"
else
	get.socks || print "Não há socks ativos!" 2>/dev/null
	exit 0
fi

for arg in $@
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
		else
			case $arg in 
				https://* ) add "$(xclip -sel clipboard -o)";mp -mpd start;;
				http://* ) add "$(xclip -sel clipboard -o)";mp -mpd start;;
				* ) <<< "Não foi possível resolver '"$arg"'" ;;
			esac
			shift
		fi
	fi
}

if [[ -n $m3us ]]; then
	add $m3us[@]
	mp -mpd start
fi		
if [[ -n $files ]]; then
	add $files[@]
	mp -mpd start
fi
if [[ -n $yads ]]; then
	add ${(s:!:)yads[@]}
	mp -mpd start
fi	
Clipboard="$(xclip -sel clipboard -o)"
if [[ -z $cmd && -z $files && -z $m3us && -z $yads && -n $Clipboard ]]; then
	case $Clipboard in 
		https://* ) add "$(xclip -sel clipboard -o)";mp -mpd start;;
		http://* ) add "$(xclip -sel clipboard -o)";mp -mpd start;;
		* ) <<< "Não foi possível resolver '"$Clipboard"'" ;;
	esac
fi
if [[ -n $cmd ]]; then
	$cmd
fi
if sock.ativo; then
	exit 0
else
	rm $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod $mpid 2>/dev/null
fi
