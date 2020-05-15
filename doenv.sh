# The main function reads the password from a named pipe so it can be invoked
# from sh-incompatible shells like Fish without leaking the password to
# /proc/<pid>/environ or /proc/<pid>/cmdline.
function __doenv_main {
  local password
  read -r password <"$1"
  shift

  if [[ $# -lt 2 ]]; then
    echo -e "Usage: doenv ENV COMMAND [ARG]...\n" >&2
    return 1
  fi

  local env=$1
  shift

  local doenv_dir="$HOME/.doenv"
  local token_dir="$doenv_dir/tokens"
  mkdir -p "$token_dir"

  local token_file="$token_dir/$env"
  local token
  if [[ -f $token_file ]]; then
    token=$(gpg --batch \
                --quiet \
                --decrypt \
                --passphrase-file <(echo $password) \
                --pinentry-mode loopback \
                "$token_file") || return 1
  else
    read -r -s -p "Access token for new environment '$env': " token
    echo
    gpg --batch \
        --quiet \
        --symmetric \
        --cipher-algo AES256 \
        --passphrase-file <(echo $password) \
        --pinentry-mode loopback \
        -o "$token_file" \
        <(echo $token)
  fi
  env DIGITALOCEAN_ACCESS_TOKEN="$token" $@
}

# Bash wrapper for the main function.
function doenv {
  if [[ -z ${__doenv_password+x} ]]; then
    read -r -s -p 'doenv password: ' __doenv_password
    echo
    PS1="DO $PS1"
  fi
  __doenv_main <(echo $__doenv_password) $@
}
