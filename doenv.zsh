__doenv_dir=$(cd $(dirname "$0") && pwd)

function doenv {
  if [[ -z ${__doenv_password+x} ]]; then
    read -r -s '?doenv password: ' __doenv_password
    echo
    PS1="DO $PS1"
  fi
  bash "${__doenv_dir}/doenv_core.sh" <(echo $__doenv_password) $@
}
