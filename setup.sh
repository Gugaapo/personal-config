#!/usr/bin/env bash

set -e

echo "==> Starting personal config setup..."

# --------- VARIABLES ---------
SCRIPTS_DIR="$(pwd)/scripts"
TARGET_SCRIPTS_DIR="$HOME/scripts"
BASHRC="$HOME/.bashrc"
BASHRC_BACKUP="$HOME/.bashrc.backup.$(date +%s)"
OH_MY_BASH_DIR="$HOME/.oh-my-bash"
OH_MY_BASH_REPO="https://github.com/ohmybash/oh-my-bash.git"
THEME_NAME="binaryanomaly"

# --------- STEP 1: Install dependencies ---------
echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y ffmpeg git sshpass zoxide alacritty

# --------- STEP 2: Clone oh-my-bash ---------
if [ ! -d "$OH_MY_BASH_DIR" ]; then
  echo "==> Cloning oh-my-bash..."
  git clone --depth=1 "$OH_MY_BASH_REPO" "$OH_MY_BASH_DIR"
else
  echo "==> oh-my-bash already installed."
fi

# --------- STEP 3: Backup .bashrc ---------
echo "==> Backing up .bashrc to $BASHRC_BACKUP"
cp "$BASHRC" "$BASHRC_BACKUP"

# --------- STEP 4: Symlink scripts ---------
echo "==> Setting up script symlinks..."
mkdir -p "$TARGET_SCRIPTS_DIR"
for script in "$SCRIPTS_DIR"/*; do
  ln -sf "$script" "$TARGET_SCRIPTS_DIR/$(basename "$script")"
done

# --------- STEP 5: Configure .bashrc ---------
echo "==> Configuring .bashrc..."
cat << 'EOF' >> "$BASHRC"

# === BEGIN PERSONAL CONFIG ===
export OSH="$HOME/.oh-my-bash"
OSH_THEME="binaryanomaly"

# Extend PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin:/home/gustavoaugusto/Android/Sdk/build-tools/36.0.0:$HOME/.spicetify:$HOME/scripts"

# Load Oh My Bash
source "$OSH/oh-my-bash.sh"

# zoxide
eval "$(zoxide init --cmd cd bash)"

# Python Venvs
alias env_frame_drops="source \$HOME/venvs/jitter_venv/bin/activate"
alias env_cts_16="source \$HOME/venvs/cts_verifier_16/bin/activate"

# Device config
alias setup_its='source \$HOME/scripts/setup-its.sh'
alias setdump='cd \$HOME/scripts && ./dum-custom.sh'

# ITS help
alias how_its='<your long ITS command here>'

# Flash
alias flash_all='flash_0 && flash_1 && flash_2 && flash_3 && flash_4'
alias flash_0="sudo systemctl stop fwupd.service"
alias flash_1="adb reboot bootloader"
alias flash_2="./fastboot -w && fastboot erase cache"
alias flash_3="./flashall.sh -eu -nr"
alias flash_4="./fastboot flash boot boot-debug.img reboot"

# Bug collection
alias bugCollect='adb root; adb shell rm -rf /data/vendor/aplogd/*; adb shell screenrecord --bugreport /sdcard/screenrecord.mp4'
alias bugData='~/scripts/bugData/bugData.sh -d'

# SSH login
export SSHPASS="<super_secure_password>"
alias my_server_login='sshpass -e ssh gugaapo@10.181.194.246'

# Misc
alias cd..='cd ..'
alias cd.='cd -'
alias e='exit'
alias my_edit_alias='nano ~/.bashrc && my_update'
alias my_update='source ~/.bashrc'
alias my_alias='alias | grep "my_"'
alias my_quit='sudo shutdown -h -t 5'

# FPS from video
function grab_fps() {
  local video=\$1
  if [[ "\$video" == "" ]]; then
    echo "Usage: grab_fps <video>"
    exit 1
  else
    ffmpeg -i "\$video" 2>&1 | sed -n "s/.*, \(.* fps\).*/\1/p"
  fi
}

# Load dir history
[ -f "$HOME/.personal_config/scripts/.dir_history.sh" ] && source "$HOME/.personal_config/scripts/.dir_history.sh"
# === END PERSONAL CONFIG ===
EOF

# --------- STEP 6: Set Alacritty as default terminal ---------
echo "==> Setting Alacritty as default terminal..."
gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''

# --------- STEP 7: Run workspace shortcut setup ---------
echo "==> Running workspace shortcut setup..."
bash "$TARGET_SCRIPTS_DIR/setup-workspace-shortcuts.sh"

# --------- DONE ---------
echo "==> Setup complete. Run 'source ~/.bashrc' or restart your terminal."
