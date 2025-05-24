# Raspberry Pi 5 Headless Home Lab Server (`rpi5-tailscale-homeserver`)

## 1. Introduction & Project Goals

This project documents the step-by-step process of setting up a low-power, 24/7 headless Linux server using a Raspberry Pi 5. The primary motivation was to create a versatile and secure home lab environment for various technical explorations, including:

* Coding projects and development.
* Networking practice and experiments.
* Automation scripting and testing.
* General Linux server administration learning.
* Creating a personalized and informative server experience.

A key requirement for this project was establishing **secure remote access** to the server from any location. My concern with traditional methods like port forwarding was the direct exposure of my home network's public IP address and the potential security vulnerabilities. This led to the choice of using **Tailscale** to create a secure, private overlay network, allowing access without opening any inbound ports on my home router. Further security hardening was implemented using **Fail2Ban**, and the login experience was personalized with a custom **Message of the Day (MOTD)**.

This README serves as my personal knowledge base, a step-by-step guide for future reference, and hopefully, a helpful resource for others embarking on a similar journey.

## 2. Key Learnings & Skills Demonstrated

This project involved several key learning areas and skill applications:

* **Hardware Setup:** Assembling the Raspberry Pi 5 with an active cooler.
* **Operating System Installation:** Headless installation and configuration of Raspberry Pi OS (64-bit) using Raspberry Pi Imager.
* **Linux Server Administration:**
    * Initial server setup and critical first steps (password changes, system updates via `apt`).
    * Service management using `systemd` (`systemctl status`, `restart`, `enable`, `start`, `stop`).
    * Package management with `apt` (`install`, `update`, `upgrade`).
    * Navigating and editing files using the command line (`nano`).
    * Log file analysis for troubleshooting.
    * User group management (`usermod`).
    * Scripting for MOTD customization (Bash).
* **Networking:**
    * Understanding local IP addressing and mDNS (`.local` hostnames).
    * Basic network diagnostics (`ping`).
    * Secure Shell (SSH) for remote command-line access.
* **Security Implementation:**
    * Establishing secure remote access using **Tailscale**, avoiding direct port exposure.
    * Setting up **Fail2Ban** to protect against brute-force attacks on SSH, including configuration of jails and `ignoreip` whitelisting.
    * Implementing strong password policies and the critical importance of changing default/initial credentials.
* **Troubleshooting:** Diagnosing and resolving service startup issues (e.g., the Fail2Ban failure due to the missing `rsyslog`/`auth.log` and then correcting its configuration). This involved a systematic approach of checking service status, system logs, and configuration files.
* **System Customization:** Creating a dynamic and informative MOTD to personalize the server environment.

## 3. Why This Project for GitHub?

Documenting this process as a GitHub project is valuable because:

* **Knowledge Sharing & Learning Resource:** It provides a practical, detailed, real-world guide for others looking to set up a modern home server with a strong emphasis on security and personalization.
* **Demonstrates Practical Skills:** It showcases abilities in system administration, network configuration, security implementation, troubleshooting, and basic scripting – skills highly relevant in many technical roles.
* **Reproducibility:** The steps are laid out clearly, allowing others to replicate or adapt the setup.
* **Foundation for Future Work:** This server is the foundation for future software development, automation scripts, and more complex lab scenarios, which can be documented here or in linked projects.
* **Personal Reference:** Serves as a meticulous record of my own setup for future maintenance, upgrades, or rebuilds.

## 4. Hardware Used

* **Server Board:** Raspberry Pi 5 8GB
* **Power Supply:** A quality USB-C Power Supply with Power Delivery (PD), capable of delivering at least 27W (e.g., 5.1V @ 5A specifically for the Raspberry Pi 5). (This project used a CanaKit 45W model as an example).
* **Cooling:** Raspberry Pi 5 Active Cooler.
* **Storage:** A high-quality A2-rated microSDXC card, 64GB or larger (this project used a SanDisk 64GB Extreme A2 microSDXC UHS-I Card as an example).
* **SD Card Reader:** A USB-C (or USB-A) SD Card Reader (this project used a uni USB-C model with a Mac as an example).
* **Client Machine for Setup & Access:** An Apple MacBook was used as an example for initial SD card imaging and as the primary SSH client. Any modern PC (Windows, Linux) can be used.
* **Home Network Router:** Any home router capable of DHCP and internet access (this project used a TP-Link Deco BE11000 Mesh System as an example, but the principles for Tailscale access apply to most router setups).

## 5. Software Choices

* **Operating System (on Raspberry Pi):** Raspberry Pi OS (64-bit).
* **Remote Access Solution:** Tailscale.
* **Intrusion Prevention:** Fail2Ban.
* **MOTD Scripting Utilities:** `figlet` (for text banners).

## 6. Server Setup: Step-by-Step Guide

### Phase 1: Physical Assembly

1.  **Unbox All Components.**
2.  **Install Active Cooler:** Aligned over the Pi 5's CPU, secured with push pins, fan cable connected to the "FAN" connector.
3.  **(Optional) Case:** If using a case, ensure it's compatible with the Active Cooler and assemble.

### Phase 2: Preparing the microSD Card with Raspberry Pi OS (64-bit)

(Performed using a separate computer, e.g., Mac, Windows, Linux)

1.  **Download & Install Raspberry Pi Imager:**
    * From `https://www.raspberrypi.com/software/`.
2.  **Connect microSD Card to Computer:** Using the SD Card Reader.
3.  **Configure in Raspberry Pi Imager:**
    * **Device:** Select "Raspberry Pi 5".
    * **Operating System:** Select "Raspberry Pi OS (64-bit)".
    * **Storage:** Select your microSD card (verify by name and capacity, e.g., ~59-60GB for a 64GB card).
    * **OS Customisation (Click "Next" then "EDIT SETTINGS"):** Essential for headless setup.
        * **General Tab:**
            * Set **hostname:** e.g., `<your_pi_hostname>` (this project used `aqn-rpios` as an example). Enable ".local" name resolution.
            * Set **username:** e.g., `<your_pi_username>` (this project used `aqnguyen96` as an example).
            * Set **password:** Create a **strong, unique initial password**, e.g., `<your_strong_initial_password>`. **(This password MUST be changed immediately after your first login!)**
            * **Configure wireless LAN:** Tick the box. Enter your home Wi-Fi SSID and password. Select your appropriate **Wireless LAN country**. (Good practice, even if primarily using Ethernet).
            * **Set locale settings:** Set your appropriate **Time zone** and **Keyboard layout**.
        * **Services Tab:** Enable SSH (password authentication for initial setup).
        * Click **"SAVE"**.
    * **Write to Card:** Click **"WRITE"** and confirm. Wait for writing and verification.
4.  **Eject microSD Card:** After successful write and verification.

### Phase 3: First Boot of Raspberry Pi (Headless)

1.  **Insert microSD Card** into the Pi 5.
2.  **Connect Network:** Ethernet cable from Pi to home router (recommended for stability).
3.  **Connect Power:** Using the appropriate USB-C Power Supply.
4.  **Wait for Boot:** Allow 2-5 minutes.

### Phase 4: Initial Local SSH Connection & CRITICAL First Steps

1.  **Find Pi's Local IP Address:** Via router's client list or `ping <your_pi_hostname>.local`.
2.  **SSH into the Pi (Locally):**
    ```bash
    ssh <your_pi_username>@<LOCAL_PI_IP_ADDRESS_OR_HOSTNAME.LOCAL>
    ```
    Accept host authenticity. Enter the initial password.
3.  **!!! IMMEDIATE ACTION: Change Your Password !!!**
    ```bash
    passwd
    ```
    Enter current (initial) password, then enter and confirm a **new, strong, unique password**.
4.  **Update System Software:**
    ```bash
    sudo apt update
    sudo apt upgrade -y
    ```

### Phase 5: Setting up Tailscale for Secure Remote Access

Tailscale creates a private, encrypted network, chosen here to avoid opening router ports.

1.  **On the Raspberry Pi (`<your_pi_hostname>` - via SSH):**
    * **Install Tailscale:**
        ```bash
        curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh
        ```
    * **Start Tailscale & Authenticate:**
        ```bash
        sudo tailscale up
        ```
        Follow the output URL on a browser to log into your Tailscale account and authorize the Pi.
    * **Verify Service:** `sudo systemctl status tailscaled` (ensure active, running, enabled).

2.  **On Your Client Computer (e.g., Mac):**
    * **Download & Install Tailscale Client:** From `https://tailscale.com/download/`.
    * **Log In:** Use the **same Tailscale account**.

### Phase 6: Setting up Fail2Ban for Enhanced SSH Security

Fail2Ban protects services from brute-force attacks.

1.  **Install Fail2Ban on Raspberry Pi:**
    ```bash
    sudo apt install fail2ban
    ```
2.  **Address `rsyslog` Dependency (Troubleshooting & Learning):**
    * It was discovered that Fail2Ban might fail to start if `/var/log/auth.log` is missing. This can be due to `rsyslog.service` not being installed/running.
    * **Fix (if needed):** Install `rsyslog`:
        ```bash
        sudo apt update && sudo apt install rsyslog
        sudo systemctl start rsyslog.service && sudo systemctl enable rsyslog.service
        ```
        A new SSH login attempt should then create `/var/log/auth.log`.
3.  **Configure Fail2Ban (`/etc/fail2ban/jail.local`):**
    * Copied `jail.conf` to `jail.local`:
        ```bash
        sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        ```
    * Edited with `sudo nano /etc/fail2ban/jail.local`:
        * **`[DEFAULT]` section:**
            * Set `ignoreip`: This is crucial to avoid banning yourself.
                ```ini
                ignoreip = 127.0.0.1/8 ::1 <your_local_lan_cidr_e.g_192.168.1.0/24> <your_primary_client_tailscale_ip_100.x.y.z> <your_pi_tailscale_ip_100.x.y.z>
                ```
                *(Find your LAN CIDR from your router, and Tailscale IPs from the Tailscale app or `tailscale status` on each device.)*
            * Adjusted `bantime = 1h`, `findtime = 10m`, `maxretry = 3` (or as desired).
        * **`[sshd]` section:**
            * Ensured `enabled = true`.
            * `port = ssh`
            * `logpath = %(sshd_log)s`
            * `backend = %(sshd_backend)s`
4.  **Restart and Verify Fail2Ban:**
    ```bash
    sudo systemctl restart fail2ban
    sudo systemctl status fail2ban.service
    sudo fail2ban-client status sshd
    ```
    Confirm service is active and `sshd` jail is monitoring `auth.log`.

### Phase 7: Customizing the Welcome Message (MOTD)

To create a personalized and informative login experience:

1.  **Prerequisites:**
    * Install `figlet`: `sudo apt install figlet`
    * Add your server user to the `video` group (for CPU temperature via `vcgencmd`):
        ```bash
        sudo usermod -aG video <your_pi_username>
        ```
        (A logout/login is required for this group change to take effect).
2.  **MOTD Script Implementation:**
    * The script content is located in this repository at: `code/10-custom-welcome.sh` (You will create this file in a `code` subdirectory of your Git project and paste the script provided in our previous discussions there).
    * **To deploy it on your Raspberry Pi:**
        1.  Copy the `10-custom-welcome.sh` script from your Git project's `code` directory to your Raspberry Pi server, placing it in the `/etc/update-motd.d/` directory. You can name it, for example, `10-custom-welcome` on the Pi.
            ```bash
            # Example: If you cloned this repo to your Pi's home directory in a folder named 'rpi5-tailscale-homeserver'
            # sudo cp ~/rpi5-tailscale-homeserver/code/10-custom-welcome.sh /etc/update-motd.d/10-custom-welcome
            ```
        2.  Make the script executable on the Pi:
            ```bash
            sudo chmod +x /etc/update-motd.d/10-custom-welcome
            ```
3.  **Client-Side Terminal Theme:**
    * For the best visual experience with this MOTD (especially the colors and ASCII art), I configured my SSH client's terminal application (on my Mac) to use a **black background theme**. This is a client-side setting and is not controlled by the server's MOTD script itself.
4.  **(Optional) Managing other MOTD scripts:**
    * Your system may have other default scripts in `/etc/update-motd.d/` (e.g., `10-uname`). If their output becomes redundant, you can disable them by removing their execute permissions:
        ```bash
        # Example: To disable the '10-uname' script
        # sudo chmod -x /etc/update-motd.d/10-uname
        ```
5.  **Testing:**
    * Log out of your SSH session and log back in to see your new custom MOTD in action.

### Phase 8: Accessing the Server Securely

* **Primary Remote Access (from anywhere):** Via Tailscale, using the server's Tailscale IP or MagicDNS hostname.
    ```bash
    ssh <your_pi_username>@<YOUR_PI_TAILSCALE_IP_OR_HOSTNAME>
    ```
* **Local Network Access:**
    ```bash
    ssh <your_pi_username>@<your_pi_hostname>.local
    ```
    Enter the **new, secure password** set in Phase 4.

### Phase 9: Exiting SSH Sessions

From the client terminal connected to the Pi:
* Type `exit` or `logout` and press Enter.
* Or press `Ctrl+D`.

## 7. Overview: Tailscale Benefits for This Project

* **Enhanced Security:** Avoids opening inbound router ports, significantly reducing direct exposure to the public internet. This was a primary design goal.
* **Simplicity:** Much easier to set up and manage for secure remote access compared to traditional VPNs or manual port forwarding rules.
* **Stable Access:** Provides consistent hostnames (via MagicDNS) and private `100.x.y.z` IP addresses for devices within the tailnet, abstracting away complexities of dynamic public IPs or local IP changes.
* **True "Access from Anywhere":** Enables SSH access to the Pi from authorized client devices from any location with an internet connection.
* **Generous Free Tier:** Tailscale's "Personal" plan is well-suited for home lab use (check their website for current details).

## 8. Power Efficiency

The Raspberry Pi 5, combined with the lightweight Tailscale service, provides a very power-efficient solution for a 24/7 server, making it economical to run continuously.

## 9. Adding More Client Devices to Tailscale

1.  Install the Tailscale client on the new device (Windows, Linux, macOS, iOS, Android).
2.  Log in to the same Tailscale account.
3.  The new device joins your private tailnet and can then use SSH (with an appropriate client app if it's a mobile device) to connect to `<your_pi_hostname>` using its Tailscale IP or name.

## 10. Future Plans & Next Steps

* [X] Customize MOTD with ASCII art and dynamic info. *(Implemented!)*
* [X] Set up Fail2Ban for basic SSH protection. *(Implemented! Further review of rules can be ongoing.)*
* [ ] Implement SSH Key Authentication and disable password authentication for SSH access via Tailscale/LAN for maximum security.
* [ ] Install and configure a personal Git server (e.g., Gitea).
* [ ] Explore hosting Docker containers for various applications (e.g., web apps, databases, monitoring tools).
* [ ] Set up network monitoring tools.
* [ ] Develop and test Python automation scripts.
* [ ] Document specific lab projects undertaken on this server in separate files or linked repositories.

## 11. Troubleshooting Log & Lessons Learned

* **Lesson 1: Fail2Ban & `rsyslog` Dependency.**
    * **Issue:** Fail2Ban service failed to start after initial installation.
    * **Diagnosis:** Debug mode (`sudo /usr/bin/fail2ban-server -xf -vvv start`) showed an error about not finding `/var/log/auth.log`.
    * **Root Cause:** `rsyslog.service` was not installed or running, preventing the creation of `auth.log`.
    * **Resolution:** Installed `rsyslog` (`sudo apt install rsyslog`), then started and enabled the service. This allowed `/var/log/auth.log` to be created, and Fail2Ban started successfully.
    * **Learning:** Always verify service dependencies, especially for logging mechanisms. System logs are crucial for troubleshooting, and verbose/debug startup modes for services are invaluable for diagnosis.
* **Lesson 2: MOTD Update Checker Package Evolution.**
    * **Issue:** The `update-notifier-common` package, often used for MOTD update counts, was not available or was obsoleted in the current OS version.
    * **Resolution:** Switched to using `apt list --upgradable | grep -vc "Listing..."` within the MOTD script to get a count of upgradable packages.
    * **Learning:** Package names and availability can change between OS versions or distributions; be prepared to find alternative methods or commands for desired functionality.
