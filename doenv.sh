__doenv_dir=$(cd $(dirname "$BASH_SOURCE") && pwd)

function doenv {
  if [[ -z ${__doenv_password+x} ]]; then
    read -r -s -p 'doenv password: ' __doenv_password
    echo
    PS1="DO $PS1"
  fi
  bash "${__doenv_dir}/doenv_core.sh" <(echo $__doenv_password) $@
}
