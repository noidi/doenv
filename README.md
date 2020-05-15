# doenv

doenv is a small shell script to manage the `DIGITALOCEAN_ACCESS_TOKEN` environment variable used by tools like [doctl](https://github.com/digitalocean/doctl) and [Terraform](https://www.terraform.io/docs/providers/do/index.html). It solves two problems I had with the existing tooling:

1. I want to explicitly specify which token to use for each command to minimize the risk of running it against the wrong account.

2. I want to store my access tokens encrypted on the device where they are used. I don't feel comfortable storing the tokens as plaintext, and copying and pasting them manually from a password manager is cumbersome and error-prone.

## Installation

1. Clone this repo somewhere, e.g. in your home directory.

2. Follow the instructions for your shell to load doenv on startup.

### Bash

Add the following line to `~/.bashrc`:

```
source path/to/doenv/doenv.sh
```

### ZSH

Add the following line to `~/.zshrc`:

```
source path/to/doenv/doenv.zsh
```

### Fish

Add the following line to `~/.config/fish/config.fish`:

```
source path/to/doenv/doenv.fish
```

## Usage

```
doenv TOKEN_NAME COMMAND [ARG]...
```

For example:

```
doenv my-test doctl account get
```

Or:

```
doenv my-prod terraform apply
```

When you first run doenv in a new shell, it will ask you for the password used to encrypt and decrypt the tokens. It will then change the prompt to start with `DO` to indicate that the password is now stored in the shell's memory. (If you enter the wrong password, currently the only way to enter a new password is to restart the shell and re-run doenv.)

To add a new token, run doenv with an unused token name, and it will ask you for the token. To remove a previously saved token, delete the corresponding file from `~/.doenv/tokens/`.

## Security

doenv uses GPG to encrypt the tokens using AES-256. It only decrypts the requested token and only for the duration of the given command. This should make it harder (though not impossible*) for an attacker with read-only access to your system to steal the tokens.

_*) At least on Linux, while a command is being run with doenv, the selected token will be readable from `/proc/<pid>/environ` where `<pid>` is the [PID](https://en.wikipedia.org/wiki/Process_identifier) of the command or one of its subprocesses. I still think this is an improvement over having all your tokens readable from a fixed location like `~/.config/doctl/config.yaml` all the time._
