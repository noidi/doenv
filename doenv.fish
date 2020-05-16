set __doenv_dir (pushd (dirname (status --current-filename)); and pwd; and popd)

function doenv
    if not set -q __doenv_password
        read -g -s -P 'doenv password: ' __doenv_password
        functions --copy fish_prompt fish_prompt_old
        function fish_prompt
            echo -n 'DO '
            fish_prompt_old
        end
    end
    bash "$__doenv_dir/doenv_core.sh" (echo $__doenv_password | psub) $argv
end
