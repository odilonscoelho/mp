#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
save () #reformular
{
  [[ -z $1 ]] && file="$(select.file save)" || file=$1
  [[ -z $file ]] && msg "Operação cancelada ! PLaylist não Salva!"
  [[ -d $file ]] && msg "Operação cancelada ! PLaylist não Salva! Foi selecionado apenas o diretório"
  t=1;while read line; do; export title[$t]=$line;t=$t+1;done < /tmp/mptitles
  echo "#EXTM3U" >| $file
  i=1
  while read line
  do
    echo "#EXTINF:'" "', $line\n$(< /tmp/mpurls| sed -n ''$i'p')" >> $file &&
    i=$(( $i + 1 ))
  done < /tmp/mptitles
  dstfy "$file"
}

add.to ()
{
  if [[ $1 =~ "essa" ]]; then
    url=$(test.loaded url "$(trackget)")
    title=$(test.loaded title "$(trackget)")
  else
    url=$(test.loaded url $1)
    url=$(test.loaded title $1)
  fi
  if [[ -z $2 ]]; then
    file="$(select.file save)"
    [[ -z $file ]] && msg "Operação cancelada ! PLaylist não Salva!"
    [[ -d $file ]] && msg "Operação cancelada ! PLaylist não Salva! Foi selecionado apenas o diretório"
  else
    file="$2"
  fi
  [[ -z $title ]] && title=$(test.loaded title.iptv $1)
  [[ -z $title ]] && title=$(get.title $1)
  
  echo "#EXTINF:' ', $title\n"$url"" >> $file
  exit 0
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
select.file () #Argumentos
{
  [[ -z $1 ]] && \
    file="$(yad --separator="!" --text="Select files....$ _>" --file --multiple --geometry=600x800)" && \
      [[ -n $file ]] && mp "$file" #url file &&
  [[ -n $1 ]] && yad --text="Select files....$\_>" --file --multiple --save
}
#--------------------------------------------------\---------------------------------------------------------------------------------------------------------------------------------------------------#
play.best ()
{
  [[ -n $(test.loaded url) ]] && add.url || rm -f $sock && mpv --x11-name="$new_class" $url --input-ipc-server=$sock &
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
pause.toggle () #Argumentos
{
  if [[ $(echo '{ "command": ["get_property", "pause"] }' |socat - $sock |grep 'true') ]];then
    echo '{ "command": ["set_property", "pause", false] }' |socat - $sock
  else
    echo '{ "command": ["set_property", "pause", true] }' |socat - $sock
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
msg () #Argumentos
{
  yad --form --button=yad-ok --borders=5 --mouse --geometry=700x300 --title "Information:" --field=CONTEUDO:TXT "$@"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
poly.title ()
{
  if sock.ativo; then
    if [[ $(playlist |sed 's/,/\n/g'|grep '"playing":true') ]]; then 
      trck=$(trackget)
      printf '%-20s %10s' "%{R} $(title|tail -c 20)" "| $trck | %{R-}"
    else
      printf '%-20s %10s' "%{R} End PLaylist!" "|...| %{R-}"
    fi
  else
    echo " "
  fi
}
dstfy ()
{
  [[ -n $1 ]] &&  dunstify -t 5000 "$@" ||dunstify -t 5000 "$(poly.title)"
}
