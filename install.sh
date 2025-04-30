#!/bin/bash

install_all="false"
install_dots="false"
install_nvidia="false"

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
SKY_BLUE="$(tput setaf 6)"
YELLOW="$(tput setaf 3)" 
RESET="$(tput sgr0)"

if [[ $EUID -eq 0 ]]; then
    echo "${RED}❌ Root user detected, this script should no be executed as root! Exiting...${RESET}"
    exit 1
fi

print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all         Install everything except NVIDIA drivers"
    echo "  --dots        Install dotfiles"
    echo "  --nvidia      Install NVIDIA drivers"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Example:"
    echo "  $0 --all --dots"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            install_all="true"
            install_dots="true"
            shift
            ;;
        --dots)
            install_dots="true"
            shift
            ;;
        --nvidia)
            install_nvidia="true"
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help to see available options."
            exit 1
            ;;
    esac
done

prompt_user() {
    local prompt="${1:-Are you sure?} [Y/n] "
    local response

    read -r -p "$prompt" response
    case "$response" in
        [nN][oO]|[nN])
            return 1  # "No"
            ;;
        *)  
            return 0  # Default to "Yes"
            ;;
    esac
}


############################
########## Setup ###########
############################

# Install Nvidia 
if [ "$install_nvidia" = "true" ] || prompt_user "Do you wanna install ${GREEN}Nvidia Drivers${RESET}?"; then
    if lspci | grep -i "nvidia" &> /dev/null; then
        sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda libva libva-nvidia-driver -y
        if ! grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
            additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
            sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
        fi
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        echo "${YELLOW}[WARNING] Beware NVIDIA gpu not found, skipping installation...${RESET}"
    fi
fi

# Install display manager SDDM
echo "Installing SDDM..."
sudo dnf install sddm -y
sudo systemctl enable sddm
sudo dnf install qt6-qt5compat qt6-qtdeclarative qt6-qtsvg -y

## Install theme for sddm
if [ "$install_dots" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Where Is My SDDM Theme${RESET}?"; then
    echo "Installing Where is my SDDM theme..."
    git clone https://github.com/stepanzubkov/where-is-my-sddm-theme.git
    sudo ./where-is-my-sddm-theme/install.sh current
    rm -drf where-is-my-sddm-theme/
    sudo cp 'assets/sddm.conf' /etc/
fi

# Install Hyprland
echo "Installing Hyprland..."
sudo dnf install hyprland hyprland-devel -y
sudo systemctl set-default graphical.target

sudo dnf install gtk2 gtk3 gtk3-devel -y
sudo dnf install xdg-desktop-portal-hyprland xdg-desktop-portal-gtk -y
sudo dnf install xwaylandvideobridge -y

if [ "$install_dots" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}GTK Theme${RESET}?"; then
    echo "Installing Where is my GTK theme..."
    sudo dnf install materia-gtk-theme -y     
    sudo dnf install papirus-icon-theme -y  
fi

if [ "$install_dots" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Swaybg${RESET}?"; then
    echo "Installing Swaybg..."
    sudo dnf install swaybg -y     
fi


# Install foot
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Foot${RESET}?"; then
    echo "Installing Foot..."
    sudo dnf install foot -y
fi

## Install Oh My ZSH
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}ZSH${RESET}?"; then
    echo "Installing Oh My ZSH..."

    sudo dnf install zsh -y 
    sudo chsh -s /bin/zsh

    sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 

    sudo dnf install lsd -y
    sudo dnf install powerline-fonts -y
    sudo dnf install fastfetch -y

    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    sudo mkdir /usr/share/fonts/jetbrains-mono
    sudo tar -xf JetBrainsMono.tar.xz -C /usr/share/fonts/jetbrains-mono
    rm -f JetBrainsMono.tar.xz

    rm -f ~/.zshrc
    cp -r 'assets/.zshrc' ~/
    
    chsh -s "$(command -v zsh)"
fi


## Install Gnome-keyring and Seahorse
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Gnome Keyring${RESET}?"; then
    echo "Installing Gnome Keyring and Seahorse..."
    sudo dnf install gnome-keyring -y
    sudo dnf install seahorse -y
fi


## Install Mate Polkit
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Mate Polkit${RESET}?"; then
    echo "Installing Mate Polkit..."
    sudo dnf install mate-polkit -y
fi

############################
########### APPS ###########
############################

# VSCode
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}VSCODE${RESET}?"; then
    echo "Installing VSCode..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf install code -y
fi

# Zen
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Zen Browser${RESET}?"; then
    echo "Installing Zen Browser..."
    bash "installer/zen_install.sh"
fi

# Easyeffect
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Easy Effects Equalizer${RESET}?"; then
    echo "Installing Easyeffect..."
    sudo dnf install easyeffects -y
fi

# Blueman
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Blueman${RESET}?"; then
    echo "Installing Blueman..."
    sudo dnf install blueman -y
fi


############################
######### Dotfiles #########
############################

# Copy dotfiles
if [ "$install_dots" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}dotfiles${RESET}?"; then
    echo "Copying dotfiles..."
    cp -r 'assets/.config' ~/
fi
