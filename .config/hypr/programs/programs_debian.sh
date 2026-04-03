#!/bin/bash

echo "This script will install the necessary programs required for Awesome Wm"
echo "Enter to cotinue, ctrl + c to exit:"
read enter
echo

echo "Installing nitrogen"
echo
sudo apt install nitrogen -y
echo

echo "Installing Vscode"
echo
sudo snap install code -y
echo

echo "Install Brave browser(recommended)(y/n)"
read ans
if [[ $ans = y || $ans = Return ]]
then
	echo "Installing brave"
        sudo apt install curl
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
	sudo apt update
	sudo apt install brave-browser -y
else
	echo "Cancelled brave install"
fi
echo

echo "Installing file manager (Nautilus)"
echo
sudo apt install nautilus -y
echo

echo"Installing alacritty"
echo
sudo apt install alacritty -y
echo

echo "Installing Brightnesss controller"
echo
sudo add-apt-repository ppa:apandada1/brightness-controller
sudo apt update
sudo apt install brightness-controller -y
echo
echo "Installing Power Manager"
echo
sudo apt install xfce4-power-manager -y

echo
echo "Installing compton"
echo
sudo apt install compton -y

echo
echo
echo "Installing kmix"
echo
sudo apt install kmix -y

echo
echo "Installing Flameshot"
sudo apt install flameshot -y
echo

echo
echo "Installing Arandr"
sudo apt install arandr -y
echo

echo
echo "Installing spectacle"
sudo apt install spectacle -y
echo

echo
echo "Installing scrcpy"
sudo apt install scrcpy -y
echo

sleep 3
echo "End of script"
echo
sleep 2

exit
