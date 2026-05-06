export GPG_DIR="$HOME/gpg"

rainbow_bar() {
    awk 'BEGIN{
        s="  ";
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm%s\033[0m", r,g,b,s;
        }
        printf "\n";
    }'
}

# Backup file or directory with date and versioning
backup() {
  local target="$1"
  if [[ -z "$target" ]]; then
    echo "Usage: backup <filename|directory>"
    return 1
  fi

  if [[ ! -e "$target" ]]; then
    echo "Error: $target is not a valid file or directory"
    return 1
  fi

  local date=$(date +%Y-%m-%d)
  local base_backup="${target}.${date}"
  local final_backup="${base_backup}.bak"

  if [[ -e "$final_backup" ]]; then
    local version=2
    while [[ -e "${base_backup}_v${version}.bak" ]]; do
      ((version++))
    done
    final_backup="${base_backup}_v${version}.bak"
  fi

  if [[ -d "$target" ]]; then
    cp -r "$target" "$final_backup"
    echo "Directory $target backed up as $final_backup"
  else
    cp "$target" "$final_backup"
    echo "File $target backed up as $final_backup"
  fi
}

m3u8() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: (ffmpeg)-m3u8 [m3u8 url] [output-name]"
    return 1
  fi
  ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i "${1}" -c copy $2
}

dlt() {
  local title="$1"
  local url="$2"
  if [[ -z "$title" || -z "$url" ]]; then
    echo "Usage: dlt \"Title\" \"URL\""
    return 1
  fi
  yt-dlp -o "${title}.%(ext)s" "${url}"
}

verify() {
    # 1. Check if GPG is installed
    if ! command -v gpg &> /dev/null; then
        echo "[ERROR] gpg command not found. Please install GnuPG."
        return 1
    fi

    # Zsh-specific option to prevent errors if no files are found
    [[ -n "$ZSH_VERSION" ]] && setopt localoptions nullglob

    if [[ ! -d "$GPG_DIR" ]]; then
        echo "[ERROR] Directory $GPG_DIR does not exist."
        return 1
    fi

    local current_dir=$(pwd)
    cd "$GPG_DIR" || return 1

    # Search for signature files (.asc and .sig)
    local sig_files=(*.asc *.sig)

    # Check if any signature files were found
    if [[ ${#sig_files[@]} -eq 0 || "${sig_files[0]}" == "*.asc" ]]; then
        echo "[ERROR] No signature files (.asc or .sig) found in directory."
        cd "$current_dir"
        return 1
    fi

    for sig in "${sig_files[@]}"; do
        # Assume the target file has the same name minus the extension
        local target_file="${sig%.*}"
        echo "----------------------------------------"
        echo "Target: $target_file"

        if [[ ! -f "$target_file" ]]; then
            echo "[SKIP] Original source file not found."
            continue
        fi

        # Extract the Key ID from the signature file
        local key_id=$(gpg --list-packets "$sig" 2>/dev/null | grep -i "keyid" | awk '{print $NF}' | head -n 1)

        if [[ -z "$key_id" ]]; then
            echo "[ERROR] Could not read Key ID from signature."
            continue
        fi

        # Attempt to fetch the key from public keyservers
        echo "Fetching Key: $key_id..."
        gpg --keyserver hkps://keys.openpgp.org --recv-keys "$key_id" >/dev/null 2>&1 || \
        gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key_id" >/dev/null 2>&1

        # Retrieve the owner's name for display
        local key_owner=$(gpg --list-keys "$key_id" 2>/dev/null | grep "uid" | sed 's/uid *\[.*\] *//' | head -n 1)
        [[ -z "$key_owner" ]] && key_owner="Unknown"

        # Perform the actual verification
        local verify_output=$(gpg --verify "$sig" 2>&1)

        if echo "$verify_output" | grep -q "Good signature"; then
            echo "[SAFE] Signature is valid."
            echo "Signed by: $key_owner"
        else
            echo "[DANGER] Invalid signature! Do not use this file."
        fi
    done
    echo "----------------------------------------"

    cd "$current_dir"
}
