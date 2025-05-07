```
       ..                 .                      ...     ..                           ..       ..              
    :**888H: `: .xH""    @88>                 .=*8888x <"?88h.                  x .d88"  x .d88"    ..         
   X   `8888k XX888      %8P      .u    .    X>  '8888H> '8888      x.    .      5888R    5888R    @L          
  '8hx  48888 ?8888       .     .d88B :@8c  '88h. `8888   8888    .@88k  z88u    '888R    '888R   9888i   .dL  
  '8888 '8888 `8888     .@88u  ="8888f8888r '8888 '8888    "88>  ~"8888 ^8888     888R     888R   `Y888k:*888. 
   %888>'8888  8888    ''888E`   4888>'88"   `888 '8888.xH888x.    8888  888R     888R     888R     888E  888I 
     "8 '888"  8888      888E    4888> '       X" :88*~  `*8888>   8888  888R     888R     888R     888E  888I 
    .-` X*"    8888      888E    4888>       ~"   !"`      "888>   8888  888R     888R     888R     888E  888I 
      .xhx.    8888      888E   .d888L .+     .H8888h.      ?88    8888 ,888B .   888R     888R     888E  888I 
    .H88888h.~`8888.>    888&   ^"8888*"     :"^"88888h.    '!    "8888Y 8888"   .888B .  .888B .  x888N><888' 
   .~  `%88!` '888*~     R888"     "Y"       ^    "88888hx.+"      `Y"   'YP     ^*888%   ^*888%    "88"  888  
         `"     ""        ""                        ^"**""                         "%       "%            88F  
                                                                                                         98"   
                                                                                                       ./"
                                                                                                      ~`
(c) Copyright by LTFZP 2025
```     
**AirBully** is a semi-automated toolkit designed to perform targeted WPA3 Transition Mode downgrade attacks by deploying Rogue Access Points and inducing deauthentication against clients.

It guides the attacker through scanning, selecting the target, preparing the environment, and executing a full rogue AP operation with minimal manual configuration.

---
Why the name "Air Bully"?
In the wireless (air) environment, this tool acts as a "bully" — forcefully manipulating client behavior by leveraging deauthentication and rogue AP tactics. Specifically, it "bullies" WPA3-capable clients into downgrading their security to vulnerable WPA2-PSK connections, opening the door for traditional attacks.

## Features
![AirBully](https://github.com/user-attachments/assets/b6f08463-38d9-4ad3-b8fe-e30efada0fe8)

- Automatic wireless interface detection.
- Initial network scan and ESSID discovery.
- Deep RSN (Robust Security Network) parameter parsing — **beyond** simple airodump-ng outputs.
- Intelligent ESSID and BSSID selection.
- Rogue AP deployment using **hostapd-mana**.
- Targeted client deauthentication using **aireplay-ng**.
- Dependency auto-checker with optional auto-installer.
- Friendly terminal UI and error handling.

![Airbully](https://github.com/user-attachments/assets/609ab0a3-e6ab-45ed-8cc5-4071eb6011ec)

---

## Requirements

| Binary         | Package         |
|----------------|-----------------|
| iwconfig       | wireless-tools  |
| airodump-ng    | aircrack-ng     |
| aireplay-ng    | aircrack-ng     |
| tshark         | tshark          |
| hostapd-mana   | hostapd-mana    |
| xxd            | vim-common      |

**Note:** The script will automatically detect and offer to install any missing dependencies.

---

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/airbully.git
   cd airbully
   ```

2. Make the script executable:
   ```bash
   chmod +x airbully.sh
   ```

3. Run the script:
   ```bash
   sudo ./airbully.sh
   ```

---

## ⚙️ How It Works

1. **Detect** wireless interfaces available.
2. **Scan** surrounding networks and select target ESSID.
3. **Analyze** RSN security parameters for downgrade viability.
4. **Identify** associated clients (stations).
5. **Deploy** a Rogue AP mimicking the legitimate network.
6. **Launch** controlled deauthentication against a target client.
7. **Capture** handshake or initiate further exploitation.

---
![Screenshot 2025-05-07 112154](https://github.com/user-attachments/assets/f71e7fce-6552-489a-a773-7acab17a4cec)

![Screenshot 2025-05-07 112332](https://github.com/user-attachments/assets/1af305d5-ba8a-4821-ae1e-adc79a19e642)


## Current Limitations

- Attack **only works on networks running WPA3 Transition Mode** — pure WPA3 (SAE-only) networks are not vulnerable.
- Attack is **only effective if the target access point does not have Protected Management Frames (PMF) enabled**
- Manual intervention needed after client scan — future versions may automate capture analysis.

---

## Advantages

- **Deep RSN scanning:**  
  Unlike basic airodump-ng outputs, AirBully parses RSN IE (Information Elements) in greater detail using `tshark`, detecting AKM suite types and cipher suites more accurately.

- **Educational-friendly:**  
  AirBully was designed not only for attackers but also for researchers, students, and penetration testers who want a better understanding of wireless protocol weaknesses.

- **Semi-automated process:**  
  A clear step-by-step flow allows faster engagement with minimal room for manual mistakes.

---
# Roadmap (Coming Soon)
- PMF detection
- Better client recon 
- Full WPA3 SAE attack path research.
---
