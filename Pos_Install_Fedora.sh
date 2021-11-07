#!/usr/bin/env bash

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------ CABEÇALHO -------------------------------------------------- #
## AUTOR:
### 	Ciro Mota <contato.ciromota@outlook.com>
## NOME:
### 	Pos_Install_Fedora.
## DESCRIÇÃO:
###			Script de pós instalação desenvolvido para base Fedora 35, 
###			baseado no meu uso de programas, configurações e personalizações.
## LICENÇA:
###		  GPLv3. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/blob/master/LICENSE>
## CHANGELOG:
### 		Última edição 07/11/2021. <https://github.com/ciro-mota/Pos-Instalacao-Ubuntu/commits/master>

### Para calcular o tempo gasto na execução do script, use o comando "time ./Pos_Install_Fedora.sh".

# ------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------- VARIÁVEIS E REQUISITOS ----------------------------------------- #

### Repos e links de download dinâmicos.
url_key_brave="https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
url_repo_brave="https://brave-browser-rpm-release.s3.brave.com/x86_64/"
url_repo_dck="https://download.docker.com/linux/fedora/docker-ce.repo"
url_jopplin="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
url_flathub="https://flathub.org/repo/flathub.flatpakrepo"
url_tviewer="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm"
url_dbox="https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2020.03.04-1.fedora.x86_64.rpm"
url_code="https://az764295.vo.msecnd.net/stable/b3318bc0524af3d74034b8bb8a64df0ccf35549a/code-1.62.0-1635954170.el7.x86_64.rpm"
# url_backup="https://github.com/ciro-mota/conf-backup.git"
# url_fantasque="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FantasqueSansMono/Regular/complete/Fantasque%20Sans%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"

### Programas para instalação e desinstalação.
apps_remover=(cheese 
	gnome-boxes 
	gnome-connections 
	gnome-maps 
	gnome-photos 
	gnome-tour 
	mediawriter 
	totem 
	rhythmbox)	

apps=(android-tools 
	brave-browser 
	celluloid 
	chrome-gnome-shell
	containerd.io 
	cowsay 
	docker-ce-cli  
	ffmpegthumbnailer 
	fortune-mod 
	gnome-tweaks 
	hugo  
	java-latest-openjdk 
	lolcat 
	lutris 
	neofetch 
	neovim 
	obs-studio 
	terminator 
	ulauncher 
	zsh)

flatpak=(com.spotify.Client 
	com.valvesoftware.Steam 
	com.valvesoftware.Steam.Utility.MangoHud 
	nl.hjdskes.gcolor3 
	org.gimp.GIMP 
	org.onlyoffice.desktopeditors 
	org.qbittorrent.qBittorrent 
	org.remmina.Remmina 
	org.telegram.desktop)

code_extensions=(CoenraadS.bracket-pair-colorizer-2 
	dendron.dendron-markdown-shortcuts 
	eamodio.gitlens
	HashiCorp.terraform
	ms-azuretools.vscode-docker 
	MS-CEINTL.vscode-language-pack-pt-BR
	ms-kubernetes-tools.vscode-kubernetes-tools
	shakram02.bash-beautify 
	Shan.code-settings-sync 
	snyk-security.vscode-vuln-cost 
	streetsidesoftware.code-spell-checker 
	streetsidesoftware.code-spell-checker-portuguese-brazilian 
	timonwong.shellcheck 
	zhuangtongfa.Material-theme)	

diretorio_downloads="$HOME/Downloads/programas"

# ------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------- TESTE --------------------------------------------------- #
### Check se a distribuição é a correta.
if [[ $(cat /etc/fedora-release | awk '{ print $3 }') = "35" ]]
then
	echo ""
	echo ""
	echo -e "\e[32;1mDistribuição correta. Prosseguindo com o script...\e[m"
	echo ""
	echo ""
else
	echo -e "\e[31;1mDistribuição não homologada para uso com este script.\e[m"
	exit 1
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------ APLICANDO REQUISITOS --------------------------------------------- #
### Desinstalando apps desnecessários.
for nome_do_programa in "${apps_remover[@]}"; do
    sudo dnf remove "$nome_do_programa" -y
done

### Adicionando RPM Fusion.
 sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
 https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm -y

### Adicionando repositórios de terceiros.
sudo dnf config-manager --add-repo "$url_repo_brave"
sudo rpm --import "$url_key_brave"

sudo dnf config-manager --add-repo "$url_repo_dck"

flatpak remote-add --if-not-exists flathub "$url_flathub"

### Atualizando sistema após adição de novos repositórios.
sudo dnf update -y

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- EXECUÇÃO -------------------------------------------------- #
### Instalação da lista de apps.
for nome_do_app in "${apps[@]}"; do
  if ! dnf list --installed | grep -q "$nome_do_app"; then
    sudo dnf install "$nome_do_app" -y
  else
    echo "$nome_do_app ==> [JÁ INSTALADO]"
  fi
done

### Instalação de apps Flatpak.
for nome_do_flatpak in "${flatpak[@]}"; do
  if ! flatpak list | grep -q "$nome_do_flatpak"; then
    sudo flatpak install flathub --system "$nome_do_flatpak" -y
  fi
done

### Instalação do Jopplin.
wget -O - $url_jopplin | bash

### Download de programas .rpm.
mkdir -p "$diretorio_downloads"
wget -cq --show-progress "$url_code" 	-P "$diretorio_downloads"
wget -cq --show-progress "$url_dbox" 	-P "$diretorio_downloads"
wget -cq --show-progress "$url_tviewer" -P "$diretorio_downloads"

### Instalando pacotes .rpm.
sudo dnf install -y "$diretorio_downloads"/*.rpm

### Instalação extensões do Code.
for code_ext in "${code_extensions[@]}"; do
    code --install-extension "$code_ext" 2> /dev/null
done

### Instalação de ícones, temas e configurações.
if [ -d "$HOME"/.icons ]
then
  echo "Pasta já existe."
else
  mkdir -p "$HOME"/.icons
fi

if [ -d "$HOME"/.themes ]
then
  echo "Pasta já existe."
else
  mkdir -p "$HOME"/.themes
fi

# ------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------- PÓS-INSTALAÇÃO -------------------------------------------- #
### Ativando ZRAM.
sudo systemctl enable zram-swap.service

### Procedimentos e otimizações.
sudo echo -e "fastestmirror=1" | sudo tee -a /etc/dnf/dnf.conf
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
sudo sh -c 'echo "# Menor uso de Swap" >> /etc/sysctl.conf'
sudo sh -c 'echo vm.swappiness=10 >> /etc/sysctl.conf'
sudo sh -c 'echo vm.vfs_cache_pressure=50 >> /etc/sysctl.conf'
sudo usermod -aG docker "$(whoami)"
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
sudo gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
sudo flatpak --system override org.telegram.desktop --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.spotify.Client --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override com.valvesoftware.Steam --filesystem="$HOME"/.icons/:ro
sudo flatpak --system override org.onlyoffice.desktopeditors --filesystem="$HOME"/.icons/:ro
sudo gsettings set org.gnome.desktop.default-applications.terminal exec terminator

### Bloco de personalizações pessoais.
# wget -cq --show-progress "$url_fantasque" -P "$diretorio_downloads"
# mkdir -p .local/share/fonts
# mv *.ttf ~/.local/share/fonts/
# fc-cache -f -v >/dev/null

# git clone "$url_backup"

# cp -r $HOME/conf-backup/Dracula-Blue $HOME/.themes
# cp -r $HOME/conf-backup/Yaru-Deepblue-dark $HOME/.themes
# cp -r $HOME/conf-backup/Flat-Remix-Blue-Dark $HOME/.icons
# cp -r $HOME/conf-backup/volantes_cursors $HOME/.icons
# cp -r $HOME/conf-backup/neofetch $HOME/.config/neofetch
# cp -r $HOME/conf-backup/terminator $HOME/.config/terminator
# cp -r $HOME/conf-backup/.zsh_aliases $HOME
# cp -r $HOME/conf-backup/.zshrc $HOME
# cp -r $HOME/conf-backup/.vim $HOME

# sudo gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-Blue'
# sudo gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark'
# sudo gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-Deepblue-dark'
# sudo gsettings set org.gnome.desktop.interface cursor-theme 'volantes_cursors'

### Finalização e limpeza.
sudo dnf autoremove -y

### Limpando pasta temporária dos downloads.
sudo rm "$diretorio_downloads"/ -rf