function git-config {
    git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME @args
}

Set-Alias -Name config -Value git-config
