#!/bin/bash
# ---------------------------------------------------------
# Author: Vamshi Namala
# Script: create_users.sh
# Description:
#   Reads a text file containing usernames and groups (user;groups)
#   Creates users, personal groups, assigns secondary groups,
#   generates random passwords, logs all actions, and stores
#   passwords securely.
#
# Usage:
#   sudo bash create_users.sh employees.txt
# ---------------------------------------------------------

# Exit if any command fails
set -e

# --- Variables ---
LOG_FILE="/var/log/user_management.log"
SECURE_DIR="/var/secure"
PASSWORD_FILE="$SECURE_DIR/user_passwords.csv"

# --- Check root privileges ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root." >&2
  exit 1
fi

# --- Validate input file ---
INPUT_FILE="$1"
if [[ -z "$INPUT_FILE" ]]; then
  echo "Usage: sudo bash $0 <input_file>"
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "❌ Input file not found: $INPUT_FILE"
  exit 1
fi

# --- Prepare secure directories ---
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$SECURE_DIR"

touch "$LOG_FILE"
touch "$PASSWORD_FILE"

chmod 600 "$PASSWORD_FILE"
chmod 644 "$LOG_FILE"

echo "========== $(date) ==========" >> "$LOG_FILE"

# --- Main Logic ---
while IFS=';' read -r username groups; do
  # Remove whitespace
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs | tr -d ' ')

  # Skip empty lines
  [[ -z "$username" ]] && continue

  echo "Processing user: $username" | tee -a "$LOG_FILE"

  # --- Create personal group ---
  if ! getent group "$username" >/dev/null; then
    groupadd "$username"
    echo "Created group: $username" >> "$LOG_FILE"
  else
    echo "Group $username already exists" >> "$LOG_FILE"
  fi

  # --- Create user ---
  if id "$username" &>/dev/null; then
    echo "⚠️ User $username already exists. Skipping creation." | tee -a "$LOG_FILE"
  else
    useradd -m -g "$username" -s /bin/bash "$username"
    echo "User $username created with home directory /home/$username" >> "$LOG_FILE"
  fi

  # --- Handle secondary groups ---
  IFS=',' read -ra group_list <<< "$groups"
  for grp in "${group_list[@]}"; do
    grp=$(echo "$grp" | xargs)
    [[ -z "$grp" ]] && continue

    if ! getent group "$grp" >/dev/null; then
      groupadd "$grp"
      echo "Created additional group: $grp" >> "$LOG_FILE"
    fi

    usermod -aG "$grp" "$username"
    echo "Added $username to group: $grp" >> "$LOG_FILE"
  done

  # --- Generate random password ---
  password=$(openssl rand -base64 12)

  echo "$username,$password" >> "$PASSWORD_FILE"
  echo "$username: password generated and saved." >> "$LOG_FILE"

  # --- Set password ---
  echo "$username:$password" | chpasswd

  # --- Secure permissions ---
  chown "$username:$username" "/home/$username"
  chmod 700 "/home/$username"

done < "$INPUT_FILE"

echo "✅ User creation process completed successfully!" | tee -a "$LOG_FILE"