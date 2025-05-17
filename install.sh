#!/bin/bash

install_all="false"
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
########## Nvidia ##########
############################

# Install Nvidia 
if [ "$install_nvidia" = "true" ] || prompt_user "Do you wanna install ${GREEN}Nvidia Drivers${RESET}?"; then
    if lspci | grep -i "nvidia" &> /dev/null; then
        sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda libva libva-nvidia-driver nvidia-vaapi-driver libva-utils vdpauinfo -y
        if ! grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
            additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
            sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
        fi
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        echo "${YELLOW}[WARNING] Beware NVIDIA gpu not found, skipping installation...${RESET}"
    fi
fi



############################
########### SDDM ###########
############################

# Install display manager SDDM
echo "Installing SDDM..."
sudo dnf install sddm -y
sudo systemctl enable sddm
sudo dnf install qt6-qt5compat qt6-qtdeclarative qt6-qtsvg -y

## Install theme for sddm
echo "Installing Where is my SDDM theme..."
git clone https://github.com/stepanzubkov/where-is-my-sddm-theme.git
sudo ./where-is-my-sddm-theme/install.sh current
rm -drf where-is-my-sddm-theme/
sudo cp 'assets/sddm.conf' /etc/



############################
######### Hyprland #########
############################

# Install Hyprland
echo "Installing Hyprland..."
sudo dnf install hyprland hyprland-devel -y
sudo systemctl set-default graphical.target

sudo dnf install gtk2 gtk3 gtk3-devel -y
sudo dnf install xdg-desktop-portal-hyprland xdg-desktop-portal-gtk -y
sudo dnf install xwaylandvideobridge -y

echo "Installing Where is my GTK theme..."
sudo dnf install materia-gtk-theme -y     
sudo dnf install papirus-icon-theme -y  

# Hyprland ecosystem
sudo dnf copr enable solopasha/hyprland -y

## Install hypridle
echo "Installing Hypridle..."
sudo dnf install hypridle -y

## Install hyprlock
echo "Installing Hyprlock..."
sudo dnf install hyprlock -y

## Install hyprpolkitagent
echo "Installing Hyprpolkitagent..."
sudo dnf install hyprpolkitagent -y

## Install hyprpaper
echo "Installing Hyprpaper..."
sudo dnf install hyprpaper -y

## Install hyprnome
echo "Installing Hyprnome..."
sudo dnf install hyprnome -y

## Install hyprshot
echo "Installing Hyprshot"
sudo dnf install hyprshot -y



############################
######### Utility ##########
############################

## Install Gnome-keyring and Seahorse
echo "Installing Gnome Keyring and Seahorse..."
sudo dnf install gnome-keyring -y
sudo dnf install seahorse -y

# Install cliphist
echo "Installing Cliphist..."
sudo dnf install cliphist -y

# Install nwg-displays
echo "Installing Nwg Dislays..."
sudo dnf install nwg-displays -y


############################
########## Topbar ##########
############################

echo "Installing Swaync..."
sudo dnf install swaync -y

echo "Installing Waybar..."
sudo dnf install waybar -y

echo "Installing Power profiles daemon..."
sudo dnf install power-profiles-daemon -y

echo "Installing Network Manager Applet..."
sudo dnf install libappindicator network-manager-applet -y

############################
######### Terminal #########
############################

# Install Alacritty and remove Kitty
echo "Installing Alacritty..."
sudo dnf install alacritty -y
sudo dnf remove kitty -y

## Install Oh My ZSH
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



############################
########### APPS ###########
############################

echo "Installing Nautilus..."
sudo dnf copr enable monkeygold/nautilus-open-any-terminal -y
sudo dnf install nautilus-open-any-terminal -y
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal foot

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

# Spotify
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Spotify${RESET}?"; then
    echo "Installing Spotify..."
    sudo dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.spotify.Client

    sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
    sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps
fi

# Discord
if [ "$install_all" = "true" ]  || prompt_user "Do you wanna install ${SKY_BLUE}Discord${RESET}?"; then
    echo "Installing Discord..."
    sudo dnf install discord -y
fi

############################
########## Extra ###########
############################

THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_stop_threshold"
DESIRED_THRESHOLD=80
if [ -f "$THRESHOLD_FILE" ] && prompt_user "Do you want to ${SKY_BLUE}limit battery charge to ${DESIRED_THRESHOLD}%${RESET}?"; then
    SCRIPT_PATH="/usr/local/bin/charge_thresholds"
    sudo tee "$SCRIPT_PATH" > /dev/null <<EOF
#!/usr/bin/bash
CURRENT=\$(cat $THRESHOLD_FILE)
if [ "\$CURRENT" != "$DESIRED_THRESHOLD" ]; then
    echo $DESIRED_THRESHOLD | sudo tee $THRESHOLD_FILE > /dev/null
fi
EOF

    sudo chmod +x "$SCRIPT_PATH"

    # Create systemd service
    SERVICE_PATH="/etc/systemd/system/charge_thresholds.service"
    sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Set battery charge stop threshold to $DESIRED_THRESHOLD%
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reexec
    sudo systemctl enable charge_thresholds.service
    sudo systemctl start charge_thresholds.service

    echo -e "${SKY_BLUE}Battery charge threshold set to 80% and service enabled.${RESET}"
fi

############################
######### Dotfiles #########
############################

# Copy dotfiles
echo "Copying dotfiles..."
cp -r 'assets/.config' ~/

chmod +x  ~/.config/waybar/scripts/audio_changer.py