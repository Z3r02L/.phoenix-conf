# .bashrc

# Если не интерактивная оболочка, выйти
[[ $- != *i* ]] && return

# Псевдонимы
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Настройки PS1
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Путь к PATH
export PATH="$HOME/.local/bin:$PATH"

# Настройки редактора
export EDITOR=nvim
export VISUAL=nvim

# История команд
export HISTSIZE=10000
export HISTFILESIZE=100
