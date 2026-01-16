#!/bin/bash
set -e

# ===========================================
# Dev Box Bootstrap Script for Hetzner CX32
# User: morosanandrei
# Stack: Node.js, Docker, Docker Compose, Tailscale
# ===========================================

USERNAME="morosanandrei"
NODE_VERSION="24"  # LTS version, change if needed

echo "=========================================="
echo "🚀 Setting up your dev box..."
echo "=========================================="

# ----- 1. System Update -----
echo "📦 Updating system packages..."
apt-get update && apt-get upgrade -y

# ----- 2. Install Essential Tools -----
echo "🔧 Installing essential tools..."
apt-get install -y \
    git \
    curl \
    wget \
    htop \
    unzip \
    build-essential \
    gnupg \
    lsb-release \
    vim \

# ----- 3. Create User -----
echo "👤 Creating user: $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists, skipping..."
else
    adduser --disabled-password --gecos "" $USERNAME
    usermod -aG sudo $USERNAME
    
    # Allow sudo without password (optional, remove if you want password prompt)
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

    # Copy SSH keys from vagrant to new user
    mkdir -p /home/$USERNAME/.ssh
    cp /home/vagrant/.ssh/authorized_keys /home/$USERNAME/.ssh/
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
fi

# ----- 6. Install Docker -----
echo "🐳 Installing Docker..."
# Remove old versions if any
apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
usermod -aG docker $USERNAME

# ----- 7. Install Node.js via Volta -----
echo "📗 Installing Node.js v$NODE_VERSION via Volta..."
sudo -u $USERNAME bash << EOF
cd ~

# Install Volta
curl https://get.volta.sh | bash

# Add Volta to current session
export VOLTA_HOME="\$HOME/.volta"
export PATH="\$VOLTA_HOME/bin:\$PATH"

# Install Node and package managers
volta install node@$NODE_VERSION
volta install pnpm
volta install yarn
EOF

# ----- 9. Setup Git Config Template -----
echo "📝 Setting up git config..."
sudo -u $USERNAME bash << 'EOF'
git config --global init.defaultBranch main
git config --global core.editor vim
# User should set these:
# git config --global user.name "Your Name"
# git config --global user.email "your@email.com"
EOF

# ----- 10. Create Projects Directory -----
echo "📁 Creating projects directory..."
sudo -u $USERNAME mkdir -p /home/$USERNAME/projects

# ----- 11. Setup .bashrc additions -----
echo "⚙️ Configuring shell..."
sudo -u $USERNAME bash << 'EOF'
cat >> ~/.bashrc << 'BASHRC'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'

# Show git branch in prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='\[\033[01;32m\]\u@devbox\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

# Projects shortcut
alias proj='cd ~/projects'
BASHRC
EOF
