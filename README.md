# 🧱 Monolith Firewall

> **A modern, web-UI-based, and fully extensible firewall distribution built from the ground up with C# and Debian.**

![License](https://img.shields.io/badge/license-NC--MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Debian-green.svg)
![Language](https://img.shields.io/badge/language-C%23-orange.svg)

Monolith Firewall is a **security-focused Linux distribution** designed to deliver enterprise-grade firewall and routing capabilities with an intuitive, modern **web interface** — similar to pfSense, but built from scratch using C# and Debian.

It provides a clean UI, a fast backend, and powerful features for sysadmins, homelabbers, and security enthusiasts.

---

## ✨ Features

- 🖥️ **Modern Web UI** — manage your firewall entirely through a clean, browser-based interface.  
- 🔥 **Custom C# backend** — optimized for speed, security, and flexibility.  
- 🐧 Based on **Debian** for stability and support.  
- 🧰 Modular security rule system with extensible plugins.  
- 📡 Real-time traffic monitoring and packet filtering.  
- 🛡️ Hardened out of the box with minimal overhead.  
- 🧠 Easy to deploy, easy to manage — no CLI wizardry required (unless you want it).

---

## 💿 Download

You can download the latest **Monolith Firewall ISO** from the [**Releases**](../../releases) page.  

Once downloaded:

1. Burn it to a USB drive or mount it in your hypervisor.  
2. Boot and install or run in live mode.  
3. Access the web UI via your browser (default LAN IP & credentials shown on first boot).  
4. Start configuring your network security in minutes.

> 💡 Works great on both physical and virtual machines.

---

## 🧰 Build It Yourself (Optional)

For advanced users who want to **build Monolith Firewall from source** or customize the distro, check out the [**Wiki**](../../wiki) for full build instructions.

The wiki covers:
- Environment setup  
- Dependencies  
- Building the C# backend  
- Packaging into an ISO  
- Adding your own modules or UI elements

---

## 🧪 Example Usage (Web UI)

- ✅ Set up WAN/LAN interfaces through the dashboard  
- ✍️ Create or modify firewall rules in a point-and-click interface  
- 📊 Monitor real-time traffic graphs  
- 🧱 Manage NAT, VPN, routing, and DHCP  
- 🔐 Enable additional services like IDS/IPS modules

> Default web interface: `http://192.168.1.1` (or the IP you configure during setup)

---

## 🤝 Contributing

We welcome contributions from the community! 🙌  
Whether it’s bug reports, feature requests, UI improvements, or backend modules — every bit helps.

1. Fork the repo  
2. Create a new branch  
3. Make your changes  
4. Submit a pull request 🚀

Discussions and extra developer notes are available in the [Wiki](../../wiki).

---

## 📜 License

This project — **Monolith Firewall** — is licensed under the **Non-Commercial MIT License (NC-MIT)**.  
You may use, modify, and share this software for personal and non-commercial purposes.

For commercial licensing inquiries, please contact: `[your-email@example.com]`.

---

## 🌟 Roadmap

- [ ] Web-based rule editor enhancements  
- [ ] VPN & multi-WAN support  
- [ ] IDS/IPS integration  
- [ ] Plugin marketplace  
- [ ] Traffic shaping & QoS  
- [ ] Dark mode 🌙

---

## ❤️ Acknowledgments

- Debian and the open-source community 🐧  
- The pfSense community for inspiring a better open firewall experience  
- Everyone who contributes to building secure networks  
- You — for trying Monolith Firewall 🙌
