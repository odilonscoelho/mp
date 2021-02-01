# mp
mp -> media player with mpv

## À que se propõe:
mp é um controle remoto do mpv que permite gerenciar mais de uma sessão por vez por meio dos sockets criados, permite salvar playlists de vídeos do youtube por exemplo, ou de arquivos locais em .m3u, fornece por meio do rofi ou yad um controle para o mpv quando executar arquivos de aúdio (onde a janela do mpv por padrão será escondida) e uma playlist em yad, rofi e terminal, há também um módulo para polybar via IPC.

## Dependências:
Itens marcados são necessários, os demais opcionais mas limitando o usabilidade:

- [x] zsh - Não precisa ser o shell default do user;
- [x] mpv - Requerido;
- [x] socat - Requerido para escrever no socket do mpv;
- [x] youtube-dl - Requerido para reproduçao de vídeos do youtube e obtenção de thumbs;
- [ ] yad - Opcional para ter uma caixa de diálog para seleção de arquivos fora do terminal e um controle em GTK do mp;
- [ ] rofi - Opcional, para ter uma playlist em rofi e console que aceita algumas das funções do mp;
- [ ] wget - Opcional, para obtenção das thumbs;
- [ ] imagemagick (convert) - Opcional, para conversão de thumbs em formatos svg para jpg;
- [ ] dunst (dunstify) - Opcional, para notificações;
- [ ] polybar (polybar-msg) - Opcional, para implementar o modulo polybar;

## Configuração:

* Copie e cole no seu **~/.config/mpv/mpv.conf**, isso fará com que o mpv não encerre a sessão ao término da reprodução, possibilitando acrescentar arquivos para a execuçao na mesma sessão mesmo quando o player terminar de reproduzir o último arquivo carregado:
```
idle=yes
```
Dê permissão de execução ao script e coloque o diretório no seu PATH, caso use o bash como shell default, altere **~/.zshrc** por **~/.bashrc** no exemplo abaixo:
```
cd /path/mp
chmod +x mp*
echo "# path para mp\nPATH=\$PATH:$PWD" >> ~/.zshrc
```
## Uso
```
USO: 	
mp --help | -h (Opções do terminal)
mp --console | -console (Console em rofi modo comando com arugmentos que são requeridos nas mesmas opções via terminal - Requer Rofi)
mp --controls | -c (Controle do MPV via internface gráfica em yad - Requer Yad)
mp --select-file | -sf (Caixa de diálogo para seleção de arquivos, Requer Yad)

```

## Módulo Polybar - Exemplo
```
[module/mpv]
type = custom/ipc
hook-0 = mp -pb &
hook-1 = mp --polybar &
initial = 1
double-click-left = mp -sf &>/dev/null & 
click-right = mp -plr &>/dev/null & 
click-left = mp -console &> /dev/null &
scroll-down = mp -next &
scroll-up = mp -prev &
```
## O nome do módulo deve ser configurado também no arquivo mp.conf para refletir o mesmo nome e hook cadastrado no módulo no arquivo da polybar.
```
mpv.conf
polymsg.command () polybar-msg hook mpv 1
```
#### Para não usar a polybar comente a opção acima no aruqivo mp.conf, o mesmo deve ser feito caso não queira o serviço de notificações, comente todas as opções que envolvam notificações.
