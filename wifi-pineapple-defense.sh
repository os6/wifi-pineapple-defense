#!/bin/bash
# prevent automatic ssid association to hotspot honeypots (wifi pineapple) by removing non whitelisted ssids from os x preferred networks (run as cron job)

whitelist=('ssidname1' 'ssidname2')

if [ ${#whitelist[@]} -eq 0 ]; then
	echo "you must define ssid names in the whitelist."
	exit 1
fi

IFS=$'\n';
num=0
wifi=`networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/,/Ethernet/' | awk 'NR==2' | cut -d " " -f 2`
ssids=( $(networksetup -listpreferredwirelessnetworks $wifi | sed -n '1!p' | sed 's/	//g') )

echo "-> starting wifi pineapple defense"
echo "-> checking for new preferred networks on $wifi.."
for i in "${ssids[@]}"; do
	if [[ "${whitelist[*]}" =~ $i ]]; then
		:
	else
		networksetup -removepreferredwirelessnetwork $wifi $i
		let num=num+1
	fi
done
echo "-> finished, removed ($num) entries"