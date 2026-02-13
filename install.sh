#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dot-files"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "Installing dotfiles..."
mkdir -p "$BACKUP_DIR"

for file in "$DOTFILES_DIR"/*; do
    [ -d "$file" ] && continue
    [[ "$(basename "$file")" =~ ^(install\.sh|README\.md|\.git.*)$ ]] && continue
    
    filename=$(basename "$file")
    dest="$HOME/.$filename"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up $filename"
        mv "$dest" "$BACKUP_DIR/"
    fi
    
    [ -L "$dest" ] && rm "$dest"
    
    echo "Linking $filename"
    ln -s "$file" "$dest"
done

[ -z "$(ls -A "$BACKUP_DIR")" ] && rmdir "$BACKUP_DIR" || echo "Backups: $BACKUP_DIR"
echo "Done!"
