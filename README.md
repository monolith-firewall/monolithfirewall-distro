# 🧱 Monolith Firewall

> **A modern, lightweight, and fully extensible firewall distribution built from the ground up with C# and Debian.**

![License](https://img.shields.io/badge/license-NC--MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Debian-green.svg)
![Language](https://img.shields.io/badge/language-C%23-orange.svg)

Monolith Firewall is a purpose-built security-focused Linux distribution designed to deliver **powerful, modular network protection** without the unnecessary bloat.  
It combines the stability of Debian with a custom C#-based firewall engine, giving administrators full control over their network perimeter.

---

## ✨ Features

- 🔥 **Custom-built engine in C#** — fast, lightweight, and extensible.  
- 🐧 Based on **Debian** for proven stability.  
- 🧰 Modular security rules system — build or load what you need.  
- 📡 Real-time traffic inspection and packet filtering.  
- 🛡️ Hardened out of the box with a minimal footprint.  
- 🧠 Simple, scriptable CLI for easy rule management.

---

## 💿 Download

You can download the latest Monolith Firewall ISO directly from the [**Releases**](../../releases) page.

Once downloaded, you can:

- Burn it to a USB drive
- Install or run it live
- Start protecting your network immediately 🚀

> 💡 For the best results, use a dedicated physical or virtual machine.

---

## 🧰 Build It Yourself (Optional)

If you prefer to build Monolith Firewall from source, you can follow the step-by-step instructions in the [**Wiki**](../../wiki).

- Includes build dependencies, environment setup, and packaging steps.
- Ideal for advanced users who want to customize their own flavor of Monolith.

---

## 🧪 Example Usage

```bash
# List active firewall rules
monolithctl rules list

# Allow SSH traffic
monolithctl rules add allow tcp 22

# Block an IP
monolithctl rules add deny ip 192.168.1.100
