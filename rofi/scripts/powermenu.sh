#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

dir="$HOME/.config/rofi/powermenu"
rofi_command="rofi -theme $dir/powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')

# Options
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
suspend=" Suspend"
logout=" Logout"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
		swaylock \
			--screenshots \
			--clock \
			--indicator \
			--indicator-radius 100 \
			--indicator-thickness 7 \
			--effect-blur 7x5 \
			--effect-vignette 0.5:0.5 \
			--ring-color 1E1E2E \
			--key-hl-color CDD6F4 \
			--line-color 00000000 \
			--inside-color 00000088 \
			--separator-color 00000000 \
			--text-color FFFFFF \
			--grace 2 \
			--fade-in 0.2
        ;;
    $suspend)
		systemctl suspend
        ;;
    $logout)
		pkill Hyprland
        ;;
esac
