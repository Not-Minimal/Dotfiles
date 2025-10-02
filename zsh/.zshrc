# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew
export PATH="/opt/homebrew/bin:$PATH" 

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Configuración del historial
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS  # No duplicados en historial
setopt HIST_FIND_NO_DUPS     # No duplicados al buscar
setopt INC_APPEND_HISTORY    # Agregar comandos al historial inmediatamente

# Mejoras de autocompletado
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select  # Menú interactivo
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive

# Funciones
# Crear un directorio y entrar en él
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Alias Propios
alias ls="lsd"
alias la="lsd -la"
alias vim="nvim"
alias to="tmux attach -t"
alias tc="tmux new -s" #Crear nueva sesión
alias tls="tmux ls"
alias tconf='tmux source-file ~/.tmux.conf || echo "No tmux session activa"'
alias studio="npx prisma studio"

# Comandos personalizados
alias ll="lsd -la --group-directories-first"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias kill="kill -9"
alias port="sudo lsof -i -P | grep"
# Git mejorado
alias gco="git checkout"
alias gb="git branch"
alias gl="git log --oneline --graph --decorate"
alias grh="git reset --hard"
alias gst="git stash"
alias gstp="git stash pop"
alias ga="git add ."
alias gd="git diff"
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
# NPM/Yarn
alias ni="npm install"
alias nid="npm install --save-dev"
alias nr="npm run"
alias dev="npm run dev"
alias build="npm run build"

# Utilidades del sistema
alias mkdir="mkdir -p"
alias c="clear"
alias h="history"
alias e="exit"
# Directorios frecuentes
alias projects="cd ~/Development"
alias downloads="cd ~/Downloads"
alias desktop="cd ~/Desktop"
alias docs="cd ~/Documents"

# Abrir archivos con Vim directamente
alias v="vim"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=white,bg=blue,italic"
# Configuración de zsh-history-substring-search
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey "^[[OA" history-substring-search-up   # Flecha option + arriba ⬆️
bindkey "^[[OB" history-substring-search-down # Flecha option + abajo ⬇️

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
eval "$(fzf --zsh)"
source ~/fzf-git.sh/fzf-git.sh
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#7cbba3,fg+:#d0d0d0,bg:-1,bg+:#090316
  --color=hl:#248eff,hl+:#53ff7e,info:#58ff69,marker:#ffffff
  --color=prompt:#00ff22,spinner:#00ff04,pointer:#00ff6f,header:#87afaf
  --color=gutter:#0d1320,border:#09aba8,separator:#0d1320,label:#aeaeae
  --color=query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --padding="1"
  --margin="1" --prompt="👨🏻‍💻" --marker="" --pointer="🚀"
  --separator="" --scrollbar=""'

export PATH="$HOME/depot_tools:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
source ~/powerlevel10k/powerlevel10k.zsh-theme
