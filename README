# dotfiles
dotfiles

https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/

Steps:

To install in current setup:
```console
git clone git@github.com:nachopitt/dotfiles.git $HOME/.cfg
```

To create a "config" alias to be used instead of the git command for all git related operations:
```console
alias config='/usr/bin/git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME'
```

```powershell
function config { git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME @args }
```

To see changes in the working tree
```console
config status
```

To avoid showing up the untracked files when performing operations such as "config status"
```console
config config --local status.showUntrackedFiles no
```

To pull new changes:
```console
config pull
```

To see differences:
```console
config diff
```

To add changes to the staging area:
```console
config add files...
```

To commit changes:
```console
config commit
```

To push changes:
```console
config push
```
