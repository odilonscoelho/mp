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
-bpl: -basepl: \
-bply: -baseplyad: \
-c! -controls! \
-cr! -controlsr! \
-console! \
-f! -format! \
-gs! -get-socks! \
-h! -help! \
-indice: \
-md: -modi: \
-mpd: \
-nx! -next! \
-p! -pause! -play! \
-pb! -polybar! \
-pv! -prev! \
-pl: -plist: \
-plr! -plistrofi! \
-ply: -plistyad: \
-rm: -remove: \
-rmy! -removeyad! \
-S! -Save! \
-svf: -save-file: \
-s: -sock: \
-st! -stop! \
-sf! -selfile! \
-t: -track: \
-tgo! -trackgo! \
-tget! -trackget! \
-tt: -title: \
-u: -url: \
-v: -vol: \
-x! -xclip! \
-tn: -titlen: \
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
		$ARGUMENTOS[titlen] || $ARGUMENTOS[tn] ) cmd+=(titleN $x) ;;
		$ARGUMENTOS[url] || $ARGUMENTOS[u] ) cmd+=(loaded url $x) ;;
		$ARGUMENTOS[vol] || $ARGUMENTOS[v] ) cmd+=(vol $x) ;;
		$ARGUMENTOS[xclip] || $ARGUMENTOS[x] ) clip=$(xclip -sel clipboard -o) ;;
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
if [[ -n $cmd ]]; then
	$cmd
fi

if [[ -z $cmd && -z $files && -z $m3us && -z $yads && -n $clip ]]; then
	case $clip in 
		https://* ) add "$clip";mp -mpd start;;
		http://* ) add "$clip";mp -mpd start;;
		* ) <<< "Não foi possível resolver '"$Clipboard"'" ;;
	esac
	unset clip
fi
if sock.ativo; then
	exit 0
else
	rm $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod $mpid 2>/dev/null
fi
