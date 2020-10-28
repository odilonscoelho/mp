# mp
mp -> media player with mpv

## À que se propõe:
mp é um controle remoto do mpv que permite gerenciar mais de uma sessão por vez por meio dos sockets criados, permite salvar playlists de vídeos do youtube por exemplo, ou de arquivos locais em .m3u, fornece por meio do rofi ou yad um controle para o mpv quando executar arquivos de aúdio (onde a janela do mpv por padrão será escondida) e uma playlist em yad, rofi e terminal, há também um módulo para polybar via IPC.

## Dependências:
* zsh -> não precisa ser o shell default do user
* mpv -> +youtube-dl para reproduzir videos do youtube
* yad -> para seleção de arquivos fora do terminal
* rofi -> para listar playlist e ter um painel de controle
* socat -> para comunicação com os sockets

## Configuração:

* Copie e cole no seu **~/.config/mpv/mpv.conf**
```
input-ipc-server=/tmp/mpvsocketDefault
idle=yes
```
* Dê permissão de execução ao script e coloque o diretório no seu PATH
* Se usa o bash como shell default altere o **~/.zshrc** por **~/.bashrc**
```
cd /path/mp
chmod +x mp*
echo "# path para mp\nPATH=\$PATH:$PWD" >> ~/.zshrc
```
## Uso
```
USO: 	

mp [options] <files/urls>

Options:

-bpl 	-basepl		- Atualiza a base de dados para playlists (terminal)
-bply 	-baseplyad	- Atualiza a base de dados para playlistyad *deprecate
-c 	-controls	- Abre controls em yad
-cr 	-controlsr	- Abre controls em rofi
-console		- Abre o modo console em rofi
-f 	-format		- Alterar format do video/áudio do yt (terminal, console e controlsr)
-gs 	-get-socks	- Verificar quais os nomes dos socks abertos (terminal)
-h 	-help		- Esse menu de ajuda (terminal)
-mpd			- start / stop - para iniciar ou parar o daemon (terminal e console)
-nx 	-next 		- Next track (terminal e console)
-p 	-pause 		- Toggle Pause/Play (terminal e console)
-pb 	-polybar 	- Label para módulo polybar
-pv 	-prev 		- Prev track (terminal e console)
-pl 	-plist 		- Playlist no terminal (terminal)
-plr 	-plistrofi 	- Playlist no rofi (terminal e console)
-ply 	-plistyad 	- PLaylist no yad *deprecate
-rm 	-remove 	- Remove a track informada (terminal e console).
-rmy 	-removeyad 	- Remove a track selecionada na playlist com yad
-S 	-Save 		- Salve a playlist atual - Requer yad
-svf 	-save-file 	- Salve a playlist com o nome informado (terminal e console)
-s 	-sock 		- Inicie o MP com o socket informado
-st 	-stop 		- Stop e clear playlist (terminal e console)
-sf 	-selfile 	- Selecionar arquivos para execução - Requer yad
-t 	-track 		- Vá para a track informada
-tget 	-trackget 	- Informa qual a track em execução (terminal)
-tt 	-title 		- Retorna o título do arquivo/url 'N' solicitada (terminal)
-u 	-url 		- Retorna o nome do arquivo/url 'N' solicitada (terminal)
-v 	-vol 		- Seta o volume do mpv no valor informado
```
