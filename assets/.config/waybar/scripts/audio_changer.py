#!/usr/bin/env python 
# Credit: Sebatiaan76
# https://github.com/Sebastiaan76/waybar_wireplumber_audio_changer/tree/main

import subprocess
import sys

type = sys.argv[1]

# function to parse output of command "wpctl status" and return a dictionary of devices with their id and name.
def parse_wpctl_status():
    # Execute the wpctl status command and store the output in a variable.
    output = str(subprocess.check_output("wpctl status", shell=True, encoding='utf-8'))

    # remove the ascii tree characters and return a list of lines
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    # get the index of the Devices line as a starting point
    devices_index = None
    for index, line in enumerate(lines):
        if type + ":" in line:
            devices_index = index
            break

    # start by getting the lines after "Devices:" and before the next blank line and store them in a list
    devices = []
    for line in lines[devices_index +1:]:
        if not line.strip():
            break
        devices.append(line.strip())

    # remove the "[vol:" from the end of the device name
    for index, device in enumerate(devices):
        devices[index] = device.split("[vol:")[0].strip()
    
    # strip the * from the default device and instead append "- Default" to the end. Looks neater in the wofi list this way.
    for index, device in enumerate(devices):
        if device.startswith("*"):
            devices[index] = device.strip().replace("*", "").strip() + " - Default"

    # make the dictionary in this format {'device_id': <int>, 'device_name': <str>}
    devices_dict = [{"device_id": int(device.split(".")[0]), "device_name": device.split(".")[1].strip()} for device in devices]

    return devices_dict

# get the list of devices ready to put into wofi - highlight the current default device
output = ''
devices = parse_wpctl_status()
for i, items in enumerate(devices, 1):
    if "Easy Effects" in items['device_name']:
        continue
    if items['device_name'].endswith(" - Default"):
        output += f"<b>-> {items['device_name']}</b>"
    else:
        output += f"{items['device_name']}"
    if i != len(devices):
        output += "\n"

# Call wofi and show the list. take the selected device name and set it as the default device
wofi_command = f"echo '{output}' | wofi --show=dmenu --hide-scroll --allow-markup --location=top_right --width=600 --height=250 --xoffset=-60"
wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if wofi_process.returncode != 0:
    print("User cancelled the operation.")
    exit(0)

selected_device_name = wofi_process.stdout.strip()
devices = parse_wpctl_status()
selected_device = next(device for device in devices if device['device_name'] == selected_device_name)
subprocess.run(f"wpctl set-default {selected_device['device_id']}", shell=True)