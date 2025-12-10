# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# source ~/.local/share/omarchy/default/bash/rc  # Commented out - file doesn't exist

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Arrow Style Prompt with Git support
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Colors
RESET='\[\033[0m\]'
BOLD='\[\033[1m\]'
CYAN='\[\033[36m\]'
GREEN='\[\033[32m\]'
BLUE='\[\033[34m\]'
PURPLE='\[\033[35m\]'
YELLOW='\[\033[33m\]'
GREY='\[\033[90m\]'

# Build the prompt
PS1="${BOLD}${CYAN}\u@\h${RESET} "
PS1+="${GREY}→${RESET} "
PS1+="${BLUE}\w${RESET}"

# Add git branch if in a repo
PS1+='$(if [ "$(parse_git_branch)" ]; then echo " '"${GREY}→${RESET} ${PURPLE}"'$(parse_git_branch)'"${RESET}"'"; fi)'

PS1+=" ${GREEN}→${RESET} "

export PS1
