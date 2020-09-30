#!/bin/zsh
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
sock.ativo ()
{
  # playlist |sed 's/,/\n/g'|grep -q '"playing":true' && return 0 || return 1
  [[ -z $(test.loaded url 2>/dev/null) ]] && return 1 || return 0
  # grep -Eq "[[:alnum:]]" <<< $(playlist |sed 's/request\_id//g') && return 0 || return 1
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
sock ()
{
  if [[ -z $sock ]]; then
    declare -x name=$(yad --geometry=200x100 --no-buttons --borders=50 --text "Informe o socket do mpv:" --entry) # Ao usar mais de ums socket simultaneo, descomentar!
    [[ -z $name ]] && declare -x sock=/tmp/mpvsocket ||  declare -x sock=/tmp/mpvsocket$name
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
get.title ()
{
  youtube-dl --get-title "$@"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
indice.selected () #Argumentos
{
  # echo $@|cut -d" " -f1 > $selcod
  echo $@|cut -d" " -f1 > $tmpcod
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
format.url () #Argumentos
{
  if [[ "$url" =~ "https://www.youtube.com/playlist?|'https://www.youtube.com.*start_radio'" ]]; then
    declare -x format="best"
    declare -x new_class="youtube"
  elif [[ "$url" =~ "painelcode.me" ]]; then
    declare -x format="best"
    declare -x new_class="iptv"
  else
    case "$url" in;
      *www.xvideos.com* )
        base=$(\
        youtube-dl --list-formats "$url"\
        |grep -Ev "[XV]ideos|format|info|Downloading"\
        |awk '{print $1,$2,$3}'\
        |sed -E 's/ |$/\|/g');;
      *spankbang.com* )
        base=$(\
        youtube-dl --list-formats "$url"\
        |grep -Ev "Spank[b|B]ang|format|info"\
        |awk '{print $1,$2,$3}'\
        |sed -E 's/ |$/\|/g');;
      *youtube.com* )
        base=$(\
        youtube-dl --list-formats "$url"\
        |grep -Ev "Spank[b|B]ang|format|info|youtube|video only"\
        |awk '{print $1,$2,$3}'\
        |sed -E 's/ |$/\|/g');;
      *youtu.be* )
        base=$(\
        youtube-dl --list-formats "$url"\
        |grep -Ev "Spank[b|B]ang|format|info|youtube|video only"\
        |awk '{print $1,$2,$3}'\
        |sed -E 's/ |$/\|/g');;
    esac
    declare -x format=$(yad --list \
    --columns=3 --column "Format Code" --column "Extension" --column "Resolution/Audio Only" \
    --button="BEST":"mp play.best" \
    --title "Opções :" --selectable-labels --search-column=2 --search-column=3 --regex-search \
    --text-align=center --geometry 400x320 --borders=5 ${(s:|:)base} |cut -d'|' -f1|grep -Ev '^$')
    [[ -z $format ]] && exit 0
  fi
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
test.loaded () 
{
  # grep -Ev 'request_id|error":' <<< $(sed -E 's/,/\n/g;s/\{\"filename\"\://g;s/\"title\"\://g;s/\}//g;s/\]//g' /tmp/playlist)
  case $@ in
    url.iptv )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|title:' \
      |cut -d':' -f2- ;;
    url.iptv* )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|title:' \
      |cut -d':' -f2- \
      |sed -n ''$2'p' ;;
    title.iptv )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|filename:' \
      |cut -d':' -f2- ;;
    title.iptv* )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/,title\:/\ntitle\:/g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|filename:' \
      |cut -d':' -f2- \
      |sed -n ''$2'p' ;;
    url )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|title:' \
      |cut -d':' -f2- ;;
    url* )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|title:' \
      |cut -d':' -f2- \
      |sed -n ''$2'p' ;;
    title )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|filename:' \
      |cut -d':' -f2- ;;
    title* )
      playlist \
      |sed -E 's/\}\,\{/\}\n\{/g;s/\{|\}|\]|\[|"|request_id.*|error\:suc.*//g;s/current:true|playing:true|data://g;s/title\: /\ntitle\: /g' \
      |sed -E 's/,$|,,$|,,,$|,,,,$//g' \
      |grep -Ev '^$|filename:' \
      |cut -d':' -f2- \
      |sed -n ''$2'p' ;;
  esac
}