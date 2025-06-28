# Only show Node version if in a Node project directory
function node_prompt_info() {
  # Check for Node project indicators in current or parent directories
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" || -d "$dir/node_modules" ]]; then
      if command -v nodenv &>/dev/null; then
        local node_version=$(nodenv version-name 2>/dev/null)
        echo "%F{green}‹⬢ $node_version›%f "
      elif command -v node &>/dev/null; then
        local node_version=$(node --version 2>/dev/null | sed 's/^v//')
        echo "%F{green}‹⬢ $node_version›%f "
      fi
      return
    fi
    dir=$(dirname "$dir")
  done
}
