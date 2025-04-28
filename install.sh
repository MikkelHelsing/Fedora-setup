#!/bin/bash

install_all=0
install_dots=0
install_nvidia=0


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
            install_all=1
            install_dots=1
            shift
            ;;
        --dots)
            install_dots=1
            shift
            ;;
        --nvidia)
            install_nvidia=1
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
if install_nvidia || prompt_user "Do you wanna install Nvidia Drivers?"; then
    sudo dnf install libva libva-nvidia-driver egl-wayland -y
fi

# Install display manager SDDM
echo "Installing SDDM..."
sudo dnf install sddm -y
sudo systemctl enable sddm
sudo dnf install qt6-qt5compat qt6-qtdeclarative qt6-qtsvg -y

## Install theme for sddm
if install_dots || prompt_user "Do you wanna install Where Is My SDDM Theme?"; then
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

if install_dots || prompt_user "Do you wanna install GTK Theme?"; then
    echo "Installing Where is my GTK theme..."
    sudo dnf install materia-gtk-theme -y     
    sudo dnf install papirus-icon-theme -y  
fi

# Install foot
if install_all || prompt_user "Do you wanna install Foot?"; then
    echo "Installing Foot..."
    sudo dnf install foot -y
fi

## Install Oh My ZSH
if install_all || prompt_user "Do you wanna install ZSH?"; then
    echo "Installing Oh My ZSH..."

    sudo dnf install zsh -y 
    sudo chsh -s /bin/zsh

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
fi

############################
########### APPS ###########
############################

# VSCode
if install_all || prompt_user "Do you wanna install VSCODE?"; then
    echo "Installing VSCode..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf install code -y
fi

# Zen
if install_all || prompt_user "Do you wanna install Zen Browser?"; then
    echo "Installing Zen Browser..."
    bash "installer/zen_install.sh"
fi

# Easyeffect
if install_all || prompt_user "Do you wanna install Easy Effects Equalizer?"; then
    echo "Installing Easyeffect..."
    sudo dnf install easyeffects -y
fi

# Blueman
if install_all || prompt_user "Do you wanna install Blueman?"; then
    echo "Installing Blueman..."
    sudo dnf install blueman -y
fi


############################
######### Dotfiles #########
############################

# Copy dotfiles
if install_dots || prompt_user "Do you wanna install dotfiles?"; then
    echo "Copying dotfiles..."
    cp -r 'assets/.config' ~/
fi