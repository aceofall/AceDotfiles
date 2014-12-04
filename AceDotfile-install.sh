#!/usr/bin/env bash
############################  SETUP PARAMETERS
app_name='AceDotfiles'
app_dir="$HOME/.AceDotfiles"
[ -z "$git_uri" ] && git_uri='https://github.com/aceofall/AceDotfiles.git'
git_branch='master'
debug_mode='0'
fork_maintainer='0'
[ -z "$VUNDLE_URI" ] && VUNDLE_URI="https://github.com/gmarik/vundle.git"

############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
    msg "\e[32m[✔]\e[0m ${1}${2}"
    fi
}

error() {
    msg "\e[31m[✘]\e[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
      msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    type $1 >/dev/null 2>&1 || { local ret='1'; }

    # throw error on non-zero return value
    if [ ! "$ret" -eq '0' ]; then
    error "$2"
    fi
}

############################ SETUP FUNCTIONS
lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

do_backup() {
    if [ -e "$2" ] || [ -e "$3" ] || [ -e "$4" ]; then
        today=`date +%Y%m%d_%s`
        for i in "$2" "$3" "$4"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv "$i" "$i.$today";
        done
        ret="$?"
        success "$1"
        debug
   fi
}

upgrade_repo() {
      msg "trying to update $1"

      if [ "$1" = "$app_name" ]; then
          cd "$app_dir" &&
          git pull origin "$git_branch"
      fi

      if [ "$1" = "vundle" ]; then
          cd "$HOME/.vim/bundle/vundle" &&
          git pull origin master
      fi

      ret="$?"
      success "$2"
      debug
}

clone_repo() {
    program_exists "git" "Sorry, we cannot continue without GIT, please install it first."

    if [ ! -e "$app_dir" ]; then
        git clone --recursive -b "$git_branch" "$git_uri" "$app_dir"
        ret="$?"
        success "$1"
        debug
    else
        upgrade_repo "$app_name"    "Successfully updated $app_name"
    fi
}

clone_vundle() {
    if [ ! -e "$HOME/.vim/bundle/vundle" ]; then
        git clone $VUNDLE_URI "$HOME/.vim/bundle/vundle"
    else
        upgrade_repo "vundle"   "Successfully updated vundle"
    fi
    ret="$?"
    success "$1"
    debug
}

create_symlinks() {
    endpath="$app_dir"

    lnif "$endpath/bashrc"          "$HOME/.bashrc"
    lnif "$endpath/bash_aliases"    "$HOME/.bash_aliases"
    lnif "$endpath/ctags"           "$HOME/.ctags"
    lnif "$endpath/editrc"          "$HOME/.editrc"
    lnif "$endpath/gitconfig"       "$HOME/.gitconfig"
    lnif "$endpath/gitconfig.user"  "$HOME/.gitconfig.user"
    lnif "$endpath/gitignore"       "$HOME/.gitignore"
    lnif "$endpath/inputrc"         "$HOME/.inputrc"
    lnif "$endpath/tmux.conf"       "$HOME/.tmux.conf"
    lnif "$endpath/tmux.conf.user"  "$HOME/.tmux.conf.user"
    lnif "$endpath/screenrc"        "$HOME/.screenrc"
    lnif "$endpath/globalrc"        "$HOME/.globalrc"

    ret="$?"
    success "$1"
    debug
}

setup_vundle() {
    system_shell="$SHELL"
    export SHELL='/bin/sh'
    
    vim \
        -u "$app_dir/.vimrc.bundles.default" \
        "+set nomore" \
        "+BundleInstall!" \
        "+BundleClean" \
        "+qall"
    
    export SHELL="$system_shell"

    success "$1"
    debug
}

############################ MAIN()
program_exists "vim" "To install $app_name you first need to install Vim."

clone_repo      "Successfully cloned $app_name"

create_symlinks "Setting up vim symlinks"

msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` http://aceofall.github.com/"
