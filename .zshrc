ZIM_HOME=~/.zim

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias la='ls -a'
alias ll='ls -lah'

# Ctrl+Left/Right to move between words
bindkey "^[[1;5C" emacs-forward-word
bindkey "^[[1;5D" emacs-backward-word

# completions for go-task
# original: https://github.com/sawadashota/go-task-completions
# Listing commands from Taskfile.yml
function __list_tasks() {
    local -a scripts

    if ls Taskfile.yaml > /dev/null 2>&1; then
        tasks=$(task -l | sed -En "s/^\* ([^[:space:]]+):[[:space:]]+(.+)$/\1 \2/p" | awk '{gsub(/:/,"\\:",$1)} 1' | awk "{ st = index(\$0,\" \"); print \$1 \":\" substr(\$0,st+1)}")
        scripts=("${(@f)$(echo $tasks)}")
        _describe 'script' scripts
    fi
}

_task() {
    _arguments \
        '(-d --dir)'{-d,--dir}'[sets directory of execution]: :_files' \
        '(--dry)'--dry'[compiles and prints tasks in the order that they would be run, without executing them]' \
        '(-f --force)'{-f,--force}'[forces execution even when the task is up-to-date]' \
        '(-i --init)'{-i,--init}'[creates a new Taskfile.yml in the current folder]' \
        '(-l --list)'{-l,--list}'[lists tasks with description of current Taskfile]' \
        '(-p --parallel)'{-p,--parallel}'[executes tasks provided on command line in parallel]' \
        '(-s --silent)'{-s,--silent}'[disables echoing]' \
        '(--status)'--status'[exits with non-zero exit code if any of the given tasks is not up-to-date]' \
        '(--summary)'--summary'[show summary about a task]' \
        '(-t --taskfile)'{-t,--taskfile}'[choose which Taskfile to run. Defaults to "Taskfile.yml"]' \
        '(-v --verbose)'{-v,--verbose}'[enables verbose mode]' \
        '(--version)'--version'[show Task version]' \
        '(-w --watch)'{-w,--watch}'[enables watch of the given task]' \
        '(- *)'{-h,--help}'[show help]' \
        '*: :__list_tasks'
}

compdef _task task
