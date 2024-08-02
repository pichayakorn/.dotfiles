# Function to get the Python version from the active Conda environment
function get_conda_python_version() {
  if [[ -n ${CONDA_DEFAULT_ENV} ]]; then
    conda run -n ${CONDA_DEFAULT_ENV} python --version 2>&1 | awk '{print $2}'
  else
    python --version 2>&1 | awk '{print $2}'
  fi
}

# Define Zsh prompt components
ZSH_THEME_CONDA_PREFIX='%F{cyan}‹'
ZSH_THEME_CONDA_SUFFIX='›%f'

# Function to display Conda environment and Python version
function conda_prompt_info() {
  [[ -n ${CONDA_DEFAULT_ENV} ]] || return
  local python_version=$(get_conda_python_version)
  echo "${ZSH_THEME_CONDA_PREFIX} ${CONDA_DEFAULT_ENV:t:gs/%/%%} ${python_version}${ZSH_THEME_CONDA_SUFFIX}"
}

# Disable Conda prompt change
export CONDA_CHANGEPS1=false
