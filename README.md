# rpi5-tailscale-homeserver
Assemble and Config a home server for personal usage.

# Project: My Raspberry Pi 5 Headless Home Lab Server (`aqn-rpios`)

## 1. Introduction & My Goals

This project documents the step-by-step process of setting up a low-power, 24/7 headless Linux server using a Raspberry Pi 5. The primary goal is to create a versatile home lab environment located in for:

* Coding projects and development.
* Networking practice and experiments.
* Automation scripting and testing.
* General Linux server administration learning.

A key requirement for this project was to establish **secure remote access** to the server from anywhere. I wanted to avoid the potential security vulnerabilities associated with traditional port forwarding, which would expose my home network's public IP address directly to the internet for services like SSH. After considering various options, I chose to use **Tailscale** to create a secure, private overlay network for my devices. This approach allows me to log in without opening any inbound ports on my home router, addressing my security concerns.

This README serves as both my personal documentation and a guide for others who might be interested in a similar, secure home server setup.

## 2. Why This Project for GitHub?

Even though this initial setup phase doesn't involve extensive custom software development, documenting this process is valuable for several reasons:

* **Learning & Sharing:** It provides a practical, real-world guide for setting up a modern home server with a strong emphasis on security and ease of remote access.
* **Reproducibility:** Others can follow these steps to replicate or adapt this setup for their own needs.
* **Best Practices:** It incorporates important considerations for initial server setup, security hardening (like immediate password changes and using Tailscale), and efficient operation.
* **Foundation for Future Projects:** This server (`aqn-rpios`) will be the base for many future coding, automation, and networking projects, which *will* involve more code. Documenting the foundation is key.
* **Demonstrating Skills:** This project showcases skills in system administration, network configuration, problem-solving, and security awareness.
* **Personal Knowledge Base:** It acts as a detailed record for myself, ensuring I can recreate or troubleshoot the setup if needed.

## 3. Hardware Used

* **Server Board:** Raspberry Pi 5 8GB
* **Power Supply:** CanaKit 45W USB-C Power Supply with PD (using the 27W @ 5.1A mode optimized for Raspberry Pi 5)
* **Cooling:** Raspberry Pi 5 Active Cooler
* **Storage:** SanDisk 64GB Extreme microSDXC UHS-I A2 Card (Model: SDSQXAH-064G-GN6MA)
* **SD Card Reader:** uni USB-C SD Card Reader (used with a Mac for preparing the microSD card)
* **Client Machine for Setup & Access:** Apple MacBook
* **Home Network Router:** TP-Link Deco BE11000 Mesh System

## 4. Software Choices

* **Operating System (on Raspberry Pi):** Raspberry Pi OS (64-bit) - Chosen for its official support, optimization for Raspberry Pi hardware, user-friendly tools like `raspi-config`, and a familiar Debian-based Linux environment.
* **Remote Access Solution:** Tailscale - Chosen for its ability to create a secure overlay network, providing encrypted remote access without requiring open inbound ports on my home router, thus enhancing security and simplifying connectivity.

## 5. Server Setup: Step-by-Step Guide

Here's the detailed process followed to set up `aqn-rpios`:

### Phase 1: Physical Assembly

1.  **Unbox All Components:** All parts were laid out and checked.
2.  **Install Active Cooler:**
    * The Raspberry Pi 5 Active Cooler was carefully aligned over the Pi 5's CPU and mounting points.
    * It was secured using its spring-loaded push pins.
    * The cooler's 4-pin fan cable was connected to the "FAN" connector on the Pi 5 board.
3.  **(Optional) Case:** If a case is used, it should be compatible with the Active Cooler and assembled at this stage.

### Phase 2: Preparing the microSD Card with Raspberry Pi OS (64-bit) (Using a Mac)

1.  **Download & Install Raspberry Pi Imager:**
    * The latest version of Raspberry Pi Imager for macOS was downloaded from `https://www.raspberrypi.com/software/` and installed on the Mac.
2.  **Connect microSD Card to Mac:**
    * The SanDisk 64GB microSD card was inserted into the uni USB-C SD Card Reader.
    * The reader was then plugged into a USB-C port on the Mac.
3.  **Configure in Raspberry Pi Imager:**
    * **Device:** Selected "Raspberry Pi 5".
    * **Operating System:** Selected "Raspberry Pi OS (64-bit)".
    * **Storage:** Selected the SanDisk 64GB microSD card (identified in Imager, e.g., as "apple SDXC Reader MEDIA" with an approximate capacity of 59-60GB).
    * **OS Customisation (Accessed via "Next" then "EDIT SETTINGS"):**
        * **General Tab:**
            * Hostname set to: `aqn-rpios` (with ".local" name resolution enabled).
            * Username set to: `aqnguyen96`.
            * Initial Password set to: `159753Aqn#$%rpios` **(Crucial Note: This password was set for initial setup only and was changed immediately after the first login for security reasons).**
            * Wireless LAN configured with home Wi-Fi SSID and password (Country: US for San Diego). This serves as a backup/alternative to Ethernet.
            * Locale Settings: Time zone set to `America/Los_Angeles`, Keyboard layout to `US`.
        * **Services Tab:**
            * SSH enabled, using password authentication (for the initial login).
        * Settings were saved.
    * **Write to Card:** Clicked **"WRITE"** and confirmed the action. Waited for the writing and verification process to complete.
4.  **Eject microSD Card:**
    * Once Raspberry Pi Imager confirmed "Write Successful," the card reader was safely ejected from the Mac, and the microSD card was removed.

### Phase 3: First Boot of Raspberry Pi (Headless)

1.  **Insert microSD Card:** The prepared microSD card was inserted into the Raspberry Pi 5.
2.  **Connect Network:** An Ethernet cable was connected from the Pi's Ethernet port to a LAN port on the TP-Link Deco BE11000 router for a stable connection.
3.  **Connect Power:** The CanaKit USB-C Power Supply was connected to the Pi, powering it on.
4.  **Wait for Boot:** Allowed 2-5 minutes for the Raspberry Pi to complete its first boot sequence and connect to the network.

### Phase 4: Initial Local SSH Connection & CRITICAL First Steps

1.  **Find Pi's Local IP Address:**
    * Checked the TP-Link Deco app (or web interface, if accessible) for `aqn-rpios` in the list of connected devices to find its local IP address.
    * Alternatively, from the Mac's Terminal: `ping aqn-rpios.local`
2.  **SSH into the Pi (Locally):**
    * From the Mac's Terminal:
        ```bash
        ssh aqnguyen96@<LOCAL_PI_IP_ADDRESS> 
        # or, if mDNS/Bonjour resolves:
        ssh aqnguyen96@aqn-rpios.local
        ```
    * Accepted host authenticity on the first connection by typing `yes`.
    * Entered the initial password: `159753Aqn#$%rpios`
3.  **!!! IMMEDIATE ACTION: Changed Password !!!**
    * This was the **first command run** after logging in for security:
        ```bash
        passwd
        ```
    * Entered the current (initial) password.
    * Entered and confirmed a **new, strong, unique password**.
4.  **Update System Software:**
    ```bash
    sudo apt update
    sudo apt upgrade -y
    ```

### Phase 5: Setting up Tailscale for Secure Remote Access

My primary motivation for choosing Tailscale was to establish secure remote access to `aqn-rpios` without exposing any ports on my home router, thereby minimizing security vulnerabilities.

1.  **On the Raspberry Pi (`aqn-rpios` - via the SSH session from Phase 4):**
    * **Install Tailscale:**
        ```bash
        curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh
        ```
    * **Start Tailscale and Authenticate:**
        ```bash
        sudo tailscale up
        ```
        This command provided an authentication URL.
    * **Authenticate in a Browser:** The provided URL was copied and opened in a web browser on the Mac. I logged into my Tailscale account (using `aqnguyen96@gmail.com`) and authorized the `aqn-rpios` device to join my tailnet.
    * **Verify Tailscale Service:**
        ```bash
        sudo systemctl status tailscaled
        ```
        The output confirmed the service was `Active: active (running)`, `enabled` (to start on boot), and connected, showing my Tailscale email and the Pi's Tailscale IP address (e.g., `100.79.63.64`).

2.  **On My Mac (Client Device):**
    * **Download and Install Tailscale:** The macOS client was downloaded from `https://tailscale.com/download/` and installed.
    * **Log In:** Launched Tailscale on the Mac and logged in using the **same Tailscale account** (`aqnguyen96@gmail.com`).

### Phase 6: Accessing the Server via Tailscale (Remotely or Locally)

1.  **Ensure Tailscale is Running:** On both the Mac and `aqn-rpios`.
2.  **Connect via SSH using Tailscale:**
    * The Raspberry Pi's Tailscale IP address (e.g., `100.79.63.64`) or its Tailscale machine name (`aqn-rpios`) can be used.
    * From the Mac's Terminal:
        ```bash
        ssh aqnguyen96@100.79.63.64 
        # Or, using Tailscale's MagicDNS (usually works by default):
        ssh aqnguyen96@aqn-rpios
        # If the short name doesn't resolve immediately, the full Tailscale FQDN can be used:
        # ssh aqnguyen96@aqn-rpios.your-tailnet-name.ts.net 
        # (Find your tailnet name in the Tailscale admin console's DNS settings)
        ```
    * Entered the **new, secure password** set for `aqnguyen96` on the Pi.

### Phase 7: Exploring Raspberry Pi OS & Further Server Setup

1.  **`raspi-config` Utility:**
    * This tool can be used for Pi-specific configurations:
        ```bash
        sudo raspi-config
        ```
2.  **Server Ready:** The server is now operational and accessible securely. Further customization (like the ASCII art MOTD) and software installation for lab purposes can now proceed.

## 6. Deep Dive: Tailscale for This Project

* **What it is:** Tailscale creates a secure, zero-configuration VPN, forming a private network (a "tailnet") that interconnects authorized devices directly using WireGuard® encryption.
* **Why it was the right choice for me:**
    * **Enhanced Security:** It allows remote access without opening any inbound ports on my TP-Link Deco router. This directly addresses my concern about minimizing the attack surface on my home network. My server isn't directly visible or scannable from the public internet.
    * **Simplicity:** Significantly easier to set up and manage compared to configuring a traditional VPN server or meticulously managing port forwarding rules and associated security measures (like Fail2Ban, though Fail2Ban can still be used for local SSH hardening).
    * **Stable Connectivity:** Tailscale provides consistent hostnames (via MagicDNS) and `100.x.y.z` IP addresses for devices within my tailnet, regardless of changes in their local network IPs or my home's public IP address.
    * **True "Access from Anywhere" Capability:** I can SSH into `aqn-rpios` from my Mac or other authorized devices from any location with an internet connection, as long as Tailscale is running on both ends.
* **Free Tier:** Tailscale's "Personal" plan is free for up to 3 users and 100 devices, which is more than sufficient for this home lab.
* **Performance:** For SSH, latency is generally very good. Tailscale prioritizes direct peer-to-peer (P2P) connections. If P2P isn't possible due to network restrictions, it uses its DERP (Designated Encrypted Relay for Packets) servers, which might add some latency, but SSH remains highly usable.
* **Adding New Devices to Access the Server:**
    1.  Install the Tailscale client on the new device (Windows, Linux, macOS, iOS, Android).
    2.  Log in to the same Tailscale account (`aqnguyen96@gmail.com`).
    3.  The new device joins the tailnet and can then use SSH (with an appropriate client app if it's a mobile device) to connect to `aqn-rpios` using its Tailscale IP or name.
* **Is Tailscale always running on `aqn-rpios`?** Yes, the installation process sets up Tailscale (`tailscaled`) as a system service that starts automatically on boot and runs in the background, ensuring the server is consistently part of the tailnet and available for connection.

## 7. Power Efficiency Considerations

The Raspberry Pi 5 is known for its low power consumption (idling around 2.5-3.5 Watts, with higher but still modest consumption under load). The Tailscale service adds a negligible amount to this, making this setup very economical for a 24/7 server.

## 8. How to Exit an SSH Session

To log out of an SSH session connected to `aqn-rpios` from the client (e.g., Mac Terminal):
* Type `exit` and press Enter.
* Or type `logout` and press Enter.
* Or press `Ctrl+D` (sends an end-of-file signal).
The server `aqn-rpios` and its Tailscale service will continue running.

## 9. Future Plans for `aqn-rpios`

* [ ] Implement SSH Key Authentication and disable password authentication for SSH for enhanced security.
* [ ] Set up Fail2Ban for an extra layer of protection (even with Tailscale, good for local network access attempts).
* [ ] Install and configure a Git server (e.g., Gitea) for personal coding projects.
* [ ] Explore hosting Docker containers for various applications and services.
* [ ] Set up network monitoring tools or practice network configurations.
* [ ] Develop and test Python automation scripts.
* [ ] Customize the MOTD (Message of the Day) with ASCII art for a personalized welcome.
* [ ] Document specific lab projects undertaken on this server.

## 10. Troubleshooting Log (To be updated as needed)

* *(Placeholder: This section will be used to document any issues encountered during setup or later use, and the steps taken to resolve them.)*

---

This README should provide a very thorough documentation of your project! Remember to replace the placeholder `your-tailnet-name.ts.net` with your actual one if you ever need to use the full FQDN. Good luck with your home lab!
