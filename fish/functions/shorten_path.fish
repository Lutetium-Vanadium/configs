function shorten_path --description "Prints a path, shortened to fit the prompt"
    set -l options h/help
    argparse -n shorten_path --max-args=1 $options -- $argv
    or return

    if set -q _flag_help
        __fish_print_help shorten_path
        return 0
    end

    # This allows overriding fish_prompt_pwd_dir_length from the outside (global or universal) without leaking it
    set -q fish_prompt_pwd_dir_length
    or set -l fish_prompt_pwd_dir_length 1

    # Replace $HOME with "~"
    set -l realhome ~
    set -l tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $argv)

    if [ $fish_prompt_pwd_dir_length -eq 0 ]
        echo $tmp
    else
        # Shorten to at most $fish_prompt_pwd_dir_length characters per directory
        string replace -ar '(\.?[^/]{'"$fish_prompt_pwd_dir_length"'})[^/]*/' '$1/' $tmp
    end
end
