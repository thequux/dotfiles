# -*- mode: sh; sh-shell-file: /bin/zsh -*-
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' substitute 1
zstyle :compinstall filename '/home/thequux/.../zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd HIST_IGNORE_DUPS	INTERACTIVE_COMMENTS
unsetopt beep nomatch
bindkey -e
# End of lines configured by zsh-newuser-install

# if I'm in emacs, certain things should be changed...
if [[ -z "${INSIDE_EMACS}" ]]; then
   PROMPT=$'%{\e[1;32m%}%n%{\e[0;39m%}@%{\e[1;31m%}%m%{\e[0;39m%} <%{\e[1;36m%}%~%{\e[0;39m%}>\n%{\e[%(#.31.1)m%}[%?]%{\e[0m%} '
   export EDITOR=emacsclient
   export ALTERNATE_EDITOR=emacs
else
    PROMPT=$'%n@%m <%~>\n[%?] '
    alias ls='ls --color=never'
fi

todo -G

