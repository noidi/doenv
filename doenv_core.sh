set -eu

# Use a named pipe instead of a command line argument or an environment variable
# to avoid leaking the password to /proc/<pid>/cmdline or /proc/<pid>/environ.
read -r password <"$1"
shift

if [[ $# -lt 2 ]]; then
  echo -e "Usage: doenv TOKEN_NAME COMMAND [ARG]...\n" >&2
  exit 1
fi

token_name=$1
shift

doenv_dir="$HOME/.doenv"
token_dir="$doenv_dir/tokens"
mkdir -p "$token_dir"

token_file="$token_dir/$token_name"
if [[ -f $token_file ]]; then
  token=$(gpg --batch \
              --quiet \
              --decrypt \
              --passphrase-file <(echo $password) \
              --pinentry-mode loopback \
              "$token_file")
else
  echo "Creating a new access token: $token_name"
  read -r -s -p "Copy and paste the token here (input will be hidden): " token
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
