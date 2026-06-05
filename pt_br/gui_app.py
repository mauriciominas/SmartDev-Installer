import os
import sys
import subprocess
import threading
import re
import tkinter as tk
from tkinter import messagebox

# Auto-install customtkinter if missing
try:
    import customtkinter as ctk
except ImportError:
    print("customtkinter não encontrado. Tentando instalar via pip...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "customtkinter"])
        import customtkinter as ctk
    except Exception as e:
        messagebox.showerror(
            "Erro de Dependência",
            f"Não foi possível instalar 'customtkinter' automaticamente.\nExecute: pip install customtkinter\n\nErro: {e}"
        )
        sys.exit(1)

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class SmartDevInstallerGUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("SmartDev Installer")
        self.geometry("940x600")
        self.resizable(False, False)

        # Determine paths
        if getattr(sys, 'frozen', False):
            # Running in PyInstaller bundle
            self.script_dir = sys._MEIPASS
            self.exe_dir = os.path.dirname(sys.executable)
        else:
            # Running in standard python interpreter
            self.script_dir = os.path.dirname(os.path.abspath(__file__))
            self.exe_dir = self.script_dir

        self.bat_path = os.path.join(self.script_dir, "smartdev_installer.bat")

        # UI Variables
        self.profile_var = ctk.StringVar(value="Completo (Tudo)")

        # Checkbox variables dict
        self.components = {
            "g": ("Git", ctk.BooleanVar(value=True)),
            "n": ("Node.js", ctk.BooleanVar(value=True)),
            "p": ("Python 3", ctk.BooleanVar(value=True)),
            "j": ("Java Temurin", ctk.BooleanVar(value=True)),
            "a": ("Android Studio", ctk.BooleanVar(value=True)),
            "m": ("Android SDK Minimo", ctk.BooleanVar(value=True)),
            "v": ("Visual Studio Build Tools", ctk.BooleanVar(value=True)),
            "f": ("Flutter", ctk.BooleanVar(value=True)),
            "s": ("Supabase CLI", ctk.BooleanVar(value=True)),
        }

        self.is_running = False
        self.build_ui()

    def build_ui(self):
        # Main split container
        main_container = ctk.CTkFrame(self, fg_color="transparent")
        main_container.pack(fill="both", expand=True, padx=15, pady=15)

        # Left Panel (Controls)
        left_panel = ctk.CTkFrame(main_container, fg_color="transparent", width=360)
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
            text="Configurador de Ambiente de Desenvolvimento", 
            font=ctk.CTkFont(family="Segoe UI", size=11),
            text_color="#888888"
        )
        subtitle_lbl.pack(pady=(0, 8))

        # 2. Bottom Execution Frame (pinned to bottom of Left Panel)
        bottom_frame = ctk.CTkFrame(left_panel, fg_color="transparent")
        bottom_frame.pack(fill="x", side="bottom", padx=0, pady=(10, 0))

        # Status and Progress
        self.status_lbl = ctk.CTkLabel(bottom_frame, text="Pronto para iniciar.", font=ctk.CTkFont(size=12))
        self.status_lbl.pack(anchor="w", padx=5, pady=(5, 2))

        self.progress_bar = ctk.CTkProgressBar(bottom_frame)
        self.progress_bar.pack(fill="x", padx=5, pady=(0, 10))
        self.progress_bar.set(0)

        # Action Buttons Frame
        btn_frame = ctk.CTkFrame(bottom_frame, fg_color="transparent")
        btn_frame.pack(fill="x", padx=5, pady=(0, 5))

        self.start_btn = ctk.CTkButton(
            btn_frame, 
            text="INICIAR", 
            font=ctk.CTkFont(weight="bold"),
            fg_color="#3a86ff",
            hover_color="#0056b3",
            command=self.start_installation
        )
        self.start_btn.pack(side="left", expand=True, fill="x", padx=(0, 5))

        self.open_logs_btn = ctk.CTkButton(
            btn_frame, 
            text="VER LOGS", 
            width=80,
            fg_color="#333333",
            hover_color="#555555",
            command=self.open_logs_dir
        )
        self.open_logs_btn.pack(side="left", padx=5)

        self.close_btn = ctk.CTkButton(
            btn_frame, 
            text="FECHAR", 
            width=80,
            fg_color="#c1121f",
            hover_color="#780000",
            command=self.destroy
        )
        self.close_btn.pack(side="left", padx=(5, 0))

        # 3. Main Scrollable Frame for settings (between Header and Pinned Bottom Controls)
        prop_frame = ctk.CTkScrollableFrame(left_panel, fg_color="transparent")
        prop_frame.pack(fill="both", expand=True, padx=0, pady=0)

        # Profile Selector
        profile_lbl = ctk.CTkLabel(prop_frame, text="Perfil de Instalação (Preset):", font=ctk.CTkFont(weight="bold"))
        profile_lbl.pack(anchor="w", pady=(5, 2))

        self.profile_combo = ctk.CTkComboBox(
            prop_frame, 
            values=["Completo (Tudo)", "Desenvolvimento Web", "Desenvolvimento Mobile (Flutter)", "Personalizado"],
            variable=self.profile_var,
            command=self.on_profile_change,
            state="readonly"
        )
        self.profile_combo.pack(fill="x", pady=(0, 12))

        # Checkboxes Frame
        comp_frame = ctk.CTkFrame(prop_frame)
        comp_frame.pack(fill="x", pady=5)

        comp_title = ctk.CTkLabel(comp_frame, text="Componentes Disponíveis:", font=ctk.CTkFont(weight="bold"))
        comp_title.pack(anchor="w", padx=10, pady=5)

        self.chk_buttons = {}
        for key, (name, var) in self.components.items():
            chk = ctk.CTkCheckBox(
                comp_frame, 
                text=name, 
                variable=var,
                command=self.on_checkbox_change
            )
            chk.pack(anchor="w", padx=20, pady=4)
            self.chk_buttons[key] = chk



        # 4. Right Panel: Logs
        log_header = ctk.CTkFrame(right_panel, fg_color="transparent")
        log_header.pack(fill="x", padx=15, pady=(15, 8))

        log_title = ctk.CTkLabel(
            log_header, 
            text="Terminal de Logs de Execução", 
            font=ctk.CTkFont(family="Segoe UI", size=14, weight="bold"),
            text_color="#3a86ff"
        )
        log_title.pack(side="left")

        self.copy_btn = ctk.CTkButton(
            log_header,
            text="Copiar Logs",
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

    def on_profile_change(self, value):
        if value == "Completo (Tudo)":
            for key, (_, var) in self.components.items():
                var.set(True)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Desenvolvimento Web":
            web_keys = {"g", "n", "p", "s"}
            for key, (_, var) in self.components.items():
                var.set(key in web_keys)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Desenvolvimento Mobile (Flutter)":
            mobile_keys = {"g", "j", "a", "m", "f"}
            for key, (_, var) in self.components.items():
                var.set(key in mobile_keys)
                self.chk_buttons[key].configure(state="normal")
        elif value == "Personalizado":
            pass

    def on_checkbox_change(self):
        # Set combobox value to Custom if user checks manually
        self.profile_var.set("Personalizado")

    def log(self, message):
        self.log_textbox.configure(state="normal")
        self.log_textbox.insert("end", message + "\n")
        self.log_textbox.see("end")
        self.log_textbox.configure(state="disabled")

    def clear_log(self):
        self.log_textbox.configure(state="normal")
        self.log_textbox.delete("1.0", "end")
        self.log_textbox.configure(state="disabled")

    def open_logs_dir(self):
        if os.path.exists(self.exe_dir):
            os.startfile(self.exe_dir)

    def copy_log_to_clipboard(self):
        log_text = self.log_textbox.get("1.0", "end-1c")
        if log_text.strip():
            self.clipboard_clear()
            self.clipboard_append(log_text)
            self.update_idletasks()
            self.copy_btn.configure(text="Copiado!", fg_color="#2a9d8f")
            self.after(1500, lambda: self.copy_btn.configure(text="Copiar Logs", fg_color="#333333"))
        else:
            messagebox.showinfo("Aviso", "O terminal de logs está vazio.")

    def start_installation(self):
        if self.is_running:
            return

        if not os.path.exists(self.bat_path):
            messagebox.showerror("Erro", f"Arquivo backend não encontrado:\n{self.bat_path}")
            return

        # Prepare choices string
        choices = ""
        for key, (_, var) in self.components.items():
            if var.get():
                choices += key

        if not choices:
            messagebox.showwarning("Aviso", "Por favor, selecione pelo menos um componente para instalar.")
            return

        # Warn user if large packages are selected
        warn_pkgs = []
        if self.components["a"][1].get():
            warn_pkgs.append("Android Studio")
        if self.components["v"][1].get():
            warn_pkgs.append("Visual Studio Build Tools")
            
        if warn_pkgs:
            msg = f"Atenção: Você selecionou a instalação do {' e '.join(warn_pkgs)}.\n\n" \
                  "Este processo de instalação é grande e pode demorar vários minutos para ser concluído.\n\n" \
                  "Deseja prosseguir?"
            if not messagebox.askyesno("Aviso de Tempo de Instalação", msg):
                return

        self.is_running = True
        self.start_btn.configure(state="disabled")
        self.profile_combo.configure(state="disabled")
        for chk in self.chk_buttons.values():
            chk.configure(state="disabled")

        self.clear_log()
        self.progress_bar.set(0)
        self.status_lbl.configure(text="Iniciando instalação...")

        # Run process in background thread
        thread = threading.Thread(target=self.run_bat, args=(choices,))
        thread.daemon = True
        thread.start()

    def run_bat(self, choices):
        # Setup environment variables
        env = os.environ.copy()
        env["ESCOLHAS"] = choices
        env["GUI_MODE"] = "1"
        env["LOG_DIR"] = self.exe_dir + os.sep

        try:
            # Execute batch file (read stdout as binary)
            process = subprocess.Popen(
                ["cmd.exe", "/c", self.bat_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env=env,
                creationflags=subprocess.CREATE_NO_WINDOW
            )

            # Parse console output in real-time
            step_regex = re.compile(r'\[(\d+)/(\d+)\]')
            while True:
                line_bytes = process.stdout.readline()
                if not line_bytes and process.poll() is not None:
                    break
                
                # Safely decode the line
                try:
                    line_str = line_bytes.decode("utf-8")
                except UnicodeDecodeError:
                    try:
                        line_str = line_bytes.decode("cp1252", errors="replace")
                    except Exception:
                        line_str = line_bytes.decode("utf-8", errors="replace")

                line_str = line_str.strip()
                if line_str:
                    self.log(line_str)
                    
                    # Update status
                    if "Verificando" in line_str or "Instalando" in line_str or "Atualizando" in line_str:
                        self.status_lbl.configure(text=line_str)

                    # Update progress bar
                    step_match = step_regex.search(line_str)
                    if step_match:
                        current = int(step_match.group(1))
                        total = int(step_match.group(2))
                        progress = current / total
                        self.progress_bar.set(progress)

            # Completed
            returncode = process.returncode
            if returncode == 0:
                self.progress_bar.set(1.0)
                self.status_lbl.configure(text="Processo concluído com sucesso!")
                self.log("\n============================================\n[CONCLUÍDO] Todos os passos executados.\n============================================")
            else:
                self.status_lbl.configure(text=f"Processo finalizado com código de saída {returncode}")
                self.log(f"\n[ERRO] O processo retornou código {returncode}.")

        except Exception as e:
            self.log(f"\n[CRITICAL ERROR] Falha ao rodar o script: {e}")
            self.status_lbl.configure(text="Erro crítico durante a execução.")

        # Re-enable UI
        self.is_running = False
        self.start_btn.configure(state="normal")
        self.profile_combo.configure(state="readonly")
        
        # Reset checkbox states depending on profile combobox value
        self.on_profile_change(self.profile_var.get())

if __name__ == "__main__":
    app = SmartDevInstallerGUI()
    app.mainloop()
