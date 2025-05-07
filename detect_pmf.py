import subprocess
import re
import sys
import time
import os
import threading
from scapy.all import *

found_aps = {}
CHANNELS = list(range(1, 14))  # 2.4GHz channels
HOP_DELAY = 0.5  # reduced from 1 second to 0.5 for faster hopping

def get_monitor_interface_rtl():
    try:
        output = subprocess.check_output(['iwconfig'], stderr=subprocess.DEVNULL).decode()
        interfaces = re.findall(r'^(\w+)\s+IEEE 802.11', output, re.MULTILINE)

        for iface in interfaces:
            if 'rtl8814au' in get_driver_info(iface) and 'Mode:Monitor' in get_interface_info(iface):
                return iface
                
        # If we can't find specifically rtl8814au in monitor mode, find any monitor mode interface
        for iface in interfaces:
            if 'Mode:Monitor' in get_interface_info(iface):
                print(f"[!] RTL8814AU not found, but found alternative monitor interface: {iface}")
                return iface
                
        return None
    except Exception as e:
        print(f"[!] Error detecting interface: {e}")
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
        try:
            bssid = pkt[Dot11].addr2
            
            # Extract SSID, handle all exceptions
            try:
                if pkt.haslayer(Dot11Elt) and pkt[Dot11Elt].ID == 0:
                    ssid = pkt[Dot11Elt].info.decode(errors='ignore')
                else:
                    for element in pkt.iterpayloads():
                        if isinstance(element, Dot11Elt) and element.ID == 0:
                            ssid = element.info.decode(errors='ignore')
                            break
                    else:
                        ssid = "<Hidden>"
            except:
                ssid = "<Error Extracting SSID>"
            
            # Look for RSN element
            rsn = None
            for element in pkt.iterpayloads():
                if isinstance(element, Dot11Elt) and element.ID == 48:  # 48 is RSN
                    rsn = element
                    break

            if bssid not in found_aps:
                pmf_status = parse_pmf(rsn.info) if rsn else "Tidak ada"
                found_aps[bssid] = (ssid, pmf_status)
                print(f"[+] Found network: {ssid} ({bssid}) - PMF: {pmf_status}")
        except Exception as e:
            pass  # Silently handle malformed packets

def print_results():
    os.system('clear')  # Change to 'cls' if on Windows
    print(f"[{time.strftime('%H:%M:%S')}] Scan results:")
    print(f"{'SSID':<30} {'MAC Address':<20} {'PMF Status'}")
    print("-" * 70)
    for bssid, (ssid, pmf_status) in found_aps.items():
        print(f"{ssid:<30} {bssid:<20} {pmf_status}")

def main():
    print("[*] Detecting monitor mode interface...")
    iface = get_monitor_interface_rtl()

    if not iface:
        print("[!] No monitor mode interface found.")
        sys.exit(1)

    print(f"[+] Using interface: {iface}")

    hopper = threading.Thread(target=channel_hopper, args=(iface,), daemon=True)
    hopper.start()

    while True:
        sniff(iface=iface, prn=handle_packet, store=0, timeout=5)
        print_results()
        time.sleep(1)

def scan_once_and_output():
    iface = get_monitor_interface_rtl()
    if not iface:
        print("ERROR: Monitor mode interface not found.", file=sys.stderr)
        sys.exit(1)

    hopper = threading.Thread(target=channel_hopper, args=(iface,), daemon=True)
    hopper.start()

    # Scan for 15 seconds
    sniff(iface=iface, prn=handle_packet, store=0, timeout=15)

    # Output in parsable format
    for bssid, (ssid, pmf_status) in found_aps.items():
        print(f"{ssid}|||{bssid}|||{pmf_status}")

def scan_for_target_essid(interface, target_essid):
    global found_aps
    found_aps = {}

    print(f"[*] Scanning for target ESSID: '{target_essid}'...")
    print(f"[*] This will take up to 30 seconds...")

    # Start channel hopping
    hopper = threading.Thread(target=channel_hopper, args=(interface,), daemon=True)
    hopper.start()

    # Scan for a longer time (30 seconds)
    start_time = time.time()
    max_time = 30  # seconds
    
    while time.time() - start_time < max_time:
        sniff(iface=interface, prn=handle_packet, store=0, timeout=2)
        
        # Check if target found
        for bssid, (ssid, pmf_status) in found_aps.items():
            if ssid == target_essid:
                print(f"{ssid}|||{bssid}|||{pmf_status}")
                return
    
    # If we reach here, the target wasn't found
    print(f"NOT_FOUND|||{target_essid}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--scan-once', action='store_true', help='Scan once and print all APs')
    parser.add_argument('--interface', help='Wireless interface in monitor mode')
    parser.add_argument('--target-essid', help='Target ESSID to look for')
    parser.add_argument('--extended-scan', action='store_true', help='Perform an extended scan (60 seconds)')

    args = parser.parse_args()

    if args.scan_once:
        scan_once_and_output()
    elif args.interface and args.target_essid:
        if args.extended_scan:
            print("[*] Performing extended 60-second scan...")
            max_time = 60
        scan_for_target_essid(args.interface, args.target_essid)
    else:
        main()