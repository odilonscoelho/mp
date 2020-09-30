#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
plistyad ()
{
  baseplyad $@
  tail -F --lines=2000 \
  --sleep-interval=1 $mplistyad \
  |\
  yad --list \
  --icon-size=48 \
  --title="Playlist MPV" \
  --grid-lines=vert \
  --grid-lines=hor \
  --geometry=300x400 \
  --columns 2 \
  --column=COD --column=Title:TEXT \
  --no-buttons --tail \
  --search-column=2 \
  --mouse \
  --grid-horizontal \
  --grid-vertical \
  --regex-search \
  --selectable-labels \
  --select-action="mp indice.selected %s" \
  --dclick-action="mp trackgo"

  exit 0
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
controls ()
{
  yad \
  --mouse \
  --geometry 30x50 \
  --borders 5 \
  --form --columns 5 \
  --title=" Controls MPV" \
  --field=" Xclip      !youtube! execute mp xlip -o":FBTN "mp" \
  --field=" Open File  !fileopen!Selecionar arquivos para reprodução":FBTN "mp select.file" \
  --field=" Stop/Clear !user-trash!Stop MPD MPV e Clear playlist":FBTN "mp stop" \
  --field=" Del Sel    !remove!Deleta arquivo selecionado na playlist":FBTN "mp removeyad" \
  --field=" Previous   !go-previous!Previous track":FBTN "mp prev" \
  --field=" Plist      !open-menu!Abrir a playlist":FBTN "mp plistyad force" \
  --field=" Play/Pause !player_play!Toggle pause/play":FBTN "mp pause.toggle" \
  --field=" Save Pl    !gtk-save!Salvar playlist carregada":FBTN "mp save" \
  --field=" Next       !go-next!Next track":FBTN "mp next" \
  --field=" Format URL !configuration!Escolher resolução/formato":FBTN "mp format" \
  --no-buttons
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Para Terminal
plist ()
{
  basepl "$@"
  rev=$(tput rev;)
  res=$(tput sgr0;)
  bold=$(tput bold;)
  i=1
  scopeold=""
  trcksold="$(tracks)"
  trckold="$(trackget)"
  plistloop && plistloop || plistloop
  plist event
}
plistloop ()
{
  if [[ $(tracks) -eq $trcksold && $trckold -eq $(trackget) && $scopeold == $(< $mptitles) ]]; then
    sleep 1
    plistloop
  else
    clear
    while read line; do
      if [[ "$i" -eq "$(trackget)" ]]; then
        echo "$rev $bold|   $(printf '%6s' $i) | $(printf '%-50s' $line|tail -c 50) $res"   
      else
        echo " |  $(printf '%8s' $i) | $(printf '%-50s' $line|tail -c 50) "
      fi
      i=$(( $i + 1 ))
    done < $mptitles
    scopeold=$(< $mptitles)
    trcksold=$(tracks)
    trckold=$(trackget)
    sleep 0.5
    i=1
    plistloop
  fi
}

#爛
