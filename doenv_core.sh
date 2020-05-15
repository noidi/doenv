set -eu

# Use a named pipe instead of a command line argument or an environment variable
# to avoid leaking the password to /proc/<pid>/cmdline or /proc/<pid>/environ.
read -r password <"$1"
shift

if [[ $# -lt 2 ]]; then
  echo -e "Usage: doenv ENV COMMAND [ARG]...\n" >&2
  exit 1
fi

env=$1
shift

doenv_dir="$HOME/.doenv"
token_dir="$doenv_dir/tokens"
mkdir -p "$token_dir"

token_file="$token_dir/$env"
if [[ -f $token_file ]]; then
  token=$(gpg --batch \
              --quiet \
              --decrypt \
              --passphrase-file <(echo $password) \
              --pinentry-mode loopback \
              "$token_file")
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
