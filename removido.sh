if [[ -z "$(grep ".m3u" <<< "$@")" && -f $1 ]]; then
	[[ $# -gt 1 ]] && \
		{
			add "$1" 2>/dev/null
			mp mpd start
			shift 1
			add $@
			exit 0
		} || \
			{
				declare -x url="$@"
				add "$url" 2>/dev/null
				mp mpd start
			}
elif [[ -n "$(grep ".m3u" <<< "$@")" && -f $1 ]]; then
	[[ $# -gt 1 ]] && \
		{
			add "$1" 2>/dev/null
			mp mpd start
			shift 1
			add $@
			exit 0
		} || \
			{
				declare -x url="$@"
				add "$url" 2>/dev/null
				mp mpd start
			}
elif [[ $1 =~ "poly.title" ]]; then
	poly.title $2
	exit 0
elif [[ $1 == "search" || $1 == "searchg" ]]; then
	$@
else
	[[ -z $1 ]] && declare -x url="$(xclip -sel clipboard -o)" || declare -x url=($@)
	case $url in
		stop ) 
			stop
			polybar-msg hook mpv 1
			rm -f $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod
			[[ -z `get.socks` ]] && pkill mpv ;;
		clear) 			
			stop
			polybar-msg hook mpv 1
			rm -f $sock $mpurls $mpurlsold $mptitles $mplistyad $tmpcod ;;
			# [[ -z `get.socks` ]] && pkill mpv 
		add.to* ) add.to $2 $3;;
		playlist ) playlist;;
		playlist.clear ) playlist.clear;;
		plistyad* ) plistyad $2;;
		plist* ) plist $2;;
		mpd ) $@ &>/dev/null &;;
		mpd* ) $@;;
		change* ) $@;;
		trackget ) trackget;;
		format.url* ) 
			url="$(test.loaded url $2)"
			format.url
			format;;
		format ) 
			if [[ -z $format ]]; then
				url="$(test.loaded url $(trackget))"
				format.url
				format
				reload
			else
				format
				reload
			fi;;
		get.title* ) get.title $2;; # Verificar impactos!
		removeyad ) remove "$(< $tmpcod)";;
		basepl* || baseplyad || commands || controls || duration || get.socks || \
		filenameN* || filename || indice.selected* || get.title* || list* || msg* || next || \
		pause.toggle || prev || play.best || plistyad || plistyarg* || \
		position* || select.file* || save* || status || remove* || sock.ativo || sock* || \
		title || test* || trackgo* || track* || tracks || titleN* || url* || vol* || volume* || reload ) $@ 2&>/dev/null &;;
		https://* ) add.url $url;mp mpd start;;
		http://* ) add.url $url;mp mpd start;;
		# O único separador válido para os yads de seleção de arquivos, é '!' 
		 *!* ) sock.ativo && { add.yad; mp mpd start }|| { add.yad.clear; mp mpd start };;
		* ) msg "
		Não foi possível resolver o
		argumento ou arquivo/url...
			$url 
				";;
	esac
fi