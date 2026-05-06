export GPG_DIR='/Volumes/MacX/hachi/gpg'

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
