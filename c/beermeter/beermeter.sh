#!/bin/sh
title='Beer-O-Meter'
accounts='./accounts'
totals="$accounts/.totals"
backend='./audio.sh'
tmp="/tmp/beertmp-$$";
dialog=$(which dialog);

beer_stat() {
	echo $(wc -c "$accounts/$1" | cut -d ' ' -f 1) piv
}

add_account() {
	"$dialog" --inputbox "New account name" 0 0 2>"$tmp"
	[ $? = 0 ] && touch "$accounts/$(cat "$tmp")";
}

servis_menu() {
	$dialog --menu "$title servis" 0 0 0 new "Novy stamgast" exit "Konec party" 2>"$tmp"
	option="$(cat "$tmp")"

	case $option in
		new)
			add_account
			;;
		exit)
			clear
			echo "=== Totals ($totals) ==="
			echo
			cat "$totals"
			echo
			exit
			;;
	esac
}

beer_menu() {
	echo -n > "$totals"
	ls -1 --group-directories-first "$accounts" | while read i; do
		echo -n "$i"; echo -ne "\x00";
		echo -n $(beer_stat "$i");  echo -ne "\x00"
		echo -e "$i\t$(beer_stat "$i")" >> "$totals"
	done | xargs -0 $dialog --menu "$title stamgasti" 0 0 0
}

main_menu() {
	while true; do
		beer_menu 2>"$tmp"
		[ "$?" = "0" ] && {
			stamgast="$(cat "$tmp")"
			clear
			echo == Cepuje stamgast $stamgast, ukonci ctrl+c ==
			"$backend" | tee -a "$accounts/$stamgast"
			true
		} || servis_menu
	done
}

main_menu
