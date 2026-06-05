# SmartDev Installer (English)

Modern Rufus-style GUI wrapper to automate the installation and configuration of developer environment tools on Windows using Winget.

---

## ⚠️ DISCLAIMER

**PLEASE READ CAREFULLY BEFORE USING OR EXECUTING THIS SOFTWARE:**

1. **Use at Your Own Risk:** This software is provided "as is", without warranty of any kind, express or implied. The author assumes no liability for errors, omissions, or any system damage, data loss, or software instability caused by this program.
2. **System Modification:** This program performs system-level modifications, requests administrative elevation (UAC), and permanently changes crucial environment variables (such as `PATH`, `ANDROID_HOME`, and `JAVA_HOME`). We highly recommend creating a system restore point or backup before running.
3. **No Guarantee of Success:** Package installations depend on the public `winget` repository and your internet connection. Failures, network timeouts, or incompatibilities from third-party tools are not the responsibility of this project.

---

## 🚀 How to Use

### Using the Ready Executable
1. Download the pre-compiled `SmartDevInstaller.exe` from the [dist/](dist/) folder or the **Releases** tab of your repository.
2. Run the executable as **Administrator** (it will prompt for UAC elevation automatically).
3. Select your desired profile (Full, Web, Mobile) or select checkboxes customly.
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
3. The compiled executable will be located in `en/dist/SmartDevInstaller.exe`.

---

## 📄 License

This project is licensed under the **MIT** License. See the [LICENSE](../LICENSE) file in the root directory for more details.

---

## ✉️ Contact

For questions, suggestions, or support, please reach out via:
📧 **webforservices@gmail.com**
