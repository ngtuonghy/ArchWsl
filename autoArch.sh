#!/bin/bash
# Reset
Color_Off='\e[0m' # Text Reset

# Regular Colors
Black='\e[0;30m'  # Black
Red='\e[0;31m'    # Red
Green='\e[0;32m'  # Green
Yellow='\e[0;33m' # Yellow
Blue='\e[0;34m'   # Blue
Purple='\e[0;35m' # Purple
Cyan='\e[0;36m'   # Cyan
White='\e[0;37m'  # White

# Bold
BBlack='\e[1;30m'  # Black
BRed='\e[1;31m'    # Red
BGreen='\e[1;32m'  # Green
BYellow='\e[1;33m' # Yellow
BBlue='\e[1;34m'   # Blue
BPurple='\e[1;35m' # Purple
BCyan='\e[1;36m'   # Cyan
BWhite='\e[1;37m'  # White

# Underline
UBlack='\e[4;30m'  # Black
URed='\e[4;31m'    # Red
UGreen='\e[4;32m'  # Green
UYellow='\e[4;33m' # Yellow
UBlue='\e[4;34m'   # Blue
UPurple='\e[4;35m' # Purple
UCyan='\e[4;36m'   # Cyan
UWhite='\e[4;37m'  # White

# Background
On_Black='\e[40m'  # Black
On_Red='\e[41m'    # Red
On_Green='\e[42m'  # Green
On_Yellow='\e[43m' # Yellow
On_Blue='\e[44m'   # Blue
On_Purple='\e[45m' # Purple
On_Cyan='\e[46m'   # Cyan
On_White='\e[47m'  # White

# High Intensity
IBlack='\e[0;90m'  # Black
IRed='\e[0;91m'    # Red
IGreen='\e[0;92m'  # Green
IYellow='\e[0;93m' # Yellow
IBlue='\e[0;94m'   # Blue
IPurple='\e[0;95m' # Purple
ICyan='\e[0;96m'   # Cyan
IWhite='\e[0;97m'  # White

# Bold High Intensity
BIBlack='\e[1;90m'  # Black
BIRed='\e[1;91m'    # Red
BIGreen='\e[1;92m'  # Green
BIYellow='\e[1;93m' # Yellow
BIBlue='\e[1;94m'   # Blue
BIPurple='\e[1;95m' # Purple
BICyan='\e[1;96m'   # Cyan
BIWhite='\e[1;97m'  # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'  # Black
On_IRed='\e[0;101m'    # Red
On_IGreen='\e[0;102m'  # Green
On_IYellow='\e[0;103m' # Yellow
On_IBlue='\e[0;104m'   # Blue
On_IPurple='\e[0;105m' # Purple
On_ICyan='\e[0;106m'   # Cyan
On_IWhite='\e[0;107m'  # White

SKIP="[${Yellow}SKIP${Color_Off}]"
CFM="[${UCyan}CONFIRM${Color_Off}]"
OK="[${UGreen}OK${Color_Off}]"
ERR="[${URed}ERROR${Color_Off}]"
NOTE="[${UCyan}NOTE${Color_Off}]"
INSTLOG="install.log"

confirm() {
	read -p "$prompt" -n 1 -r
	if [[ $REPLY =~ ^[Yy]${1}$ ]]; then
		return 0 # Trả về giá trị thành công
	else
		return 1 # Trả về giá trị thất bại
	fi
}
DEF_YES='?'

# function that will test for a package and if not found it will attempt to install it
install_software_aur() {
	# First lets see if the package is there
	if yay -Q $1 &>>/dev/null; then
		echo -e "$OK - $1 is already installed."
	else
		# no package found so installing
		echo -e "$NOTE - Now installing $1 ..."
		yay -S --noconfirm $1 &>>$INSTLOG
		# test to make sure package installed
		if yay -Q $1 &>>/dev/null; then
			echo -e "\e[1A\e[K$OK - $1 was installed."
		else
			# if this is hit then a package is missing, exit to review log
			echo -e "\e[1A\e[K$ERR - $1 install had failed, please check the install.log"
			exit
		fi
	fi
}

install_software_pacman() {
	# First lets see if the package is there
	if sudo pacman -Q $1 &>>/dev/null; then
		echo -e "$OK - $1 is already installed."
	else
		# no package found so installing
		echo -e "$NOTE - Now installing $1 ..."
		sudo pacman -S --noconfirm $1 &>>$INSTLOG
		# test to make sure package installed
		if sudo pacman -Q $1 &>>/dev/null; then
			echo -e "\e[1A\e[K$OK - $1 was installed."
		else
			# if this is hit then a package is missing, exit to review log
			echo -e "\e[1A\e[K$ERR - $1 install had failed, please check the install.log"
		fi
	fi
}

clear

#sudo pacman -Sy archlinux-keyring
MIRRORLIST="/etc/pacman.d/mirrorlist"
if [ -s ${MIRRORLIST} ]; then
	# The file is not-empty.
	echo "mirrorlist not null" >>$INSTLOG
else
	## Worldwide
	echo "Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch" >$HOME/mirrorlist.txt
	sudo mv -v $HOME/mirrorlist.txt /etc/pacman.d/mirrorlist
	sudo pacman -Syy
fi

#install yay Helper
ISYAY=/sbin/yay
if [ -f "$ISYAY" ]; then
	echo -e "$OK - yay was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BGreen}Do you want install Yay Helper? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo pacman -S --needed base-devel --noconfirm | tee -a "$INSTLOG"
		sudo pacman -S git --noconfirm | tee -a "$MIRRORLIST"
		sleep 1
		git clone https://aur.archlinux.org/yay.git | tee -a "$INSTLOG"
		cd yay
		makepkg -si --noconfirm | tee -a "$INSTLOG"
		cd ..
	fi
	# update the yay database
	echo -e "$CNT - Updating the yay database..."
	yay -Suy --noconfirm | tee -a "$INSTLOG"
fi

#install zsh & oh my posh
ISZSH=/sbin/zsh
if [ -f "$ISZSH" ]; then
	echo -e "$OK - zsh was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BGreen}Do you want install Zsh? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo pacman -S zsh --noconfirm | tee -a "$INSTLOG"
	fi
fi

ISOHMYZSH=$HOME/.oh-my-zsh
if [ -d "$ISOHMYZSH" ]; then
	echo -e "$OK - oh my zsh was located, moving on." | tee -a "$INSTLOG"
else
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

#install chezmoi & sync
ISCHEZMOI=/sbin/chezmoi
if [ -f "$ISCHEZMOI" ]; then
	echo -e "$OK - chezmoi was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BGreen}Do you want install chezmoi? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo pacman -S chezmoi --noconfirm
		chezmoi init --apply https://github.com/ngtuonghy/dotfilesWsl.git
	fi
fi

# install neovim and fd, ripgrep lazy git
echo -e -n "$CFM ${BGreen}Do you want install Neovim and dependencies[fd, ripgrep, lazygit, tmux, npm]? [Y/n] ${Color_Off}"
if confirm $DEF_YES; then
	echo -e "$NOTE - Neovim setup stage, this may take a while..."
	for SOFT_PACMAN in neovim fd ripgrep lazygit tmux npm; do
		install_software_pacman $SOFT_PACMAN
	done
else
	echo -e "\n${SKIP} You has skip install neovim"
fi
# auto sync zsh#

echo -e -n "$CFM${BGreen}Do you want sync oh my zsh and plugins? [Y/n] ${Color_Off}"
if confirm $DEF_YES; then
	ISVIMMODE=$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode
	if [ -d "$ISVIMMODE" ]; then # -d là kiểm tra đường dẫn
		echo -e "$OK - zsh-vi-mode is already installed."
	else
		git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom/}/plugins/zsh-vi-mode
	fi
	ISAUTO=$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	if [ -d ${ISAUTO} ]; then
		echo -e "$OK - zsh-autosuggestions is already installed."
	else
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	fi
	ISSYNTAX=$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
	if [ -d ${ISSYNTAX} ]; then
		echo -e "$OK - fast-syntax-highlighting is already installed."
	else
		git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
	fi
	ISP10K=$HOME/.oh-my-zsh/custom/themes/powerlevel10k
	if [ -d ${ISP10K} ]; then
		echo -e "$OK - powerlevel10k is already installed."
	else
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	fi
else
	echo -e "\n${SKIP} You has skip sync zsh"
fi

# chsh -s $(which zsh)

if [ "$(basename "$SHELL")" = "zsh" ]; then
	echo -e "$OK - Terminal Default is Zsh"
else
	echo -e -n "$CFM ${BGreen}Do you want chage default is zsh? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		chsh -s /bin/zsh
		echo "Terminal Default is Zsh" >>$INSTLOG
	fi
fi

echo -e "\n${BIPurple}Welcome! sync Success\nPlease reboot now update${Color_Off}"
