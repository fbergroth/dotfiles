export EDITOR=vim
export VISUAL=vim
export PAGER=less

[[ -z "$LANG" ]] && export LANG='en_US.UTF-8'

typeset -gU cdpath fpath mailpath path

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.npm-global/bin
  $path
)

export LESS='-F -g -i -M -R -S -w -X -z-4'
(( $#commands[(i)lesspipe(|.sh)] )) && export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"

# Local Variables:
# mode: sh
# End:
