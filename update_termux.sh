#!/bin/bash
apt update &&
apt upgrade -y &&
pkg install -y git clang tsu ncurses-utils &&
git clone https://gitlab.com/st42/termux-sudo &&
cat termux-sudo/sudo > /data/data/com.termux/files/usr/bin/sudo &&
chmod 700 /data/data/com.termux/files/usr/bin/sudo &&
sudo su &&
sudo tsu &&
exit &&
exit

