# Android TV Bulk Controller (ADB)

This project provides a robust Bash script to manage multiple Android TVs (TCL, KiVi, etc.) simultaneously via ADB (Android Debug Bridge) over a local network. It supports bulk power control, custom URL redirection, Android TV default home page redirection and automated sequences.


## 🚀 Features

* **Bulk Power Control:** Turn multiple TVs on or off (Standby) with one command.
* **Custom Redirection:** Send specific URLs to specific TVs based on a configuration map.
* **Automated Sequence:** Power ON -> Wait -> Redirect to URL (Standby).
* **Targeted Execution:** Control all devices or a specific comma-separated list of IPs.
* **Robust Loop Logic:** Designed to prevent script termination on connection errors.


## 📋 Prerequisites

* **ADB Platform Tools:** Ensure `adb` executable is in the project folder or added to your system PATH.
* **Bash Environment:**
    1. Linux/macOS: Native terminal
    2. Windows: Use Git bash (Highly recommended) or WSL.
* **Network/USB Debugging:** Must be enabled in the Developer Options of each TV. Note: The ways to enable Developer options are different for each TV. You should research the Internet for each model.
* **Authorized Devices:** You must manually authorize the PC once on each TV (select "Always allow from this computer"). When you want to connect TV via adb from your PC, an approval dialog appears on TV screen, after Allow button click you can use each commands for controling your TV.


## ⚙️ Configuration

Create a file named `ip_link_map.txt` in the root directory. Use the following format:

```bash
# IP_Address:Port      Target_URL
192.168.1.101:5555    http://your-local-link.com/screen-1
192.168.1.102:5555    http://your-local-link.com/screen-2
# You can add comments using the # symbol
```


## 🛠 Usage

Run the script from your terminal using the following commands:

```bash
sh monitor_control.sh power       Toggles power (On/Standby) for all TVs.
sh monitor_control.sh home        Returns all TVs to the Home screen.
sh monitor_control.sh redirect    Opens custom URLs defined in ip_link_map.txt.
sh monitor_control.sh sequence    Runs the full Auto-On -> Redirect -> Auto-Off sequence.
```

