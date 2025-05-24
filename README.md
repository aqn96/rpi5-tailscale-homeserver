# Project: My Raspberry Pi 5 Headless Home Lab Server (`rpi5-tailscale-homeserver`)

## 1. Introduction & Project Goals

This project documents the end-to-end process of setting up a low-power, 24/7 headless Linux server using a Raspberry Pi 5. The primary motivation was to create a versatile and secure home lab environment for various technical explorations, including:

* **Software Development:** Hosting Git repositories, running development environments, and testing applications.
* **Networking Practice:** Experimenting with network configurations, services (DNS, DHCP), and security.
* **Automation:** Developing and deploying automation scripts (e.g., Python, Ansible).
* **General Linux Server Administration:** Gaining hands-on experience with managing a Linux server.
* **Continuous Learning:** Using this server as a platform for ongoing technical skill development.

A critical requirement for this project was establishing **secure remote access** to the server from any location. My concern with traditional methods like port forwarding was the direct exposure of my home network's public IP address and the potential security vulnerabilities associated with it. This led me to research and implement **Tailscale**, a solution that creates a secure, private overlay network, allowing access without opening any inbound ports on my home router. This README details that choice and its implementation, alongside other security measures like **Fail2Ban**.

This document serves as my personal knowledge base, a step-by-step guide for future reference, and hopefully, a helpful resource for others embarking on a similar journey.

## 2. Key Learnings & Skills Demonstrated

This project involved several key learning areas and skill applications:

* **Hardware Setup:** Assembling the Raspberry Pi 5 with an active cooler.
* **Operating System Installation:** Headless installation and configuration of Raspberry Pi OS (64-bit) using Raspberry Pi Imager.
* **Linux Server Administration:**
    * Initial server setup and critical first steps (password changes, system updates via `apt`).
    * User and permission management (implicitly).
    * Service management using `systemd` (`systemctl status`, `restart`, `enable`).
    * Package management with `apt`.
    * Navigating and editing files using the command line (`nano`).
    * Log file analysis for troubleshooting.
* **Networking:**
    * Understanding local IP addressing and mDNS (`.local` hostnames).
    * Basic network diagnostics (`ping`).
    * Secure Shell (SSH) for remote command-line access.
* **Security Implementation:**
    * Establishing secure remote access using **Tailscale**, avoiding direct port exposure.
    * Setting up **Fail2Ban** to protect against brute-force attacks on SSH.
    * Understanding and configuring Fail2Ban jails and `ignoreip` settings.
    * Implementing strong password policies (and the critical importance of changing defaults).
* **Troubleshooting:** Diagnosing and resolving service startup issues (e.g., the Fail2Ban failure due to the missing `rsyslog`/`auth.log` and then correcting its configuration). This involved a systematic approach of checking service status, logs, and configuration files.

## 3. Why This Project for GitHub?

While the initial setup might not involve extensive custom software development, documenting this process as a GitHub project is valuable because:

* **Knowledge Sharing:** It provides a practical, detailed, real-world guide for others looking to set up a secure and modern home server.
* **Demonstrates Practical Skills:** It showcases abilities in system administration, network configuration, security implementation, and problem-solving – skills highly relevant in many technical roles.
* **Reproducibility:** The steps are laid out clearly, allowing others to replicate or adapt the setup.
* **Foundation for Future Work:** This server is the foundation for future software development, automation scripts, and more complex lab scenarios, which will be documented here or in linked projects.
* **Personal Reference:** Serves as a meticulous record of my own setup for future maintenance, upgrades, or rebuilds.

## 4. Hardware Used

* **Server Board:** Raspberry Pi 5 8GB
* **Power Supply:** A quality USB-C Power Supply with Power Delivery (PD), capable of delivering at least 27W (e.g., 5.1V @ 5A specifically for the Raspberry Pi 5). (This project used a CanaKit 45W model).
* **Cooling:** Raspberry Pi 5 Active Cooler.
* **Storage:** A high-quality A2-rated microSDXC card, 64GB or larger (this project used a SanDisk 64GB Extreme A2 microSDXC UHS-I Card).
* **SD Card Reader:** A USB-C (or USB-A) SD Card Reader (this project used a uni USB-C model with a Mac).
* **Client Machine for Setup & Access:** An Apple MacBook was used for initial SD card imaging and as the primary SSH client.
* **Home Network Router:** A home router capable of DHCP and internet access (this project used a TP-Link Deco BE11000 Mesh System).

## 5. Software Choices

* **Operating System (on Raspberry Pi):** Raspberry Pi OS (64-bit).
* **Remote Access Solution:** Tailscale.
* **Intrusion Prevention:** Fail2Ban.

## 6. Server Setup: Step-by-Step Guide

### Phase 1: Physical Assembly

1.  **Unbox All Components.**
2.  **Install Active Cooler:**
    * Carefully align the Active Cooler over the Pi 5's CPU and mounting points.
    * Secure it with its spring-loaded push pins.
    * Connect the cooler's 4-pin fan cable to the "FAN" connector on the Pi 5 board.
3.  **(Optional) Case:** If using a case, ensure it's compatible with the Active Cooler and assemble.

### Phase 2: Preparing the microSD Card with Raspberry Pi OS (64-bit)

This is performed using a separate computer (e.g., Mac, Windows, Linux).

1.  **Download & Install Raspberry Pi Imager:**
    * From `https://www.raspberrypi.com/software/`.
2.  **Connect microSD Card to Computer:**
    * Insert the microSD card into the SD Card Reader and plug it into the computer.
3.  **Configure in Raspberry Pi Imager:**
    * **Device:** Select "Raspberry Pi 5".
    * **Operating System:** Select "Raspberry Pi OS (64-bit)".
    * **Storage:** Select your microSD card (verify by name and capacity, e.g., ~59-60GB for a 64GB card).
    * **OS Customisation (Click "Next" then "EDIT SETTINGS"):** Essential for headless setup.
        * **General Tab:**
            * Set **hostname:** e.g., `<your_pi_hostname>` (this project used `aqn-rpios`). Enable ".local" name resolution.
            * Set **username:** e.g., `<your_pi_username>` (this project used `aqnguyen96`).
            * Set **password:** Create a **strong, unique initial password**, e.g., `<your_strong_initial_password>`. **(This password MUST be changed immediately after your first login!)**
            * **Configure wireless LAN:** Tick the box. Enter your home Wi-Fi SSID and password. Select your appropriate **Wireless LAN country**. (Good practice, even if primarily using Ethernet).
            * **Set locale settings:** Set your appropriate **Time zone** and **Keyboard layout**.
        * **Services Tab:**
            * **Enable SSH:** Ensure this is checked/ON. Select "Use password authentication" (for initial setup).
        * Click **"SAVE"**.
    * **Write to Card:** Click **"WRITE"** and confirm. Wait for writing and verification.
4.  **Eject microSD Card:**
    * Once "Write Successful," safely eject the card reader and remove the microSD card.

### Phase 3: First Boot of Raspberry Pi (Headless)

1.  **Insert microSD Card:** Into the Raspberry Pi 5.
2.  **Connect Network:** Connect an Ethernet cable from the Pi to a LAN port on your home router for stability.
3.  **Connect Power:** Connect the USB-C Power Supply to the Pi. It will power on.
4.  **Wait for Boot:** Allow 2-5 minutes.

### Phase 4: Initial Local SSH Connection & CRITICAL First Steps

1.  **Find Pi's Local IP Address:**
    * Check your router's admin page for connected devices (look for `<your_pi_hostname>`).
    * Or, from your client computer's Terminal: `ping <your_pi_hostname>.local`
2.  **SSH into the Pi (Locally):**
    * From your client computer's Terminal:
        ```bash
        ssh <your_pi_username>@<LOCAL_PI_IP_ADDRESS>
        # or
        ssh <your_pi_username>@<your_pi_hostname>.local
        ```
    * Accept host authenticity (`yes`) on the first connection.
    * Enter the initial password: `<your_strong_initial_password>`
3.  **!!! IMMEDIATE ACTION: Change Your Password !!!**
    * At the Pi's command prompt:
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

Tailscale creates a private, encrypted network, enabling secure access without router port forwarding.

1.  **On the Raspberry Pi (`<your_pi_hostname>` - via the current SSH session):**
    * **Install Tailscale:**
        ```bash
        curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh
        ```
    * **Start Tailscale and Authenticate:**
        ```bash
        sudo tailscale up
        ```
        This outputs an authentication URL.
    * **Authenticate in a Browser:** Copy the URL, open it in a browser on your client computer, log into your Tailscale account (create one if needed using a provider like Google, Microsoft, or GitHub), and authorize your Raspberry Pi.
    * **Verify Tailscale Service:**
        ```bash
        sudo systemctl status tailscaled
        ```
        (Should show `Active: active (running)`, `enabled`, and "Connected" with your Tailscale account email and a `100.x.y.z` Tailscale IP).
        You can also check with `tailscale ip -4` or `tailscale status`.

2.  **On Your Client Computer (e.g., Mac):**
    * **Download and Install Tailscale:** From `https://tailscale.com/download/`.
    * **Log In:** Launch Tailscale and log in using the **same Tailscale account**.

### Phase 6: Setting up Fail2Ban for Enhanced SSH Security

Fail2Ban adds another layer by banning IPs that show malicious signs like repeated failed login attempts.

1.  **Install Fail2Ban on the Raspberry Pi:**
    ```bash
    sudo apt install fail2ban
    ```
2.  **Troubleshooting `rsyslog` (A Key Learning Moment):**
    * **Initial Symptom:** After first installing Fail2Ban, the service failed to start (`sudo systemctl status fail2ban.service` showed `Active: failed (Result: exit-code)` and `status=255/EXCEPTION`).
    * **Diagnosis:** Running `sudo /usr/bin/fail2ban-server -xf -vvv start` revealed the error: `ERROR Failed during configuration: Have not found any log file for sshd jail` because it couldn't find `/var/log/auth.log`.
    * **Root Cause:** Checking `sudo systemctl status rsyslog.service` showed `Unit rsyslog.service could not be found`, indicating `rsyslog` (which creates `auth.log`) was not installed.
    * **Solution:**
        ```bash
        sudo apt update
        sudo apt install rsyslog
        sudo systemctl start rsyslog.service
        sudo systemctl enable rsyslog.service 
        ```
        After this, logging out and back into SSH created `/var/log/auth.log`, allowing Fail2Ban to start.

3.  **Configure Fail2Ban (`/etc/fail2ban/jail.local`):**
    * Copy the default configuration to a local file for customization:
        ```bash
        sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        ```
    * Edit the local configuration:
        ```bash
        sudo nano /etc/fail2ban/jail.local
        ```
    * **Inside `[DEFAULT]` section:**
        * Set `ignoreip`: This is crucial to avoid banning yourself.
            ```ini
            ignoreip = 127.0.0.1/8 ::1 <your_local_lan_cidr_e.g_192.168.68.0/24> <your_primary_client_tailscale_ip> <your_pi_tailscale_ip>
            ```
            *(Find your LAN CIDR from your router, and Tailscale IPs from the Tailscale app or `tailscale status` on each device.)*
        * Adjust `bantime`, `findtime`, `maxretry` as desired (e.g., `1h`, `10m`, `3` respectively).
            ```ini
            bantime  = 1h
            findtime = 10m
            maxretry = 3
            ```
    * **Inside `[sshd]` section:**
        * Ensure it's enabled:
            ```ini
            [sshd]
            enabled = true
            port    = ssh
            # logpath and backend usually use sensible defaults like %(sshd_log)s
            logpath = %(sshd_log)s 
            backend = %(sshd_backend)s
            ```
    * Save the file and exit `nano` (`Ctrl+X`, then `Y`, then `Enter`).
4.  **Restart and Verify Fail2Ban:**
    ```bash
    sudo systemctl restart fail2ban
    sudo systemctl status fail2ban.service 
    # Should now show "active (running)" and "Server ready"
    sudo fail2ban-client status sshd
    # Should show the jail active and monitoring /var/log/auth.log
    ```

### Phase 7: Accessing the Server Securely via Tailscale

1.  **Ensure Tailscale is Running:** On both your client computer and on `<your_pi_hostname>`.
2.  **SSH via Tailscale from Client Computer:**
    ```bash
    ssh <your_pi_username>@<YOUR_PI_TAILSCALE_IP>
    # Or, using Tailscale's MagicDNS:
    ssh <your_pi_username>@<your_pi_hostname>
    # If needed, use the full Tailscale FQDN:
    # ssh <your_pi_username>@<your_pi_hostname>.<your-tailnet-name>.ts.net
    ```
    Enter the **new, secure password** you set for `<your_pi_username>` on the Pi.

### Phase 8: Exploring Raspberry Pi OS

1.  **`raspi-config` Utility:**
    * For Pi-specific configurations (interfaces, localization, etc.):
        ```bash
        sudo raspi-config
        ```

## 7. Overview: Tailscale Benefits for This Project

* **Enhanced Security:** Avoids opening inbound ports on the home router, shielding the server from direct public internet exposure. This was a primary driver for choosing Tailscale.
* **Simplicity:** Much easier to set up and manage for secure remote access compared to traditional VPNs or manual port forwarding.
* **Stable Access:** Provides consistent hostnames (MagicDNS) and private `100.x.y.z` IP addresses for devices within the tailnet, abstracting away complexities of dynamic public IPs.
* **True "Access from Anywhere":** Enables SSH access to the Pi from authorized devices from any location with internet.
* **Generous Free Tier:** Tailscale's "Personal" plan is well-suited for home lab use.
* **Performance for SSH:** Typically very good, prioritizing direct peer-to-peer connections.

## 8. Power Efficiency

The Raspberry Pi 5, combined with the lightweight Tailscale service, provides a very power-efficient solution for a 24/7 server.

## 9. Adding More Client Devices to Tailscale

1.  Install the Tailscale client on the new device.
2.  Log in to the same Tailscale account.
3.  The device joins your private tailnet and can then SSH to `<your_pi_hostname>` using its Tailscale IP or name.

## 10. How to Exit an SSH Session

From the client terminal connected to the Pi:
* Type `exit` and press Enter.
* Or type `logout` and press Enter.
* Or press `Ctrl+D`.
The server and Tailscale will continue running on the Pi.

## 11. Future Plans for This Server

* [ ] Implement SSH Key Authentication and disable password authentication for SSH access via Tailscale/LAN for maximum security.
* [ ] Set up a personal Git server (e.g., Gitea).
* [ ] Host Docker containers for various applications (e.g., web apps, databases, monitoring tools).
* [ ] Develop and test Python automation scripts that interact with network services or APIs.
* [ ] Customize the MOTD (Message of the Day) with useful server stats or ASCII art.
* [ ] Document specific lab projects undertaken on this server.

## 12. Troubleshooting Log & Lessons Learned

* **Issue:** Fail2Ban service failed to start after initial installation and configuration of `jail.local`.
    * **Symptoms:** `sudo systemctl status fail2ban.service` showed `Active: failed (Result: exit-code)` and `status=255/EXCEPTION`. Running `sudo fail2ban-client status` gave `ERROR Failed to access socket path... Is fail2ban running?`.
    * **Diagnosis:** Running `sudo /usr/bin/fail2ban-server -xf -vvv start` revealed the critical error: `ERROR Failed during configuration: Have not found any log file for sshd jail` because it couldn't find `/var/log/auth.log`.
    * **Root Cause:** Further investigation with `sudo systemctl status rsyslog.service` showed `Unit rsyslog.service could not be found`. The `rsyslog` service, responsible for creating `/var/log/auth.log` on Debian-based systems, was not installed.
    * **Resolution:**
        1.  Installed `rsyslog`: `sudo apt update && sudo apt install rsyslog`.
        2.  Ensured the service was started and enabled: `sudo systemctl start rsyslog.service && sudo systemctl enable rsyslog.service`.
        3.  Initiated a new SSH login to generate entries in `auth.log`, confirming its creation with `ls -l /var/log/auth.log`.
        4.  Restarted Fail2Ban: `sudo systemctl restart fail2ban.service`.
        5.  Verified Fail2Ban status: `sudo systemctl status fail2ban.service` (now active) and `sudo fail2ban-client status sshd` (showing monitoring of `auth.log`).
    * **Lesson Learned:** Essential system services like `rsyslog` are crucial for other dependent services (like Fail2Ban) to function. Always verify dependencies if a service fails to start after a seemingly correct configuration. Verbose/debug startup modes are invaluable for diagnosis.
