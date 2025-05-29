# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# HISTIGNORE="&:ls:[bf]g:exit:rm:cp:mv:pwd:clear:mount:umount:[ \t]*"

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi


# Add git branch if its present to PS1

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
    promnt_name='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\W\[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}[\W]$(parse_git_branch)\$ '
fi


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# if [ $HOSTNAME == "desktop" ]
# then
#     xmodmap ~/.dotfiles/bash/.Xmodmap
# fi

alias pt="python3"
alias python="/usr/bin/python3.13"
alias ns="source ~/.new_session_tt"
alias pdf="lowriter --convert-to pdf"
alias ssh='kitty +kitten ssh'
alias airn="bluetoothctl connect C0:86:B3:DF:F8:59"
alias airff="bluetoothctl disconnect C0:86:B3:DF:F8:59"
alias venv="source /home/slava/code/bash_scripts/create_venv.sh"
alias af='docker compose -f /home/slava/code/airflow-instanses/personal-2.4.2/docker-compose.yaml'
alias t='docker compose -f /home/slava/torrent/docker-compose.yaml'

alias yt-dlp=yt-dlp-wrapper


alias ls='ls -F'
alias ll='ls -lhAF --group-directories-first --no-group'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias dud='du -h -d 1 | sort -h'
alias path="echo $PATH | tr : '\n'"

alias ttl="sudo iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65 && echo '-> ttl 65'"

alias nodiff="git diff --no-index"


bind 'set bell-style none'


export PATH=$PATH:$HOME/.local/bin/
export PATH=/opt/node-v20.10.0-linux-x64/bin:$PATH
export PATH=$HOME/code/learn.clickhouse.com:$PATH
export EDITOR='nvim'

setxkbmap "us,ru" ",winkeys" "grp:lwin_toggle"
setxkbmap -option ctrl:nocaps

function cht() { curl "cht.sh/$1"; }

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

rcp() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
}
rmv() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files "$@"
}

export WORK_REPOS_CONFIG_FILENAME=$HOME/code/output/repos.json
