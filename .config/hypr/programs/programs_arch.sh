#!/bin/bash

echo "This script will install the necessary programs required for Awesome Wm"
echo "Enter to cotinue, ctrl + c to exit:"
read enter
echo

echo "Installing nitrogen"
echo
sudo pacman -S nitrogen
echo

echo "Installing Vscode"
echo
sudo pacman -S code -y
echo
echo

echo "Installing file manager (Nautilus)"
echo
sudo pacman -S nautilus 
echo
echo "Installing brave"
echo
yay -S brave-browser
echo"Installing alacritty"
echo
sudo pacman -S alacritty -y
echo
echo

echo "Installing Power Manager"
echo
sudo pacman -S xfce4-power-manager

echo
echo "Installing picom"
echo
sudo pacman -S picom

echo
echo
echo "Installing kmix"
echo
sudo pacman -S kmix

echo
echo "Installing Flameshot"
sudo pacman -S flameshot
echo

echo
echo "Installing Arandr"
sudo pacman -S arandr 
echo

echo
echo "Installing spectacle"
sudo pacman -S spectacle
echo 

echo
echo "Installing scrcpy"
sudo pacman -S scrcpy
echo

sleep 3
echo "End of script"
echo
sleep 2

exit
