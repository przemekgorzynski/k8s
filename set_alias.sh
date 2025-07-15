#!/usr/bin/env bash

# Create ~/.bash_aliases with the given aliases
cat > ~/.bash_aliases <<EOF
alias -g k='kubectl'
alias -g w='watch '
alias -g rk='scp przemek@10.0.0.9:~/.kube/config ~/.kube/config'
alias -g ga="git commit --amend --no-edit && git push -f"
alias test='date'
EOF

echo "✅ Created ~/.bash_aliases"

# 2️⃣ The line to add
SOURCE_LINE='[ -f ~/.bash_aliases ] && source ~/.bash_aliases'

# 3️⃣ Add to ~/.bashrc and ~/.zshrc if they exist
for rcfile in ~/.bashrc ~/.zshrc; do
  if [ -f "$rcfile" ]; then
    if grep -Fxq "$SOURCE_LINE" "$rcfile"; then
      echo "ℹ️  $rcfile already sources ~/.bash_aliases"
    else
      printf "\n$SOURCE_LINE\n" >> "$rcfile"
      echo "✅ Added source line to $rcfile"
      source $rcfile
    fi
  else
    echo "⚠️  $rcfile does not exist, skipping."
  fi
done

echo "🎉 Done! Now ~/.zshrc will source ~/.bash_aliases!"