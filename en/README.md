<div align="center">
  <img src="assets/logo.png" alt="SmartDev Installer Logo" width="180"/>
  <h1>SmartDev Installer (English)</h1>
  <p><strong>Modern Rufus-style GUI wrapper to automate the installation and configuration of developer environment tools on Windows using Winget.</strong></p>
</div>

---

## 📦 Supported Tools

The installer organizes tools into convenient categories:

* **📦 Version Control:** Git, GitHub Desktop
* **⚙️ Languages & Runtimes:** Node.js, Python 3 (stable), Java Temurin (LTS 21), Deno Runtime
* **💻 Editors & IDEs:** Visual Studio Code
* **📱 Mobile & Desktop:** Flutter SDK, Android Studio, Android SDK Minimum (cmdline-tools), Visual Studio Build Tools
* **🌐 APIs & Databases:** Postman, DBeaver Community, Supabase CLI
* **🐳 Containers & Testing:** Docker CLI, Playwright CLI (E2E)

---

## ⚠️ DISCLAIMER

**PLEASE READ CAREFULLY BEFORE USING OR EXECUTING THIS SOFTWARE:**

1. **Use at Your Own Risk:** This software is provided "as is", without warranty of any kind, express or implied. The author assumes no liability for errors, omissions, or any system damage, data loss, or software instability caused by this program.
2. **System Modification:** This program performs system-level modifications, requests administrative elevation (UAC), and permanently changes crucial environment variables (such as `PATH`, `ANDROID_HOME`, and `JAVA_HOME`). We highly recommend creating a system restore point or backup before running.
3. **No Guarantee of Success:** Package installations depend on the public `winget` repository and your internet connection. Failures, network timeouts, or incompatibilities from third-party tools are not the responsibility of this project.

---

## 📋 System Requirements

To ensure the installer works correctly, your environment must meet the following prerequisites:

* **Operating System:** Windows 10 (version 1709 or newer) or Windows 11.
* **PowerShell:** PowerShell 5.1 or newer (pre-installed on Windows 10/11).
* **Package Manager:** `winget` installed (native on modern Windows 10/11; can be updated/installed from the Microsoft Store as "App Installer" if missing).
* **Permissions:** Administrator Access (the executable will prompt for UAC elevation automatically upon launching).

---

## 🚀 How to Use

### Using the Ready Executable
1. Download the pre-compiled `SmartDevInstaller.exe` from the [dist/](dist/) folder or the **Releases** tab of your repository.
2. Run the executable as **Administrator** (it will prompt for UAC elevation automatically).
3. Select your desired profile (Full, Web, Mobile, Backend) or select checkboxes customly.
4. Click **START** and follow logs in real-time.

### Running from Source Code
If you want to run or modify the project from the source:

1. Ensure you have Python 3 installed.
2. Install dependencies:
   ```bash
   pip install customtkinter
   ```
3. Run the application:
   ```bash
   python gui_app.py
   ```

### Compiling a New Executable
To bundle a new standalone `.exe` containing the internal batch script:
1. Open PowerShell inside the `en/` folder.
2. Execute the compilation script:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File build_exe.ps1
   ```
3. The compiled executable will be located in `dist/SmartDevInstaller.exe`.

---

## 📄 License

This project is licensed under the **MIT** License. See the [LICENSE](../LICENSE) file in the root directory for more details.

---

## ✉️ Contact

For questions, suggestions, or support, please reach out via:
📧 **webforservices@gmail.com**

---

## ☕ Support the Project (Donations)

If this project saved you time setting up your developer environment, please consider supporting ongoing development with a donation!

<div align="center">

### 🌐 PayPal (International)
[![Donate with PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg?style=for-the-badge&logo=paypal)](https://www.paypal.com/donate/?hosted_button_id=T3472SUH7RP52)

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
