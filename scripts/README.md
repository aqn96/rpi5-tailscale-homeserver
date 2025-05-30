### Phase 7: Customizing the Welcome Message (MOTD)

To create a personalized and informative login experience, a custom Message of the Day (MOTD) script was implemented. This script displays custom ASCII art, a "H O M E L A B" title generated by `figlet`, and various pieces of dynamic system information with color coding for readability.

1.  **Prerequisites for the MOTD script:**
    * **Install `figlet`:** This utility is used for creating large text banners.
      ```bash
      sudo apt install figlet
      ```
    * **User Group for CPU Temperature:** For the MOTD to display the Raspberry Pi's CPU temperature using `vcgencmd` without requiring `sudo` privileges (MOTD scripts run as the logged-in user), the user needs to be added to the `video` group. Replace `<your_pi_username>` with your actual username on the Pi:
      ```bash
      sudo usermod -aG video <your_pi_username>
      ```
      **Important:** A full logout from all sessions and a new login is required for this group change to take effect for the user.

2.  **MOTD Script Implementation:**
    * The script content is located in this repository at: `code/10-custom-welcome.sh` (or your chosen path).
    * **To use it:**
        1.  Copy the `10-custom-welcome.sh` script from this repository to your Raspberry Pi server, placing it in the `/etc/update-motd.d/` directory. You can name it, for example, `10-custom-welcome`.
            ```bash
            # Example: If you cloned this repo to your Pi's home directory in a folder named 'my-server-project'
            # sudo cp ~/my-server-project/code/10-custom-welcome.sh /etc/update-motd.d/10-custom-welcome
            ```
        2.  Make the script executable:
            ```bash
            sudo chmod +x /etc/update-motd.d/10-custom-welcome
            ```

3.  **Client-Side Terminal Theme:**
    * For the best visual experience with this MOTD (especially the colors and ASCII art), I configured my SSH client's terminal application (on my Mac) to use a **black background theme**. This is a client-side setting and is not controlled by the server's MOTD script itself.

4.  **(Optional) Managing other MOTD scripts:**
    * Your system may have other default scripts in `/etc/update-motd.d/` (e.g., `10-uname` which prints basic Linux version info). If their output becomes redundant with your custom MOTD, you can disable them by removing their execute permissions:
      ```bash
      # Example: To disable the '10-uname' script
      # sudo chmod -x /etc/update-motd.d/10-uname
      ```
      You can re-enable them later with `sudo chmod +x ...` if desired.

5.  **Testing:**
    * Log out of your SSH session and log back in to see your new custom MOTD in action.
