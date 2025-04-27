# Install Nvidia 
sudo dnf install libva libva-nvidia-driver egl-wayland -y

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

# Install Hyprland
echo "Installing Hyprland..."
sudo dnf install hyprland hyprland-devel -y
sudo systemctl set-default graphical.target

sudo dnf install gtk2 gtk3 gtk3-devel -y
sudo dnf install xdg-desktop-portal-hyprland xdg-desktop-portal-gtk -y

# Install foot
echo "Installing Foot..."
sudo dnf install foot -y

## Install Oh My ZSH
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

rm -f ~/.zshrc
cp -r 'assets/.zshrc' ~/

# VSCode
echo "Installing VSCode..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install code -y

# Copy dotfiles
echo "Copying dotfiles..."
cp -r 'assets/.config' ~/