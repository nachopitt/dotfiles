### Aliases
# The best way to store your dotfiles: A bare Git repository
# https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
alias config='yadm'
alias vim-config='GIT_DIR="$(yadm rev-parse --git-dir)" GIT_WORK_TREE="$HOME" vim'
alias nvim-config='GIT_DIR="$(yadm rev-parse --git-dir)" GIT_WORK_TREE="$HOME" nvim'
