if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Wizard options: nerdfont-complete + powerline, small icons, lean, time, 1 line,
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/powerlevel10k/config/p10k-lean.zsh
typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER// }'
typeset -g POWERLEVEL9K_DIR_CLASSES=()
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs kubecontext gcloud virtualenv time)

HISTFILE="$HOME/.zhistory"
HISTSIZE=10000000
SAVEHIST=10000000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_BEEP

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Keys

bindkey -e
bindkey '^ ' autosuggest-accept
bindkey '^T' fzy-file-widget
bindkey '^R' fzy-history-widget
bindkey '^P' fzy-proc-widget

# Aliases

alias ls='ls --color=auto --group-directories-first'
alias l='ls -1A'
alias ll='ls -lh'
alias lr='ll -R'
alias ..='cd ..'
alias df='df -kh'
alias du='du -kh'
alias o='xdg-open'

# Completion

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PATH_DIRS
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt EXTENDED_GLOB
unsetopt CASE_GLOB
unsetopt MENU_COMPLETE
unsetopt FLOW_CONTROL

fpath=(~/.zsh/zsh-completions/src $fpath)
autoload -Uz compinit && compinit -i

(( $+commands[kubectl] )) && source <(kubectl completion zsh)
(( $+commands[helm] )) && source <(helm completion zsh)

# Using prezto settings ↴
# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single


# Utilities

_virtualenv_auto_activate () {
  emulate -L zsh -o extendedglob
  activate=((../)#.venv/bin/activate(Y1N:a))
  [[ -n "$VIRTUAL_ENV" && -z $functions[deactivate] ]] && unset VIRTUAL_ENV
  [[ -n "$VIRTUAL_ENV" && "${activate:h:h}" != "$VIRTUAL_ENV" ]] && deactivate
  [[ -z "$VIRTUAL_ENV" && -n "$activate" ]] && source "$activate"
}
chpwd_functions+=(_virtualenv_auto_activate)
_virtualenv_auto_activate

# Plugins

eval $(dircolors -b ~/.zsh/LS_COLORS/LS_COLORS)
source ~/.zsh/z/z.sh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-fzy/zsh-fzy.plugin.zsh
zstyle ':fzy:file' command rg --files
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Local Variables:
# mode: sh
# End:
