#!/bin/bash

# helper functions
answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}
ask() {
    print_question "$1"
    read
}
ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -n 1
    printf "\n"
}
execute() {
    $1 &> /dev/null
    print_result $? "${2:-$1}"
}
get_answer() {
    printf "$REPLY"
}
print_error() {
    printf "\e[0;31m [✖] $1 $2\e[0m\n"
}
print_info() {
    printf "\e[0;35m [i] $1\e[0m\n"
}
print_question() {
    printf "\e[0;33m [?] $1\e[0m"
}
print_success() {
    printf "\e[0;32m [✔] $1\e[0m\n"
}
print_result() {
    [ $1 -eq 0 ] \
        && print_success "$2" \
        || print_error "$2"

    [ "$3" == "true" ] && [ $1 -ne 0 ] \
        && exit
}

# finds all .dotfiles in this folder
declare -a FILES_TO_SYMLINK=$(find . -maxdepth 1 -type f -name ".*" -not -name .DS_Store -not -name .git | sed -e 's|//|/|' | sed -e 's|./.|.|')
FILES_TO_SYMLINK="$FILES_TO_SYMLINK"

# symlink files
main() {
    local i=""
    local sourceFile=""
    local targetFile=""

    for i in ${FILES_TO_SYMLINK[@]}; do

        sourceFile="$(pwd)/$i"
        targetFile="$HOME/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ -e "$targetFile" ]; then
            if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then
                    rm -rf "$targetFile"
                    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
                else
                    print_error "$targetFile → $sourceFile"
                fi

            else
                print_success "$targetFile → $sourceFile"
            fi
        else
            execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
        fi

    done
}

main

# install z
if [ ! -d "$HOME/z" ]; then
    git clone --quiet https://github.com/rupa/z.git $HOME/z
    chmod +x $HOME/z/z.sh
    print_success "z installed"
else
    print_info "z folder already exists"
fi

# install tpm
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone --quiet https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    print_success "tpm installed"
else
    print_info "tpm folder already exists"
fi
