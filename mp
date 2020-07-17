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
interval () {sleep 2}
# Declaração do path do projeto
declare -x path_mp=/home/losaoall/hdbkp/projetos/shell/mp/
# Declaração do path de playlist, verificar isso, acho desnecessário.
declare -x path_playlist=$HOME/hdbkp/playlist
# Arquivos temporários
declare -x selcod=$(mktemp)
declare -x seltit=$(mktemp)
declare -x tmpcod="/tmp/mpcod"
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Import das funções...
. $path_mp/mpdef
. $path_mp/mpc
. $path_mp/mpd
. $path_mp/mpfn
. $path_mp/mplist
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

if [[ -z "$(grep ".m3u" <<< "$@")" && -f $1 ]]; then
  sock
  print "Is File!"
  declare -x url=($@)
  add $url 2>/dev/null
  exit 0
elif [[ -n "$(grep ".m3u" <<< "$@")" && -f $1 ]]; then
  sock
  print "Is M3U!"
  declare -x url="$@"
  add.m3u 2>/dev/null
  exit 0
elif [[ $1 =~ "poly.title" ]]; then
  poly.title
  exit 0
else
  sock
  [[ -z $1 ]] && declare -x url="$(xclip -sel clipboard -o)" || declare -x url=$@
  case $url in
    clear.files) sock; stop; rm -f $sock /tmp/mpurls /tmp/mptitles; pkill mpv; return 0;;
    playlist ) sock; playlist;;
    plistyad* )
      sock
      case $2 in
        force) declare -x url="force"; plistyad force;;
        event) declare -x url="event"; plistyad event;;
        ajuste ) declare -x url="ajuste";plistyad ajuste;;
        *) declare -x url="null"; plistyad null;;
      esac;;
    plist* ) 
      sock
      case $2 in
        force ) declare -x url="force";plist force;;
        event ) declare -x url="event";plist event;;
        ajuste ) declare -x url="ajuste";plist ajuste;;
        * ) declare -x url="null";plist null;;
      esac;;
    mpd ) $@ &>/dev/null &;;
    mpd* ) $@;;
    change* ) $@;;
    trackget ) trackget;;
    format.url* ) declare -x url="$(filenameN $2)"; format.url; format;;
    get.title* ) get.title $url;; # Verificar impactos!
    basepl || baseplyad || commands || controls || duration || format* || \
    filenameN* || filename || indice.selected* || get.title* || list* || msg* || next || \
    pause.toggle || prev || play.best || plistyad || plistyarg* || \
    position* || select.file* || save || status || stop || remove* || removego* || sock.ativo || sock* || \
    title || test* || trackgo* || track* || tracks || titleN* || url* || vol* || volume* || reload ) $@ 2&>/dev/null &;;
    https://* ) sock; add.url;;
    http://* ) sock; add.url;;
    # O único separador válido para os yads de seleção de arquivos, é '!' 
     *!* ) sock; sock.ativo && add.yad|| add.yad.clear;;
    * ) msg "
    Não foi possível resolver o
    argumento ou arquivo/url...
        ! $url !";;
  esac
fi
exit 0
rm -f $selcod $seltit $tmpcod