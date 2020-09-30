#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# verificar pois pode exminir muitos comandos clear, atualmente usado só em local file 'lfs'.
add ()
{
  if sock.ativo; then
    print "add"
    for arg in $@
    {
      echo '{ "command": ["loadfile", "'"$arg"'", "append-play"], "request_id": 0}' |socat - $sock & #adicionar File individualmente
    }
  else
    print "add.clear"
    rm -f $sock
    mpv $@ --input-ipc-server=$sock &> /dev/null &
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.yad () 
{
  wq notificatime 5000 "YADs requisitado"
  print "add.yad"
  if [[ ${#${(s:!:)url}} -ne 1 ]]; then
    urlx="$(print $url|sed 's/\!/\n/g'|grep -Ev '^$')"
    for (( i=1; i<=${#${(f)urlx}}; i++ ));do
      echo '{ "command": ["loadfile", "'${${(f)urlx}[$i]}'", "append-play"], "request_id": 0}' |socat - $sock &
    done
  else
      urlx="$(echo $url|sed 's/\!//g')"
      echo '{ "command": ["loadfile", "'$urlx'", "append-play"], "request_id": 0}' |socat - $sock &
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.yad.clear ()
{ 
  wq notificatime 5000 "YADs clear requisitado"
  print "add.yad.clear"
  rm -f $sock
  mpv ${(s:!:)url} --input-ipc-server=$sock &> /dev/null &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.url ()
{
  if sock.ativo; then
    print "add"
    for arg in $@
    {
      echo '{ "command": ["loadfile", "'"$arg"'", "append-play"], "request_id": 0}' |socat - $sock & #adicionar File individualmente
    }
  else
    rm -f $sock
    mpv "$1" --input-ipc-server=$sock &> /dev/null &
    shift 1
    for arg in $@
    {
      echo '{ "command": ["loadfile", "'"$arg"'", "append-play"], "request_id": 0}' |socat - $sock & #adicionar File individualmente
    }
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.url.clear ()
{
  print "add.url.clear"
  rm -f $sock 
  mpv \
  --x11-name="$new_class" \
  --ytdl-format=$format $url \
  --input-ipc-server=$sock &> /dev/null &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.m3u ()
{ 
  if [[ $(test.loaded url) ]]; then
    print "add.m3u"
    echo '{ "command": ["loadfile", "'$url'", "append-play"], "request_id": 0}' |socat - $sock & #adiciona playlist
  else
    print "add.m3u.clear"
    rm -f $sock
    mpv $url \
    --input-ipc-server=$sock &> /dev/null &
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
add.m3u.clear ()
{
  print "add.m3u.clear"
  rm -f $sock
  mpv $url \
  --input-ipc-server=$sock &> /dev/null &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
duration ()
{
  echo '{ "command": ["get_property", "duration"], "request_id": 0}' |socat - $sock |sed -E 's/.*data\":|,\".*//g' #duração #Verificar
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
filenameN () #Argumentos
{
  echo '{ "command": ["get_property", "playlist/'"$@"'/filename"], "request_id": 0}' |socat - $sock|sed -E 's/.*data":|,".*|\"//g' #nome/url do arquivo na pos $2 da playlist #Ajuste
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
filename () 
{
  echo '{ "command": ["get_property", "filename"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|"//g'
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
format ()
{
  echo "set ytdl-format $format" |socat - $sock
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
commands ()
{
  echo '{ "command": ["get_property", "command-list"], "request_id": 0}' |socat - $sock |sed -E 's/\{*:|,.*//'
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
next ()
{ 
  echo '{ "command": ["playlist-next", "force"], "request_id": 0}' |socat - $sock
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
stop ()
{
  echo 'stop' |socat - $sock #Funcional
  # rm /tmp/mptitles
  # playlist > /tmp/mpsession
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
trackgo () #Argumentos , usada apenas pela playlist.yad
{
  < /tmp/mpcod |read cod
  echo '{ "command": ["set_property", "playlist-pos-1", '"$cod"'], "request_id": 0}' |socat - $sock
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
track () #Argumentos
{
  echo '{ "command": ["set_property", "playlist-pos-1", '"$1"'], "request_id": 0}' |socat - $sock
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
trackget () #Argumentos
{
  echo '{ "command": ["get_property", "playlist-pos-1"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|\"//g;s/\{request_id\:0//g;s/\"playing\"\:true\}//g'
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
tracks ()
{
  echo '{ "command": ["get_property_string", "playlist-count"], "request_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|\"//g' #Nº faixas na Playlist Funcional
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
title ()
{
  echo '{ "command": ["get_property", "media-title"], "reqsuest_id": 0}' |socat - $sock |sed -E 's/.*data":|,".*|"//g' #titulo atual Funcional usado na polybar
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
titleN () #Argumentos
{ 
  echo '{ "command": ["get_property_string", "playlist/'"$@"'/media-title"], "request_id": 0}' |socat - $sock|sed -E 's/.*data":|,".*|\"//g' #titulo do arquivo na pos $2 da playlist #Ajuste
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
prev ()
{
  echo '{ "command": ["playlist-prev", "force"], "request_id": 0}' |socat - $sock
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
position ()
{
  echo '{ "command": ["get_property", "time-pos"], "request_id": 0}' |socat - $sock #posição Verifica além de tudo se o socket está ativo
}
positionget ()
{
  echo '{ "command": ["set_property", "time-pos", '"$1"'], "request_id": 0}' |socat - $sock #posição Verifica além de tudo se o socket está ativo
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
remove () #Argumentos
{
  trackremoved="$@"
  trackremovedyad1="$(( $trackremoved * 2 ))"
  trackremovedyad2="$(( $trackremovedyad1 - 1 ))"
  dstfy "$trackremoved"
  echo "playlist-remove $(( $trackremoved - 1 ))" |socat - $sock #funcional
  sed -i $trackremoved'd' $mptitles
  sed -i ''$trackremovedyad2','$trackremovedyad1'd' $mplistyad
  baseplyad removed 
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
removeyad () #Argumentos
{
  # trck="$(< $tmpcod)"
  # dstfy "RemoveYad $trck"
  remove "$(< $tmpcod)"
  # echo "playlist-remove $(( $trck - 1 ))" |socat - $sock & #funcional
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
remaining ()
{ 
  echo '{ "command": ["set_property", "playtime-remaining"], "request_id": 0}' |socat - $sock #time restante Verificar
}
reload ()
{ 
  track "$(trackget)"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
vol ()
{
  echo '{ "command": ["set_property", "volume", '"$@"'], "request_id": 0}' |socat - $sock #volume Funcional
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
playlist ()
{
  echo '{ "command": ["get_property", "playlist"], "request_id": 0}' |socat - $sock #2>/dev/null
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
status ()
{
  echo '{ "command": ["get_property", "playlist"], "request_id": 0}' |socat - $1
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
playlist.clear () 
{
  echo "playlist-clear" |socat - $sock #funcional
}
change ()
{
  # echo '{ "command": ["change_list", "playlist/'"$1"'/media-title" , "set", '"$2"'], "request_id": 0}' |socat - $1
  echo '"change_list", "playlist/'$1'/title, set, '$2'"' |socat - $sock  
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#