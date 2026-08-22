<div align="center">
  <img src="assets/logo.png" alt="SmartDev Installer Logo" width="180"/>
  <h1>SmartDev Installer</h1>
  <p><strong>A Modern Rufus-Style Automated Developer Environment Installer & Configurator for Windows</strong></p>

  <p>
    <a href="https://github.com/mauriciominas/SmartDev-Installer/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License: MIT"/></a>
    <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?style=for-the-badge&logo=windows" alt="Platform: Windows"/>
    <img src="https://img.shields.io/badge/Backend-Winget%20%2B%20Python%20%2B%20Batch-3776AB.svg?style=for-the-badge&logo=python" alt="Stack"/>
    <a href="https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52"><img src="https://img.shields.io/badge/Donate-PayPal-00457C.svg?style=for-the-badge&logo=paypal" alt="Donate PayPal"/></a>
  </p>

  <p>
    <b>🌐 Language:</b>
    <strong>English (Default)</strong> |
    <a href="pt_br/README.md">🇧🇷 Português do Brasil</a>
  </p>
</div>

---

## 🌟 Overview

**SmartDev Installer** is an automated, open-source tool designed to set up a complete, professional development environment on **Windows 10 and 11** in minutes. 

Powered by **Windows Package Manager (`winget`)**, **Python (CustomTkinter GUI)**, and **resilient Batch/PowerShell backends**, it provides a streamlined interface to install, configure system environment variables (`PATH`, `JAVA_HOME`, `ANDROID_HOME`), and update 16+ essential developer tools with a single click.

---

## 📦 Supported Tools (16 Packages)

All packages are organized into intuitive categories and installed using official, stable releases:

| Category | Tool | Package ID / Method | Description |
| :--- | :--- | :--- | :--- |
| **📦 Version Control** | **Git** | `Git.Git` | Industry standard distributed version control |
| | **GitHub Desktop** | `GitHub.GitHubDesktop` | Official GUI client for Git & GitHub repositories |
| **⚙️ Languages & Runtimes** | **Node.js** | `OpenJS.NodeJS` | JavaScript runtime built on Chrome's V8 engine |
| | **Python 3** | `Python.Python...` | Latest stable Python 3 release |
| | **Java Temurin** | `EclipseAdoptium.Temurin.21.JDK` | Enterprise OpenJDK 21 LTS (Android & Gradle compatible) |
| | **Deno** | `DenoLand.Deno` | Modern, secure runtime for JavaScript & TypeScript |
| **💻 Editors & IDEs** | **Visual Studio Code** | `Microsoft.VisualStudioCode` | Modern, extensible code editor |
| **📱 Mobile & Desktop** | **Flutter SDK** | `Flutter.Flutter` | Google's multi-platform UI toolkit |
| | **Android Studio** | `Google.AndroidStudio` | Official IDE for Android app development |
| | **Android SDK Min** | `Google.Android.CommandLineTools` | Lightweight Android command-line tools & sdkmanager |
| | **VS Build Tools** | `Microsoft.VisualStudio.2022.BuildTools` | C++ compilers & Windows SDKs for Flutter/native builds |
| **🌐 APIs & Databases** | **Postman** | `Postman.Postman` | Comprehensive API testing and development platform |
| | **DBeaver** | `DBeaver.DBeaver.Community` | Universal database management tool for SQL/NoSQL |
| | **Supabase CLI** | `Supabase.CLI` / `npm -g` | Local development toolkit for Supabase backend |
| **🐳 Containers & Testing** | **Docker CLI** | `Docker.DockerCLI` | Standalone Docker command-line client |
| | **Playwright CLI** | `@playwright/test` | Modern End-to-End (E2E) web testing framework |

---

## 🎯 Smart Installation Profiles (Presets)

* **Full (All Tools):** Complete workstation setup with all 16 tools configured.
* **Web & Fullstack Development:** Git, GitHub Desktop, Node.js, Python, Deno, VS Code, Postman, DBeaver, Supabase CLI, Docker CLI, and Playwright CLI.
* **Mobile Development (Flutter & Android):** Git, Java Temurin (LTS 21), Flutter SDK, Android Studio, Android SDK Min, VS Code, and Postman.
* **Backend, Cloud & Containers:** Git, Node.js, Python, Deno, VS Code, Postman, DBeaver, Supabase CLI, and Docker CLI.
* **Custom:** Freely select any combination of checkboxes.

---

## 🚀 Quick Start & Downloads

### 1. Ready Standalone Executable (.exe)
No dependencies or Python installation required on the target machine:
* 🌎 **[Download English Version (dist/SmartDevInstaller.exe)](en/dist/SmartDevInstaller.exe)**
* 🇧🇷 **[Download Brazilian Portuguese Version (pt_br/dist/SmartDevInstaller.exe)](pt_br/dist/SmartDevInstaller.exe)**

> **Note:** Run the executable as **Administrator (UAC)**. The application will request elevation automatically to configure system PATH and install packages.

### 2. Running from Source Code
```bash
# Clone the repository
git clone https://github.com/mauriciominas/SmartDev-Installer.git
cd SmartDev-Installer

# Install GUI dependency
pip install customtkinter

# Run English GUI
python en/gui_app.py

# Or run Brazilian Portuguese GUI
python pt_br/gui_app.py
```

### 3. Compiling Standalone Binaries
To build your own `.exe` bundles with PyInstaller:
```powershell
# In en/ or pt_br/ folder:
powershell -NoProfile -ExecutionPolicy Bypass -File build_exe.ps1
```

---

## 📋 System Requirements

* **Operating System:** Windows 10 (version 1709 or newer) or Windows 11.
* **PowerShell:** PowerShell 5.1+ (pre-installed natively on Windows 10/11).
* **Package Manager:** `winget` (pre-installed on modern Windows; update via Microsoft Store "App Installer" if needed).
* **Privileges:** Administrator Access (UAC).

---

## ⚠️ Disclaimer

1. **As-Is Warranty:** This software is provided "as is", without warranty of any kind. The author assumes no liability for system modifications, package repository outages, or software incompatibilities.
2. **Environment Changes:** The tool configures environment variables (`PATH`, `JAVA_HOME`, `ANDROID_HOME`). Creating a system restore point before large-scale setup is recommended.

---

## ☕ Support the Project (Donations)

If **SmartDev Installer** saved you hours of manual setup, please consider supporting ongoing maintenance and open-source development!

<div align="center">

### 🌐 PayPal (International)
[![Donate with PayPal](https://img.shields.io/badge/Donate-PayPal-00457C.svg?style=for-the-badge&logo=paypal)](https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52)

👉 **[Click here to donate via PayPal](https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52)**

<br/>

<img src="assets/paypal_qr.png" alt="PayPal QR Code" width="180"/>

---

### 🇧🇷 Pix (Brazil)

```text
00020126580014BR.GOV.BCB.PIX0136abdcd399-03eb-4203-8f9c-97dc96a5146d5204000053039865802BR5925Mauricio Antonio Oliveira6009SAO PAULO62140510MzCTa2ToEb63040C07
```

<br/>

<img src="assets/pix_qr.png" alt="Pix QR Code" width="180"/>

</div>

---

## 📄 License & Author

* **License:** [MIT License](LICENSE)
* **Author / Contact:** Mauricio Antonio Oliveira — 📧 **webforservices@gmail.com**
* **Repository:** [https://github.com/mauriciominas/SmartDev-Installer](https://github.com/mauriciominas/SmartDev-Installer)
