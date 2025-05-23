#!/bin/bash

rsync --recursive --force ~/.config/alacritty ./assets/.config/
rsync --recursive --force ~/.config/background ./assets/.config/
rsync --recursive --force ~/.config/gtk-3.0 ./assets/.config/
rsync --recursive --force ~/.config/gtk-4.0 ./assets/.config/
rsync --recursive --force ~/.config/hypr ./assets/.config/
rsync --recursive --force ~/.config/swaync ./assets/.config/
rsync --recursive --force ~/.config/waybar ./assets/.config/
rsync --recursive --force ~/.config/wofi ./assets/.config/
rsync --recursive --force ~/.config/xdg-desktop-portal ./assets/.config/

cp ~/.config/mimeapps.list ./assets/.config/mimeapps.list

cp ~/.zshrc ./assets/