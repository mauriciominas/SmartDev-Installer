import os
import sys
import subprocess
import threading
import queue
import re
import ctypes
import tkinter as tk
from tkinter import messagebox

# Verify customtkinter
try:
    import customtkinter as ctk
except ImportError:
    if getattr(sys, 'frozen', False):
        messagebox.showerror(
            "Initialization Error",
            "The required UI library was not found in the executable package."
        )
    else:
        root = tk.Tk()
        root.withdraw()
        messagebox.showerror(
            "Missing Dependency",
            "The 'customtkinter' library is not installed in your Python environment.\n\n"
            "To install it, run in your terminal:\n"
            "pip install customtkinter"
        )
    sys.exit(1)

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except Exception:
        return False

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class SmartDevInstallerGUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("SmartDev Installer")
        self.geometry("1000x680")
        self.minsize(960, 620)
        self.resizable(True, True)

        # Determine paths
        if getattr(sys, 'frozen', False):
            self.script_dir = sys._MEIPASS
            self.exe_dir = os.path.dirname(sys.executable)
        else:
            self.script_dir = os.path.dirname(os.path.abspath(__file__))
            self.exe_dir = self.script_dir

        self.bat_path = os.path.join(self.script_dir, "smartdev_installer.bat")

        # UI Variables
        self.profile_var = ctk.StringVar(value="Full (All)")

        # Categorized components dictionary: category -> list of (key, display_name, default_val)
        self.categories = {
            "📦 Version Control": [
                ("g", "Git", True),
                ("h", "GitHub Desktop", True),
            ],
            "⚙️ Languages & Runtimes": [
                ("n", "Node.js", True),
                ("p", "Python 3", True),
                ("j", "Java Temurin (LTS 21)", True),
                ("e", "Deno Runtime", True),
            ],
            "💻 Editors & IDEs": [
                ("c", "Visual Studio Code", True),
            ],
            "📱 Mobile & Desktop": [
                ("f", "Flutter SDK", True),
                ("a", "Android Studio", True),
                ("m", "Android SDK Minimum (cmdline-tools)", True),
                ("v", "Visual Studio Build Tools", True),
            ],
            "🌐 APIs & Databases": [
                ("t", "Postman", True),
                ("b", "DBeaver Community", True),
                ("s", "Supabase CLI", True),
            ],
            "🐳 Containers & Testing": [
                ("d", "Docker CLI", True),
                ("w", "Playwright CLI (E2E)", True),
            ],
        }

        # Flat components lookup: key -> (name, BooleanVar)
        self.components = {}
        for cat_name, items in self.categories.items():
            for key, name, default_val in items:
                self.components[key] = (name, ctk.BooleanVar(value=default_val))

        self.is_running = False
        self.current_process = None
        self.msg_queue = queue.Queue()
        self.copy_timer = None

        self.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.build_ui()
        self.check_admin_privileges()
        self.after(50, self._process_queue)

    def build_ui(self):
        # Main split container
        main_container = ctk.CTkFrame(self, fg_color="transparent")
        main_container.pack(fill="both", expand=True, padx=15, pady=15)

        # Left Panel (Controls & Options)
        left_panel = ctk.CTkFrame(main_container, fg_color="transparent", width=430)
        left_panel.pack(side="left", fill="both", expand=False, padx=(0, 10))
        left_panel.pack_propagate(False)

        # Right Panel (Logs)
        right_panel = ctk.CTkFrame(main_container, fg_color="#181818", corner_radius=8, border_width=1, border_color="#2c2c2c")
        right_panel.pack(side="right", fill="both", expand=True, padx=(10, 0))

        # 1. Header Frame (inside Left Panel)
        header_frame = ctk.CTkFrame(left_panel, corner_radius=8, fg_color="#1a1a1a")
        header_frame.pack(fill="x", padx=0, pady=(0, 10))

        title_lbl = ctk.CTkLabel(
            header_frame, 
            text="SmartDev Installer", 
            font=ctk.CTkFont(family="Segoe UI", size=20, weight="bold"),
            text_color="#3a86ff"
        )
        title_lbl.pack(pady=(8, 2))

        subtitle_lbl = ctk.CTkLabel(
            header_frame, 
            text="Developer Environment Configurator", 
            font=ctk.CTkFont(family="Segoe UI", size=11),
            text_color="#888888"
        )
        subtitle_lbl.pack(pady=(0, 8))

        # 2. Bottom Execution Frame (pinned to bottom of Left Panel)
        bottom_frame = ctk.CTkFrame(left_panel, fg_color="transparent")
        bottom_frame.pack(fill="x", side="bottom", padx=0, pady=(10, 0))

        # Status and Progress
        self.status_lbl = ctk.CTkLabel(bottom_frame, text="Ready to start.", font=ctk.CTkFont(size=12))
        self.status_lbl.pack(anchor="w", padx=5, pady=(5, 2))

        self.progress_bar = ctk.CTkProgressBar(bottom_frame)
        self.progress_bar.pack(fill="x", padx=5, pady=(0, 10))
        self.progress_bar.set(0)

        # Action Buttons Frame
        btn_frame = ctk.CTkFrame(bottom_frame, fg_color="transparent")
        btn_frame.pack(fill="x", padx=5, pady=(0, 5))

        self.start_btn = ctk.CTkButton(
            btn_frame, 
            text="START", 
            font=ctk.CTkFont(weight="bold"),
            fg_color="#3a86ff",
            hover_color="#0056b3",
            command=self.start_installation
        )
        self.start_btn.pack(side="left", expand=True, fill="x", padx=(0, 5))

        self.open_logs_btn = ctk.CTkButton(
            btn_frame, 
            text="VIEW LOGS", 
            width=80,
            fg_color="#333333",
            hover_color="#555555",
            command=self.open_logs_dir
        )
        self.open_logs_btn.pack(side="left", padx=5)

        self.close_btn = ctk.CTkButton(
            btn_frame, 
            text="CLOSE", 
            width=80,
            fg_color="#c1121f",
            hover_color="#780000",
            command=self.on_closing
        )
        self.close_btn.pack(side="left", padx=(5, 0))

        # 3. Main Scrollable Frame for settings
        prop_frame = ctk.CTkScrollableFrame(left_panel, fg_color="transparent")
        prop_frame.pack(fill="both", expand=True, padx=0, pady=0)

        # Profile Selector
        profile_lbl = ctk.CTkLabel(prop_frame, text="Installation Profile (Preset):", font=ctk.CTkFont(weight="bold"))
        profile_lbl.pack(anchor="w", pady=(5, 2))

        self.profile_combo = ctk.CTkComboBox(
            prop_frame, 
            values=[
                "Full (All)",
                "Web & Fullstack Development",
                "Mobile Development (Flutter & Android)",
                "Backend, Cloud & Containers",
                "Custom"
            ],
            variable=self.profile_var,
            command=self.on_profile_change,
            state="readonly"
        )
        self.profile_combo.pack(fill="x", pady=(0, 10))

        # Categorized Checkbox Frames
        self.chk_buttons = {}
        for cat_name, items in self.categories.items():
            cat_frame = ctk.CTkFrame(prop_frame, fg_color="#202020", corner_radius=6)
            cat_frame.pack(fill="x", pady=4, padx=2)

            cat_title = ctk.CTkLabel(
                cat_frame, 
                text=cat_name, 
                font=ctk.CTkFont(size=12, weight="bold"),
                text_color="#4cc9f0"
            )
            cat_title.pack(anchor="w", padx=10, pady=(6, 4))

            for key, name, _ in items:
                chk = ctk.CTkCheckBox(
                    cat_frame, 
                    text=name, 
                    variable=self.components[key][1],
                    command=self.on_checkbox_change
                )
                chk.pack(anchor="w", padx=16, pady=3)
                self.chk_buttons[key] = chk

        # 4. Right Panel: Logs
        log_header = ctk.CTkFrame(right_panel, fg_color="transparent")
        log_header.pack(fill="x", padx=15, pady=(15, 8))

        log_title = ctk.CTkLabel(
            log_header, 
            text="Execution Log Terminal", 
            font=ctk.CTkFont(family="Segoe UI", size=14, weight="bold"),
            text_color="#3a86ff"
        )
        log_title.pack(side="left")

        self.copy_btn = ctk.CTkButton(
            log_header,
            text="Copy Logs",
            width=90,
            height=24,
            font=ctk.CTkFont(family="Segoe UI", size=11),
            fg_color="#333333",
            hover_color="#555555",
            command=self.copy_log_to_clipboard
        )
        self.copy_btn.pack(side="right")

        self.log_textbox = ctk.CTkTextbox(
            right_panel, 
            font=ctk.CTkFont(family="Consolas", size=11),
            fg_color="#0e0e0e",
            border_width=1,
            border_color="#2c2c2c"
        )
        self.log_textbox.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_textbox.configure(state="disabled")

    def check_admin_privileges(self):
        if not is_admin():
            self.status_lbl.configure(text="Warning: Running without Admin privileges.")
            self._append_log("[WARNING] To install or update developer tools on Windows, run this program as Administrator (UAC).\n")

    def _process_queue(self):
        try:
            while not self.msg_queue.empty():
                msg_type, payload = self.msg_queue.get_nowait()
                if msg_type == "log":
                    self._append_log(payload)
                elif msg_type == "status":
                    self.status_lbl.configure(text=payload)
                elif msg_type == "progress":
                    self.progress_bar.set(payload)
                elif msg_type == "done":
                    self._handle_done(payload)
                elif msg_type == "error":
                    self._append_log(f"\n[CRITICAL ERROR] {payload}")
                    self.status_lbl.configure(text="Critical error during execution.")
                    self._handle_done(1)
        except Exception as e:
            print(f"Queue error: {e}")
        finally:
            self.after(50, self._process_queue)

    def _append_log(self, message):
        self.log_textbox.configure(state="normal")
        self.log_textbox.insert("end", message + "\n")
        self.log_textbox.see("end")
        self.log_textbox.configure(state="disabled")

    def _handle_done(self, returncode):
        self.is_running = False
        self.current_process = None
        if returncode == 0:
            self.progress_bar.set(1.0)
            self.status_lbl.configure(text="Process completed successfully!")
            self._append_log("\n============================================\n[COMPLETED] All steps executed.\n============================================")
        else:
            self.status_lbl.configure(text=f"Process finished with code {returncode}")
            self._append_log(f"\n[ERROR] The process returned code {returncode}.")

        self.start_btn.configure(state="normal")
        self.profile_combo.configure(state="readonly")
        self.on_profile_change(self.profile_var.get())

    def on_profile_change(self, value):
        if value == "Full (All)":
            for key, (_, var) in self.components.items():
                var.set(True)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Web & Fullstack Development":
            web_keys = {"g", "h", "n", "p", "e", "c", "t", "b", "s", "d", "w"}
            for key, (_, var) in self.components.items():
                var.set(key in web_keys)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Mobile Development (Flutter & Android)":
            mobile_keys = {"g", "j", "f", "a", "m", "c", "t"}
            for key, (_, var) in self.components.items():
                var.set(key in mobile_keys)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Backend, Cloud & Containers":
            backend_keys = {"g", "n", "p", "e", "c", "t", "b", "s", "d"}
            for key, (_, var) in self.components.items():
                var.set(key in backend_keys)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Custom":
            pass

    def on_checkbox_change(self):
        self.profile_var.set("Custom")

    def clear_log(self):
        self.log_textbox.configure(state="normal")
        self.log_textbox.delete("1.0", "end")
        self.log_textbox.configure(state="disabled")

    def open_logs_dir(self):
        if os.path.exists(self.exe_dir):
            try:
                os.startfile(self.exe_dir)
            except Exception as e:
                messagebox.showerror("Error", f"Could not open directory:\n{e}")

    def copy_log_to_clipboard(self):
        log_text = self.log_textbox.get("1.0", "end-1c")
        if log_text.strip():
            self.clipboard_clear()
            self.clipboard_append(log_text)
            self.update_idletasks()
            self.copy_btn.configure(text="Copied!", fg_color="#2a9d8f")
            if self.copy_timer:
                try:
                    self.after_cancel(self.copy_timer)
                except Exception:
                    pass
            self.copy_timer = self.after(1500, self._reset_copy_btn)
        else:
            messagebox.showinfo("Notice", "The log terminal is empty.")

    def _reset_copy_btn(self):
        try:
            self.copy_btn.configure(text="Copy Logs", fg_color="#333333")
        except Exception:
            pass
        self.copy_timer = None

    def on_closing(self):
        if self.is_running:
            if messagebox.askyesno(
                "Installation in Progress",
                "An installation is currently running.\n\n"
                "Do you really want to cancel the process and close the application?"
            ):
                if self.current_process:
                    try:
                        self.current_process.terminate()
                    except Exception:
                        pass
                if self.copy_timer:
                    try:
                        self.after_cancel(self.copy_timer)
                    except Exception:
                        pass
                self.destroy()
        else:
            if self.copy_timer:
                try:
                    self.after_cancel(self.copy_timer)
                except Exception:
                    pass
            self.destroy()

    def start_installation(self):
        if self.is_running:
            return

        if not os.path.exists(self.bat_path):
            messagebox.showerror("Error", f"Backend file not found:\n{self.bat_path}")
            return

        # Prepare choices string
        choices = ""
        for key, (_, var) in self.components.items():
            if var.get():
                choices += key

        if not choices:
            messagebox.showwarning("Warning", "Please select at least one component to install.")
            return

        # Warn user if large packages are selected
        warn_pkgs = []
        if self.components["a"][1].get():
            warn_pkgs.append("Android Studio")
        if self.components["v"][1].get():
            warn_pkgs.append("Visual Studio Build Tools")
            
        if warn_pkgs:
            msg = f"Warning: You selected the installation of {' and '.join(warn_pkgs)}.\n\n" \
                  "This installation process is large and may take several minutes to complete.\n\n" \
                  "Do you wish to proceed?"
            if not messagebox.askyesno("Installation Time Warning", msg):
                return

        self.is_running = True
        self.start_btn.configure(state="disabled")
        self.profile_combo.configure(state="disabled")
        for chk in self.chk_buttons.values():
            chk.configure(state="disabled")

        self.clear_log()
        self.progress_bar.set(0)
        self.status_lbl.configure(text="Starting installation...")

        # Total steps: 2 initial (sources + appinstaller) + selected components + 2 (ConfigurePaths + Summary)
        total_steps = 2 + len(choices) + 2

        # Run process in background thread
        thread = threading.Thread(target=self.run_bat, args=(choices, total_steps))
        thread.daemon = True
        thread.start()

    def run_bat(self, choices, total_steps):
        env = os.environ.copy()
        env["ESCOLHAS"] = choices
        env["GUI_MODE"] = "1"
        env["LOG_DIR"] = self.exe_dir + os.sep
        env["TOTAL_STEPS"] = str(total_steps)

        try:
            self.current_process = subprocess.Popen(
                ["cmd.exe", "/c", self.bat_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env=env,
                creationflags=subprocess.CREATE_NO_WINDOW
            )

            step_regex = re.compile(r'\[(\d+)/(\d+)\]')
            while True:
                line_bytes = self.current_process.stdout.readline()
                if not line_bytes and self.current_process.poll() is not None:
                    break
                
                try:
                    line_str = line_bytes.decode("utf-8")
                except UnicodeDecodeError:
                    try:
                        line_str = line_bytes.decode("cp1252", errors="replace")
                    except Exception:
                        line_str = line_bytes.decode("utf-8", errors="replace")

                line_str = line_str.strip()
                if line_str:
                    self.msg_queue.put(("log", line_str))
                    
                    if any(k in line_str for k in ["Checking", "Installing", "Updating", "Processing", "Configuring", "Generating", "Searching"]):
                        self.msg_queue.put(("status", line_str))

                    step_match = step_regex.search(line_str)
                    if step_match:
                        current = int(step_match.group(1))
                        total = int(step_match.group(2))
                        if total > 0:
                            self.msg_queue.put(("progress", current / total))

            returncode = self.current_process.returncode if self.current_process else 0
            self.msg_queue.put(("done", returncode))

        except Exception as e:
            self.msg_queue.put(("error", str(e)))

if __name__ == "__main__":
    app = SmartDevInstallerGUI()
    app.mainloop()
