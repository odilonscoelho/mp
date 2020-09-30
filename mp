#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Dependências :
# mpv
# Fonte - Open Sans Condensed => para os ícones da playlist, pode ser substituída por outra que tenha
#                        os glifos necessários, qualquer pack Nerd Font deve suprir!
# xclip
# xclipboard
# zsh => Não precisa ser o shell padrão do usuário!
# yad => ainda obrigatório para escolher a resolução dos vídeos do youtube
#        mas pode facilmente ser retirado do código ou implementado para printar no terminal

# Interval para mpd
interval () {sleep 1}
# Declaração do path do projeto
declare -x path_mp=/home/losaoall/hdbkp/projetos/shell/mp/
# Declaração do path de playlist, verificar isso, acho desnecessário.
declare -x path_playlist=$HOME/hdbkp/playlist
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Import das funções...
. $path_mp/mpdef.zsh
. $path_mp/mpc.zsh
. $path_mp/mpd.zsh
. $path_mp/mpfn.zsh
. $path_mp/mplist.zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
if [[ "$1" == "--sock" ]]; then
  declare -x name="$2"
  declare -x sock="/tmp/mpvsocket$name"
  declare -x mpurls="/tmp/mpurls$name"
  declare -x mpurlsold="/tmp/mpurlsold$name"
  declare -x mptitles="/tmp/mptitles$name"
  declare -x mplistyad="/tmp/plistyad$name"
  declare -x tmpcod="/tmp/mpcod$name"
  shift 2
elif [[ "$1" == "sock" ]]; then
  sock
  declare -x mpurls="/tmp/mpurls$name"
  declare -x mpurlsold="/tmp/mpurlsold$name"
  declare -x mptitles="/tmp/mptitles$name"
  declare -x mplistyad="/tmp/plistyad$name"
  declare -x tmpcod="/tmp/mpcod$name"
  shift 1
else
  declare -x sock=/tmp/mpvsocket
  declare -x mpurls=/tmp/mpurls
  declare -x mpurlsold=/tmp/mpurlsold
  declare -x mptitles=/tmp/mptitles
  declare -x mplistyad=/tmp/plistyad
  declare -x tmpcod="/tmp/mpcod"
fi

if [[ -z "$(grep ".m3u" <<< "$@")" && -f $1 ]]; then
  [[ $# -gt 1 ]] && \
    {
      # declare -x url=($@)
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
else
  sock
  [[ -z $1 ]] && declare -x url="$(xclip -sel clipboard -o)" || declare -x url=($@)
  case $url in
    stop ) pkill mpv; stop; polybar-msg hook mpv 1; rm -f $mptitles; pkill mpv ;;
    clear) pkill mpv; stop; polybar-msg hook mpv 1; rm -f $mptitles; pkill mpv ;;
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
    removeyad ) declare -x tmpcod="/tmp/mpcod"; remove "$(< $tmpcod)";;
    basepl* || baseplyad || commands || controls || duration || \
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
        ! $url !";;
  esac
fi
exit 0
