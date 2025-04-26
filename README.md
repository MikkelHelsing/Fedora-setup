# Fedora-setup
Fedora Everything: https://alt.fedoraproject.org/
## Setup
**Custom Fedora**
- Extended package
- Dev tools
- C setup
- Network tools
### Other
- Disk encrypted
- No root

```bash
sudo dnf update || sudo dnf upgrade
```

```bash
sudo dnf install neofetch
```

# Hyprland
```bash
git clone https://github.com/JaKooLit/Fedora-Hyprland.git
cd Fedora-Hyprland
chmod +x install.sh
./install.sh
```
## Selected options
- input_group
- sddm
- sddm theme
- gtk themes
- bluetooth
- thunar
- xdph
- zsh

## Dotfiles
```bash
git clone https://github.com/EisregenHaha/fedora-hyprland

cd fedora-hyprland
sudo bash fedora/install.sh

bash fedora/fonts.sh

bash manual-install-helper.sh

cp -Rf .config/* ~/.config/
cp -Rf .local/* ~/.local/
```
