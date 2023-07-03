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
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
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

#install yay Helper
ISYAY=/sbin/yay
if [ -f "$ISYAY" ]; then
	echo -e "$OK - yay was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BRed}Do you want install Yay Helper? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo pacman -S --needed base-devel --noconfirm | tee -a "$INSTLOG"
		sleep 1
		sudo pacman -S git --noconfirm | tee -a "$INSTLOG"
		sleep 1
		git clone https://aur.archlinux.org/yay.git | tee -a "$INSTLOG"
		cd yay
		makepkg -si --noconfirm | tee -a "$INSTLOG"
		cd ..
	fi
	# update the yay database
fi
echo -e "$CNT - Updating the yay database..."
yay -Suy --noconfirm | tee -a "$INSTLOG"

#install zsh & oh my posh
ISZSH=/sbin/zsh
if [ -f "$ISZSH" ]; then
	echo -e "$OK - zsh was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BRed}Do you want install Zsh? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo pacman -S zsh --noconfirm | tee -a "$INSTLOG"
	fi
fi
ISOHMYZSH=$HOME/.oh-my-zsh/
if [ "$ISOHMYZSH" ]; then
	echo -e "$OK - oh my zsh was located, moving on." | tee -a "$INSTLOG"
else
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

#install chezmoi & sync
ISCHEZMOI=/sbin/chezmoi
if [ -f "$ISCHEZMOI" ]; then
	echo -e "$OK - chezmoi was located, moving on." | tee -a "$INSTLOG"
else
	echo -e -n "$CFM ${BRed}Do you want install chezmoi? [Y/n] ${Color_Off}"
	if confirm $DEF_YES; then
		sudo su
		cd /
		sh -c "$(curl -fsLS get.chezmoi.io)" | tee -a "$INSTLOG"
		chezmoi init --apply https://github.com/ngtuonghy/dotfiles.git
		exit
	fi
fi
# auto sync zsh
#
echo -e -n "$CFM ${BRed}Do you want sync zsh? [Y/n] ${Color_Off}"
if confirm $DEF_YES; then
	git clone https://github.com/jeffreytse/zsh-vi-mode \
		$ZSH_CUSTOM/plugins/zsh-vi-mode

	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \\n\n ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
else
	echo -e "\n${SKIP} You has skip sync zsh"
fi

echo -e "\n${BIPurple}Welcome! sync Success${Color_Off}"
