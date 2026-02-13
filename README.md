# Dotfiles

Personal configuration files managed with Git and symlinks.

## Structure

Files are stored without their leading dot. Symlinks connect `~/` to `~/.dot-files/`.

## Installation

```bash
git clone git@github.com:chochkov/dot-files.git ~/.dot-files
cd ~/.dot-files
./install.sh
```

## Adding New Dotfiles

```bash
mv ~/.newfile ~/.dot-files/newfile
ln -s ~/.dot-files/newfile ~/.newfile
cd ~/.dot-files
git add newfile
git commit -m "Add newfile"
git push
```
