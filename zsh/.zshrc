# vim: ts=2:sw=2

# Avoid beeping
set nobeep

# Set history file
export HISTFILE=~/.zsh_history

# Save lots of history entries
# 1 Mio, should keep histfile max. in the order of MB
export HISTSIZE=10000000
export HISTFILESIZE=1000000
export SAVEHIST=1000000

# Append command to the history file before execution
setopt inc_append_history

# Reload history regularily
setopt share_history

# Include timestamp in history
setopt extended_history

# Ignore subsequent duplicate history entries
setopt hist_ignore_dups

# Do not include function definitions in the history file
setopt hist_no_functions

# Do not store the "history" command itself
setopt hist_no_store

# Remove superfluous blanks from history
setopt hist_reduce_blanks

# Change directory without "cd"
setopt auto_cd

# Ignore comments on the command line
setopt interactive_comments

# Disable flow control
setopt no_flow_control

# Initialize completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# List choices on an ambiguous completion
zstyle ':completion:*' menu select

# Complete within words
setopt complete_in_word

# Also autocomplete switches for aliases
setopt complete_aliases

# Extended globbing (e.g. ./**/*.js)
setopt extended_glob

# Enable bracketed paste support
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Enable support for Ctrl+X Ctrl+E
autoload edit-command-line
zle -N edit-command-line

# Key bindings
bindkey -e

backward-kill-dir () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N backward-kill-dir

typeset -A key
key=(
    Home    "$terminfo[khome]"
    End     "$terminfo[kend]"
    Insert  "$terminfo[kich1]"
    Backspace "$terminfo[kbs]"
    Delete  "$terminfo[kdch1]"
    Up      "$terminfo[kcuu1]"
    Down    "$terminfo[kcud1]"
    Left    "$terminfo[kcub1]"
    Right   "$terminfo[kcuf1]"
    PageUp  "$terminfo[kpp]"
    PageDown "$terminfo[knp]"
    CLeft   "$terminfo[kLFT5]"
    CRight  "$terminfo[kRIT5]"
)
[[ -n "$key[Home]"      ]] && bindkey -- "$key[Home]"       beginning-of-line
[[ -n "$key[End]"       ]] && bindkey -- "$key[End]"        end-of-line
[[ -n "$key[PageUp]"    ]] && bindkey -- "$key[PageUp]"     beginning-of-history
[[ -n "$key[PageDown]"  ]] && bindkey -- "$key[PageDown]"   end-of-history
[[ -n "$key[Delete]"    ]] && bindkey -- "$key[Delete]"     delete-char
[[ -n "$key[CLeft]"     ]] && bindkey -- "$key[CLeft]"      backward-word
[[ -n "$key[CRight]"    ]] && bindkey -- "$key[CRight]"     forward-word

# alternatives for wonky terminals (find out with 'showkey -a')

bindkey -- "^[[H"       beginning-of-line
bindkey -- "^[[1~"      beginning-of-line
bindkey -- "^[[F"       end-of-line
bindkey -- "^[[4"       end-of-line
bindkey -- "^[[1;5D"    backward-word
bindkey -- "^[[1;5C"    forward-word
bindkey -- "^[[3;5~"    delete-word
bindkey -- "^[^H"       backward-kill-dir # alt + backspace
bindkey -- "^R"         history-incremental-search-backward
bindkey -- "^X^e"       edit-command-line

# 'hash' often used directories so they can be accessed as ~doc, ~log, ...
hash -d doc=/usr/share/doc
hash -d linux=/lib/modules/$(command uname -r)/build/
hash -d log=/var/log
hash -d slog=/var/log/syslog
hash -d src=/usr/src
hash -d www=/var/www

# automatically rehash on each completion
zstyle ':completion:*' rehash true

# Configure prompt

# Configure VCS/Git support
# see https://timothybasanov.com/2016/04/23/zsh-prompt-and-vcs_info.html
# and https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats '(%F{green}%b%f%u%c) '
zstyle ':vcs_info:*' actionformats '(%F{red}%b|%a%f%u%c) '

# Kerberos ticket info (implementation by me)
precmd_klist_info() {
  klist_info_msg_=""

  if [[ -z $KRB5CCNAME ]]; then
    return
  fi

  local username="${KRB5CCNAME:t:r}"

  if ! type klist > /dev/null; then
    klist_info_msg_="[%F{yellow}$username%f (?)] "
  elif klist -s; then
    klist_info_msg_="[%F{green}$username%f] "
  else
    klist_info_msg_="[%F{red}$username%f (exp)] "
  fi
}
precmd_functions+=( precmd_klist_info )

setopt prompt_subst

# Primary prompt
PROMPT='%F{yellow}%n@%m%f %F{red}%B%~%b%f ${vcs_info_msg_0_}${klist_info_msg_}%(!.#.$) '

# Primary prompt (right side)
# RPROMPT='[%F{yellow}%?%f]'

# Secondary prompt
PS2='%F{red}\%f '
# Selection prompt used within a select loop.
PS3='?# '
# Execution trace prompt (setopt xtrace). default: '+%N:%i>'
PS4='+%N:%i:%_> '

# Terminal title
_zsh_termtitle_set_title() {
    case ${TERM} in
        screen)
            print -Pn '\Ek'${(fV)1}'\E\\'
            ;;
        *)
            print -Pn '\E]0;'${(fV)1}'\a'
            ;;
    esac
}

_zsh_termtitle_update_precmd() {
    # see https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
    _zsh_termtitle_set_title '%n@%m: %~'
}

_zsh_termtitle_update_preexec() {
    # see https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
    _zsh_termtitle_set_title '%n@%m: '${(r:20:)2}
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_termtitle_update_precmd
add-zsh-hook preexec _zsh_termtitle_update_preexec

# Configure default applications (can be overriden later in .zshrc.local)
export VISUAL="$(command -v nvim || command -v vim || command -v nano || command -v vi)"
export EDITOR="$VISUAL"
export SUDO_EDITOR="$VISUAL"
export PAGER="$(command -v less || command -v more)"
export TERMINAL="$(command -v konsole || command -v gnome-terminal || command -v xfce4-terminal || command -v qterminal || command -v xterm)"
export BROWSER="$(command -v firefox || command -v chromium)"

# Color aliases
if type dircolors > /dev/null; then
  eval "$(dircolors -b)"
fi

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"

# Color for less/man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Enhance existing commands
alias cp="cp -v"
alias mv="mv -v"
alias ln="ln -v"
alias rm="rm -v"
alias chmod="chmod -c"
alias chown="chown -c"
alias mkdir="mkdir -v"
alias rmdir="rmdir -v"

# Common aliases
alias ll="ls -alhF"
if type "nvim" > /dev/null; then
    alias vim="nvim"
fi
if type "fdfind" > /dev/null; then
    alias fd="fdfind --unrestricted"
fi
alias view="vim -R"
alias vimdiff="vim -d"
alias ipsort="sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4"

function mkcd () {
    if (( ARGC != 1 )); then
        printf 'usage: mkcd <new-directory>\n'
        return 1
    fi
    if [[ ! -d "$1" ]]; then
        command mkdir -p "$1"
    else
        printf '`%s'\'' already exists: cd-ing.\n' "$1"
    fi
    builtin cd "$1"
}

function kuse () {
  if (( ARGC != 1 )); then
    printf 'usage: kuse <ticket>\n'
    return 1
  fi

  if [[ ! -f $1 ]]; then
    printf "Ticket file does not exist: $1\n"
    unset KRB5CCNAME
    return 1
  fi

  export KRB5CCNAME="${1:a}"

  if type klist > /dev/null; then
    if ! klist -s; then
      printf 'Warning: Expired Kerberos ticket.\n'
    fi
  fi
}

# Load direnv hook
if type "direnv" > /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Activate rbenv
if type "rbenv" > /dev/null; then
    eval "$(rbenv init -)"
fi

# Activate FZF
if type "fzf" > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f'

    if [ -e "/usr/share/fzf/completion.zsh" ]; then
        # Arch
        source "/usr/share/fzf/completion.zsh"
    elif [ -e "/usr/share/doc/fzf/examples/completion.zsh" ]; then
        # Debian
        source "/usr/share/doc/fzf/examples/completion.zsh"
    fi

    if [ -e "/usr/share/fzf/key-bindings.zsh" ]; then
        # Arch
        source "/usr/share/fzf/key-bindings.zsh"
    elif [ -e "/usr/share/doc/fzf/examples/key-bindings.zsh" ]; then
        # Debian
        source "/usr/share/doc/fzf/examples/key-bindings.zsh"
    fi
fi

# Enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# Add common directories to PATH
export PATH=$PATH:$HOME/.local/bin

# Source local zshrc
if [[ -e "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

