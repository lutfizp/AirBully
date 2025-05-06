import subprocess
import re
import sys
import time
import os
import threading
from scapy.all import *

found_aps = {}
CHANNELS = list(range(1, 14))  # 2.4GHz channels
HOP_DELAY = 1  # seconds

def get_monitor_interface_rtl():
    try:
        output = subprocess.check_output(['iwconfig'], stderr=subprocess.DEVNULL).decode()
        interfaces = re.findall(r'^(\w+)\s+IEEE 802\.11', output, re.MULTILINE)

        for iface in interfaces:
            if 'rtl8814au' in get_driver_info(iface) and 'Mode:Monitor' in get_interface_info(iface):
                return iface
        return None
    except Exception as e:
        print(f"[!] Error mendeteksi interface: {e}")
        return None

def get_driver_info(iface):
    try:
        out = subprocess.check_output(['ethtool', '-i', iface], stderr=subprocess.DEVNULL).decode()
        match = re.search(r'driver:\s*(\S+)', out)
        return match.group(1) if match else "unknown"
    except:
        return "unknown"

def get_interface_info(iface):
    try:
        out = subprocess.check_output(['iwconfig', iface], stderr=subprocess.DEVNULL).decode()
        return out
    except:
        return ""

def channel_hopper(interface):
    while True:
        for ch in CHANNELS:
            try:
                subprocess.call(['iwconfig', interface, 'channel', str(ch)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                time.sleep(HOP_DELAY)
            except KeyboardInterrupt:
                break

def parse_pmf(rsn_data):
    if len(rsn_data) < 22:
        return "Tidak ada"
    try:
        pmf_byte = rsn_data[20]
        pmf_capable = (pmf_byte & 0b01000000) != 0
        pmf_required = (pmf_byte & 0b10000000) != 0

        if pmf_required:
            return "PMF Required"
        elif pmf_capable:
            return "PMF Optional"
        else:
            return "PMF Tidak Aktif"
    except Exception:
        return "Parsing Error"

def handle_packet(pkt):
    if pkt.haslayer(Dot11Beacon) or pkt.haslayer(Dot11ProbeResp):
        bssid = pkt[Dot11].addr2
        ssid = pkt[Dot11Elt].info.decode(errors='ignore') if pkt[Dot11Elt].info else "<Hidden>"
        rsn = pkt.getlayer(Dot11Elt, ID=48)

        if bssid not in found_aps:
            pmf_status = parse_pmf(rsn.info) if rsn else "Tidak ada"
            found_aps[bssid] = (ssid, pmf_status)

def print_results():
    os.system('clear')  # Ganti ke 'cls' jika di Windows
    print(f"[{time.strftime('%H:%M:%S')}] Hasil scan:")
    print(f"{'SSID':<30} {'MAC Address':<20} {'PMF Status'}")
    print("-" * 70)
    for bssid, (ssid, pmf_status) in found_aps.items():
        print(f"{ssid:<30} {bssid:<20} {pmf_status}")

def main():
    print("[*] Mendeteksi interface RTL8814AU dalam mode monitor...")
    iface = get_monitor_interface_rtl()

    if not iface:
        print("[!] Tidak ditemukan interface RTL8814AU dalam mode monitor.")
        sys.exit(1)

    print(f"[+] Menggunakan interface: {iface}")

    # Start channel hopping in background
    hopper = threading.Thread(target=channel_hopper, args=(iface,), daemon=True)
    hopper.start()

    while True:
        sniff(iface=iface, prn=handle_packet, store=0, timeout=5)
        print_results()
        time.sleep(1)
def scan_once_and_output():
    iface = get_monitor_interface_rtl()
    if not iface:
        print("ERROR: Interface RTL8814AU tidak ditemukan atau bukan mode monitor.", file=sys.stderr)
        sys.exit(1)

    # Jalankan hopping sebentar
    hopper = threading.Thread(target=channel_hopper, args=(iface,), daemon=True)
    hopper.start()

    # Scan selama 10 detik
    sniff(iface=iface, prn=handle_packet, store=0, timeout=10)

    # Output dalam format yang mudah diparse
    for bssid, (ssid, pmf_status) in found_aps.items():
        print(f"{ssid}|||{bssid}|||{pmf_status}")

if __name__ == "__main__":
    if "--scan-once" in sys.argv:
        scan_once_and_output()
    else:
        main()

