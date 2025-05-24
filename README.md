# Project: Raspberry Pi 5 Headless Home Server with Tailscale (`rpi5-tailscale-homeserver`)

## 1. Introduction & Project Goals

This project documents the step-by-step process of setting up a low-power, 24/7 headless Linux server using a Raspberry Pi 5. The primary goal is to create a versatile home lab environment for:

* Coding projects and development.
* Networking practice and experiments.
* Automation scripting and testing.
* General Linux server administration learning.

A key requirement for this project was to establish **secure remote access** to the server from anywhere. To avoid the potential security vulnerabilities associated with traditional port forwarding (which would expose my home network's public IP address directly to the internet for services like SSH), I chose to use **Tailscale**. Tailscale creates a secure, private overlay network, allowing access without opening any inbound ports on my home router.

This README serves as a comprehensive guide for anyone interested in a similar, secure home server setup.

## 2. Why This Project for GitHub?

Even though this initial setup phase doesn't involve extensive custom coding, documenting this process is valuable:

* **Learning & Sharing:** It provides a practical, real-world guide for setting up a modern home server.
* **Reproducibility:** Others can follow these steps for their own setups.
* **Best Practices:** It incorporates considerations for security (a core theme) and ease of remote access.
* **Foundation for Future Projects:** This server will be the base for many coding and automation projects. Documenting the foundation is key.
* **Infrastructure Skills:** Demonstrates skills in system setup, network configuration, and security implementation.

## 3. Hardware Used

* **Server Board:** Raspberry Pi 5 8GB
* **Power Supply:** A quality USB-C Power Supply with PD, capable of delivering at least 27W (5.1V @ 5A) for the Raspberry Pi 5 (e.g., CanaKit 45W model).
* **Cooling:** Raspberry Pi 5 Active Cooler (or a compatible third-party cooling solution).
* **Storage:** A high-quality A2-rated microSDXC card, 64GB or larger (e.g., SanDisk Extreme/Extreme Plus 64GB microSDXC UHS-I A2 Card).
* **SD Card Reader:** A USB-C (or USB-A) SD Card Reader (for preparing the microSD card on a host computer like a Mac or PC).
* **Management Client:** A computer (e.g., Mac, Windows PC, Linux desktop) for initial SD card imaging and as an SSH client.
* **Home Network Router:** Any home router capable of providing DHCP and internet access (this guide used a TP-Link Deco BE11000 Mesh System as an example, but the principles apply to most routers for the Tailscale method).

## 4. Software Choices

* **Operating System (on Raspberry Pi):** Raspberry Pi OS (64-bit) - Chosen for its optimization for Raspberry Pi hardware, official support, and helpful utilities like `raspi-config`.
* **Remote Access Solution:** Tailscale - Chosen for its secure overlay networking, ease of setup, and ability to provide remote access without opening inbound ports on the home router.

## 5. Server Setup: Step-by-Step Guide

### Phase 1: Physical Assembly

1.  **Unbox All Components.**
2.  **Install Active Cooler:**
    * Carefully align the Active Cooler over the Pi 5's CPU and mounting points.
    * Secure it with its spring-loaded push pins.
    * Connect the cooler's 4-pin fan cable to the "FAN" connector on the Pi 5 board.
3.  **(Optional) Case:** If using a case compatible with the Active Cooler, install the Pi assembly into it.

### Phase 2: Preparing the microSD Card with Raspberry Pi OS (64-bit)

This is done using a separate computer (e.g., your Mac or PC).

1.  **Download & Install Raspberry Pi Imager:**
    * From `https://www.raspberrypi.com/software/`, download and install the Raspberry Pi Imager for your computer's OS.
2.  **Connect microSD Card to Computer:**
    * Insert your microSD card into the SD Card Reader.
    * Plug the reader into your computer.
3.  **Configure in Raspberry Pi Imager:**
    * **Device:** Select "Raspberry Pi 5".
    * **Operating System:** Select "Raspberry Pi OS (64-bit)".
    * **Storage:** Select your microSD card (verify by name and capacity, e.g., ~59-60GB for a 64GB card).
    * **OS Customisation (Click "Next" then "EDIT SETTINGS"):** This is crucial for a headless setup.
        * **General Tab:**
            * Set **hostname:** Choose a unique name for your Pi on the network, e.g., `<your_pi_hostname>` (Enable ".local" name resolution).
            * Set **username:** Choose a username, e.g., `<your_pi_username>`.
            * Set **password:** Create a **strong, unique initial password**, e.g., `<your_strong_initial_password>`. **(This password MUST be changed immediately after your first login!)**
            * **Configure wireless LAN:** Tick the box. Enter your home Wi-Fi SSID (network name) and password. Select your appropriate **Wireless LAN country**. (This is good practice even if primarily using Ethernet).
            * **Set locale settings:** Set your appropriate **Time zone** and **Keyboard layout**.
        * **Services Tab:**
            * **Enable SSH:** Ensure this is checked/ON. Select "Use password authentication" (for this initial setup).
        * Click **"SAVE"**.
    * **Write to Card:** Click **"WRITE"** and confirm the action. Wait for writing and verification to complete.
4.  **Eject microSD Card:**
    * Once "Write Successful," safely eject the card reader from your computer and remove the microSD card.

### Phase 3: First Boot of Raspberry Pi (Headless)

1.  **Insert microSD Card:** Into the Raspberry Pi 5.
2.  **Connect Network:** Connect an Ethernet cable from the Pi to a LAN port on your home router (recommended for stability).
3.  **Connect Power:** Connect the USB-C Power Supply to the Pi. It will power on.
4.  **Wait for Boot:** Allow 2-5 minutes for the first boot sequence.

### Phase 4: Initial Local SSH Connection & CRITICAL First Steps

1.  **Find Pi's Local IP Address:**
    * Check your router's admin page for connected devices (look for `<your_pi_hostname>`).
    * Or, from your client computer's Terminal/Command Prompt: `ping <your_pi_hostname>.local`
2.  **SSH into the Pi (Locally):**
    * From your client computer's Terminal/Command Prompt:
        ```bash
        ssh <your_pi_username>@<LOCAL_PI_IP_ADDRESS>
        # or, if mDNS/Bonjour resolves:
        ssh <your_pi_username>@<your_pi_hostname>.local
        ```
    * Accept host authenticity (`yes`) on the first connection.
    * Enter the initial password: `<your_strong_initial_password>`
3.  **!!! IMMEDIATE ACTION: Change Your Password !!!**
    * This is the **first command to run** after logging in:
        ```bash
        passwd
        ```
    * Enter the current (initial) password.
    * Enter and confirm a **new, strong, unique password**.
4.  **Update System Software:**
    ```bash
    sudo apt update
    sudo apt upgrade -y
    ```

### Phase 5: Setting up Tailscale for Secure Remote Access

Tailscale creates a private, encrypted network for your devices, enabling secure remote access without opening router ports.

1.  **On the Raspberry Pi (`<your_pi_hostname>` - via the current SSH session):**
    * **Install Tailscale:**
        ```bash
        curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh
        ```
    * **Start Tailscale and Authenticate:**
        ```bash
        sudo tailscale up
        ```
        This will output an authentication URL (e.g., `https://login.tailscale.com/a/YOUR_AUTH_CODE`).
    * **Authenticate in a Browser:** Copy this URL, open it in a browser on your client computer, and log into your Tailscale account (create one if needed using a provider like Google, Microsoft, or GitHub). Authorize your Raspberry Pi device.
    * **Verify Tailscale Service:**
        ```bash
        sudo systemctl status tailscaled
        ```
        (Should show `Active: active (running)`, `enabled`, and "Connected" with your Tailscale account email and a `100.x.y.z` Tailscale IP).

2.  **On Your Client Computer (e.g., Mac, Windows PC, Linux Desktop):**
    * **Download and Install Tailscale:** From `https://tailscale.com/download/`, get the client for your OS and install it.
    * **Log In:** Launch Tailscale and log in using the **same Tailscale account** used for your Raspberry Pi.

### Phase 6: Accessing the Server via Tailscale (Remotely or Locally)

1.  **Ensure Tailscale is Running:** On both your client computer and on `<your_pi_hostname>`.
2.  **Find Pi's Tailscale IP/Name:** Your Pi (`<your_pi_hostname>`) will have a `100.x.y.z` IP address visible in the Tailscale app on your client or via `tailscale ip -4` on the Pi.
3.  **SSH via Tailscale from Client Computer:**
    ```bash
    ssh <your_pi_username>@<YOUR_PI_TAILSCALE_IP>
    # Or, using Tailscale's MagicDNS (usually enabled by default):
    ssh <your_pi_username>@<your_pi_hostname>
    # If the short hostname doesn't resolve immediately, try the full Tailscale FQDN:
    # ssh <your_pi_username>@<your_pi_hostname>.<your-tailnet-name>.ts.net
    # (You can find your unique ".<your-tailnet-name>.ts.net" suffix in the Tailscale admin console's DNS settings)
    ```
    Enter the **new, secure password** you set for `<your_pi_username>` on the Pi.

### Phase 7: Exploring Raspberry Pi OS & Further Setup

1.  **`raspi-config` Utility:**
    * For Pi-specific configurations (interfaces, localization, etc.):
        ```bash
        sudo raspi-config
        ```
2.  **Server Ready:** Your server is now operational and securely accessible via Tailscale. You can now install software for your coding, networking, automation projects, and further customize your server environment (e.g., setting up a custom MOTD with ASCII art).

## 6. Deep Dive: Tailscale for This Project

* **What it is:** Tailscale creates a secure, zero-configuration VPN, forming a private network (a "tailnet") that interconnects authorized devices directly using WireGuard® encryption.
* **Why it was chosen for this home server:**
    * **Enhanced Security:** It avoids opening any inbound ports on my home router. This was a primary design goal to shield the server from direct scans and attacks from the public internet.
    * **Simplicity:** It's significantly easier to set up and manage compared to traditional VPNs or manual port forwarding rules.
    * **Stable Access:** Provides consistent hostnames (via MagicDNS) and `100.x.y.z` IP addresses for devices within the tailnet, regardless of changes in local network IPs or the home's public IP address.
    * **True "Access from Anywhere":** Allows secure SSH access to `<your_pi_hostname>` from authorized client devices from any location with an internet connection.
* **Free Tier:** Tailscale's "Personal" plan is free for many users and devices (check their website for current details, typically generous for home use).
* **Performance:** For SSH and many home lab tasks, latency is usually very good. Tailscale prioritizes direct peer-to-peer (P2P) connections. If P2P isn't possible due to network restrictions, it uses its DERP (Designated Encrypted Relay for Packets) servers, which might add some latency, but SSH typically remains highly usable.
* **Adding New Client Devices to Access the Server:**
    1.  Install the Tailscale client on the new device (Windows, Linux, macOS, iOS, Android).
    2.  Log in to the same Tailscale account.
    3.  The new device joins your private tailnet and can then use SSH (with an appropriate client app if it's a mobile device) to connect to `<your_pi_hostname>` using its Tailscale IP or name.

## 7. Power Efficiency

The Raspberry Pi 5 is very power-efficient (idling around 2.5-3.5 Watts, with higher but still modest consumption under load). The Tailscale service adds a negligible amount to this, making this setup ideal for an economical 24/7 server.

## 8. How to Exit an SSH Session

To log out of an SSH session connected to `<your_pi_hostname>` from the client computer:
* Type `exit` and press Enter.
* Or type `logout` and press Enter.
* Or press `Ctrl+D` (sends an end-of-file signal to the shell).
The server (`<your_pi_hostname>`) and its Tailscale service will continue running, ready for the next connection.

## 9. Future Plans for This Server

* [ ] Implement SSH Key Authentication and disable password authentication for SSH for enhanced security.
* [ ] Set up Fail2Ban for an extra layer of protection against any attempted unwanted access (even within the local network or if Tailscale had a hypothetical vulnerability).
* [ ] Install and configure a Git server (e.g., Gitea) for personal coding projects.
* [ ] Explore hosting Docker containers for various applications and services.
* [ ] Set up network monitoring tools or practice network configurations.
* [ ] Develop and test Python automation scripts.
* [ ] Customize the MOTD (Message of the Day) with ASCII art for a personalized welcome.
* [ ] Document specific lab projects undertaken on this server in separate files or subdirectories.

## 10. Troubleshooting Log (To be updated as needed)

* *(Placeholder: This section will be used to document any issues encountered during setup or later use, and the steps taken to resolve them.)*

---
This should be a great, anonymized, and comprehensive starting point for your GitHub README!
