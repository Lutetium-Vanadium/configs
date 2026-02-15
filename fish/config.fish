abbr -a claer clear

abbr -a yr 'cal -y'
abbr -a c cargo
abbr -a e nvim
abbr -a vi nvim
abbr -a m make
abbr -a o open
abbr -a g git
abbr -a gc 'git commit -v'
abbr -a gl 'git log --oneline -n 10'
abbr -a glf 'git log'
abbr -a gd 'git diff'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gap 'git add -p'
abbr -a gss 'git status -s'
abbr -a vimdiff 'nvim -d'
abbr -a ct 'cargo t'
abbr -a pr 'gh pr create -t (git show -s --format=%s HEAD) -b (git show -s --format=%B HEAD | tail -n+3)'
abbr -a cdcode 'cd ~/code'
abbr -a cdjs 'cd ~/code/javascript'
abbr -a cdpy 'cd ~/code/Python'
abbr -a cdrs 'cd ~/code/rust'
abbr -a vifconf 'nvim ~/.config/fish/config.fish'
abbr -a vivconf 'nvim ~/.config/nvim/init.lua'
abbr -a cd 'z'

# Disable nvm
# nvm use 22 > /dev/null

set -x CARGO_TARGET_DIR "$HOME/.cargo-target"
set -x EDITOR (which nvim)
set -x VISUAL (which nvim)
set -x PATH "$HOME/.cargo/bin:$PATH"
set -x PATH "$HOME/.bin:$PATH"
set -x PATH "/opt/homebrew/bin:$PATH"
set -x PATH "/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

bind -s --preset -M default L end-of-line

# if status --is-interactive
#     if test -d ~/dev/others/base16/templates/fish-shell
#         set fish_function_path $fish_function_path ~/dev/others/base16/templates/fish-shell/functions
#         builtin source ~/dev/others/base16/templates/fish-shell/conf.d/base16.fish
#     end
#     tmux ^ /dev/null; and exec true
# end

if command -v eza > /dev/null
    abbr -a l 'eza -lah --icons=always'
    abbr -a ls 'eza --icons=always'
    abbr -a ll 'eza -l --icons=always'
    abbr -a lll 'eza -la --icons=always'
    abbr -a tree 'eza --icons=always -T'
else
    abbr -a l 'ls -lah'
    abbr -a ll 'ls -l'
    abbr -a lll 'ls -la'
end

if test -f /usr/share/autojump/autojump.fish;
    source /usr/share/autojump/autojump.fish;
end

function r
    for i in $history
        if string match -q -r "^(clear|r) *\$" $i
        else
            echo "Running: $i"
            eval $i
            return
        end
    end
end

function apass
    if test (count $argv) -ne 1
        pass $argv
        return
    end

    asend (pass $argv[1] | head -n1)
end

function qrpass
    if test (count $argv) -ne 1
        pass $argv
        return
    end

    qrsend (pass $argv[1] | head -n1)
end

function asend
    if test (count $argv) -ne 1
        echo "No argument given"
        return
    end

    adb shell input text (echo $argv[1] | sed -e 's/ /%s/g' -e 's/\([[()<>{}$|;&*\\~"\'`]\)/\\\\\1/g')
end

function qrsend
    if test (count $argv) -ne 1
        echo "No argument given"
        return
    end

    qrencode -o - $argv[1] | feh --geometry 500x500 --auto-zoom -
end

function limit
    numactl -C 0,1,2 $argv
end

function remote_alacritty
    # https://gist.github.com/costis/5135502
    set fn (mktemp)
    infocmp alacritty > $fn
    scp $fn $argv[1]":alacritty.ti"
    ssh $argv[1] tic "alacritty.ti"
    ssh $argv[1] rm "alacritty.ti"
end

function remarkable
    if test (count $argv) -lt 1
        echo "No files given"
        return
    end

    ip addr show up to 10.11.99.0/29 | grep enp2s0f0u3 >/dev/null
    if test $status -ne 0
        # not yet connected
        echo "Connecting to reMarkable internal network"
        sudo dhcpcd enp2s0f0u3
    end
    for f in $argv
        echo "-> uploading $f"
        curl --form "file=@\""$f"\"" http://10.11.99.1/upload
        echo
    end
    sudo dhcpcd -k enp2s0f0u3
end

source ~/.config/fish/fzf.fish
zoxide init fish | source

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_upstream_prefix " "
set __fish_git_prompt_showupstream "informative"
set fish_prompt_pwd_dir_length 1

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
# setenv LESS_TERMCAP_mb "\e[01;31m"       # begin blinking
# setenv LESS_TERMCAP_md "\e[01;38;5;74m"  # begin bold
# setenv LESS_TERMCAP_me "\e[0m"           # end mode
# setenv LESS_TERMCAP_se "\e[0m"           # end standout-mode
# setenv LESS_TERMCAP_so "\e[38;5;246m"    # begin standout-mode - info box
# setenv LESS_TERMCAP_ue "\e[0m"           # end underline
# setenv LESS_TERMCAP_us "\e[04;38;5;146m" # begin underline

setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
setenv FZF_DEFAULT_OPTS '--height 40% --border'
setenv FZF_CTRL_T_OPTS "--reverse --preview='bat --style=numbers --color=always --line-range :500 {}'"
setenv FZF_ALT_C_OPTS "--reverse --preview='eza --icons -T {}'"

# Fish should not add things to clipboard when killing
# See https://github.com/fish-shell/fish-shell/issues/772
set FISH_CLIPBOARD_CMD "cat"

function fish_user_key_bindings
    bind \cz 'fg>/dev/null ^/dev/null'
    if functions -q fzf_key_bindings
        fzf_key_bindings
    end
end

function fish_prompt
    set --local prev_status $status
    set_color brblack
    echo -n " ["(date "+%H:%M")"] "
    set_color -b normal green
    print_path (pwd)
    set_color green
    printf '%s ' (__fish_git_prompt)

    if test $prev_status -ne 0
        set_color brred
        echo -n '✗ '
    end

    set_color red
    echo -n '| '
    set_color normal
end

function fish_right_prompt
    # status gets reset by (set_color brred)
    set -l prev_status $status
    __fish_print_pipestatus '' '' '' (set_color red) '' "$prev_status"
end

# function fish_mode_prompt
#     set --local darkest_green '005f00'
#     set --local bright_green 'afdf00'
# 
#     set --local darkest_cyan '005f5f'
#     set --local medium_cyan '00a5a5'
#     set --local white 'ffffff'
# 
#     set --local dark_red '870000'
#     set --local bright_red 'df0000'
#     set --local bright_orange 'ff8700'
# 
#     set --local delim_start ' '
#     set --local delim_end ' '
# 
#     switch $fish_bind_mode
#         case default
#             # set_color -b $bright_green -o $darkest_green
#             set_color -o $bright_green
#             echo "$delim_start"N"$delim_end"
#         case insert
#             # set_color -b $darkest_cyan -o $white
#             set_color -o $medium_cyan
#             echo "$delim_start"I"$delim_end"
#         case replace_one replace
#             # set_color -b $bright_red -o $white
#             set_color -o $bright_red
#             echo "$delim_start"R"$delim_end"
#         case visual
#             # set_color -b $bright_orange -o $dark_red
#             set_color -o $bright_orange
#             echo "$delim_start"V"$delim_end"
#     end
# 
#     set_color normal
#     # echo -n ' '
# end

function echo_run
    echo -n "RUNNING: "
    for arg in $argv
        echo -n "'$arg' "
    end
    echo ""
    $argv[1] $argv[2..]
end

function print_path
    set_color brblue

    if pwd | rg "code/." &> /dev/null
        set path_components (string split -m1 '/' (realpath --relative-to="$HOME/code" $argv))
        set doc_root $path_components[1]
        set path $path_components[2]
        set git_root (get_git_root "$HOME/code/$doc_root/$path")
        if test $git_root
            set git_root (realpath --relative-to="$HOME/code/$doc_root" $git_root)
        end
        echo -n $doc_root
        set_color yellow
        if test $path
            echo -n '/'
        end
    else if pwd | rg "$HOME" &> /dev/null
        set path (realpath --relative-to=$HOME $argv)
        if test "$path" = "."
            set path "~"
        else
            set path "~/$path"
        end
        set git_root (get_git_root "$HOME/$path")
        if test $git_root
            set git_root (realpath --relative-to=$HOME $git_root)
        end
    else
        set path (realpath --relative-to=/ "$argv[..]")
        if test "$path" = "."
            set path "/"
        else
            set path "/$path"
        end
        set git_root (get_git_root "$path")
        if test $git_root
            set git_root "/"(realpath --relative-to="/" $git_root)
        end
    end

    if test $git_root
        set path (string replace "$git_root" "" $path)
        set shortened_path (shorten_path $git_root)
        if test $shortened_path != '.'
            echo -n $shortened_path
        end
    end

    echo -n $path
end

function get_git_root --description "get path to the git root"
    set -l options h/help
    argparse -n get_git_root --max-args=1 $options -- $argv
    or return

    if set -q _flag_help
        __fish_print_help get_git_root
        return 0
    end

    set root "$argv"

    while test $root != "/" -a $root != "."
        if test -d $root/.git
            echo -n $root
            break
        end

        set root (dirname $root)
    end
end

# Type - to move up to top parent dir which is a repository
function d
    set root (get_git_root $PWD)
    if test $root
        cd $root
    else
        echo "Could not find git root in $PWD"
        return 1
    end
end

function fish_greeting
    set info 
    echo -e "$(system_profiler SPSoftwareDataType | awk '                                                                                                                                        (base)
               /System Version/ {
                   version = $3 " " $4 " " $5
                   print " \\\\e[1mOS: \\\\e[0;32m" version "\\\\e[0m"
               }')"
    echo -e (uname -sr | awk '{print " \\\\e[1mKernel: \\\\e[0;32m"$0"\\\\e[0m"}')
    echo -e "$(system_profiler SPSoftwareDataType | awk '                                                                                                                                        (base)
               /Time since boot/ {
                   $1=$2=$3=""
                   gsub(/^ */, "")
                   print " \\\\e[1mUptime: \\\\e[0;32m" $0 "\\\\e[0m"
               }')"
    echo
end

function moveall
    for i in *
        mv "$i" $i[..$argv[1]]
    end
end

nvm use 22 > /dev/null
set -x COC_NODE_PATH (which node)
# status --is-interactive; and ~/.rbenv/bin/rbenv init - fish | source

set CRYPTOGRAPHY_OPENSSL_NO_LEGACY 1

fish_vi_cursor

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/miniconda3/bin/conda
    eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
        . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<



# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/luv/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/luv/Downloads/google-cloud-sdk/path.fish.inc'; end

# opencode
fish_add_path /Users/luv/.opencode/bin

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
