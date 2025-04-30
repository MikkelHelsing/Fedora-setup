#!/bin/bash

rsync --recursive --force ~/.config/hypr ./assets/.config/
rsync --recursive --force ~/.config/foot ./assets/.config/
rsync --recursive --force ~/.config/gtk-3.0 ./assets/.config/
rsync --recursive --force ~/.config/gtk-4.0 ./assets/.config/

cp ~/.config/mimeapps.list ./assets/.config/mimeapps.list