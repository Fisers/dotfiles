#!/usr/bin/env bash

# get current connection status
CONSTATE=$(nmcli -fields WIFI g)
if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="Disable WiFi 睊"
	# this prints a beautifully formatted list. bash was a mistake

	if [ "$1" = "-r" ]; then
		rescan="yes"
	else
		rescan="no"
	fi

	LIST=$(nmcli --fields SSID,SECURITY,BARS device wifi list --rescan $rescan | sed '/^--/d' | sed 1d | sed -E "s/WPA*.?\S/~~/g" | sed "s/~~ ~~/~~/g;s/802\.1X//g;s/--/~~/g;s/  *~/~/g;s/~  */~/g;s/_/ /g" | column -t -s '~')

	# Get width based on longest line
	RWIDTH=$(($(wc -L <<< "$LIST")*13))
	LINENUM=$(($(echo "$LIST" | wc -l)+2))


	if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
		LINENUM=8
	elif [[ "$CONSTATE" =~ "disabled" ]]; then
		LINENUM=1
	fi

	# dynamic theme string
	THEME="
	window { width: $RWIDTH px; }
	listview {
		lines: $LINENUM;
		fixed-height: false;
		scrollbar: false;
	}"

	# display menu; store user choice
	CHENTRY=$(echo -e "$TOGGLE\n Rescan\n$LIST" | uniq -u | rofi -dmenu -selected-row 1 -config "~/.config/rofi/wifimenu/theme.rasi" -theme-str "$THEME")
	# store selected SSID
	CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="Enable WiFi 直"
	CHENTRY=$(echo -e "$TOGGLE" | uniq -u | rofi -dmenu -selected-row 0 -config "~/.config/rofi/wifimenu/theme.rasi")
fi


if [ "$CHENTRY" = "" ]; then
    exit
elif [ "$CHENTRY" = " Rescan" ]; then
	~/.config/rofi/scripts/rofi-wifi-menu.sh -r
elif [ "$CHENTRY" = "Enable WiFi 直" ]; then
	nmcli radio wifi on
elif [ "$CHENTRY" = "Disable WiFi 睊" ]; then
	nmcli radio wifi off
else
    # get list of known connections
    KNOWNCON=$(nmcli connection show)
	
	# If the connection is already in use, then this will still be able to get the SSID
	if [ "$CHSSID" = "*" ]; then
		CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
	fi

	# Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
	if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
		nmcli con up "$CHSSID"
	else
		if [[ "$CHENTRY" =~ "" ]]; then
			WIFIPASS=$(echo " Press Enter if network is saved" | rofi -dmenu -p " WiFi Password: " -lines 1 )
		fi
		if nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
		then
			notify-send 'Connection successful'
		else
			notify-send 'Connection failed'
		fi
	fi
fi
