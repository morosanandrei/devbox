#!/bin/bash
set -e

# ===========================================
# Dev Box Bootstrap Script for Hetzner CX32
# User: morosanandrei
# Stack: Node.js, Docker, Docker Compose, Tailscale
# ===========================================

USERNAME="morosanandrei"
NODE_VERSION="22"  # LTS version, change if needed

echo "=========================================="
echo "🚀 Setting up your dev box..."
echo "=========================================="

# ----- 1. System Update -----
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# ----- 2. Install Essential Tools -----
echo "🔧 Installing essential tools..."
apt install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    unzip \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban

# ----- 3. Create User -----
echo "👤 Creating user: $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists, skipping..."
else
    adduser --disabled-password --gecos "" $USERNAME
    usermod -aG sudo $USERNAME
    
    # Allow sudo without password (optional, remove if you want password prompt)
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
    
    # Copy SSH keys from root to new user
    mkdir -p /home/$USERNAME/.ssh
    cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
fi

# ----- 4. Configure Firewall -----
echo "🔥 Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
# Allow common dev ports (adjust as needed)
ufw allow 3000/tcp  # React/Node dev server
ufw allow 5173/tcp  # Vite
ufw allow 8080/tcp  # General dev
echo "y" | ufw enable

# ----- 5. Configure SSH Security -----
echo "🔐 Hardening SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

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

# ----- 8. Install Tailscale -----
echo "🔗 Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

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

# ----- 12. Enable fail2ban -----
echo "🛡️ Enabling fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# ----- Summary -----
echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 What was installed:"
echo "   • User: $USERNAME (with sudo)"
echo "   • Docker + Docker Compose"
echo "   • Node.js v$NODE_VERSION (via Volta) + pnpm + yarn"
echo "   • Tailscale (needs authentication)"
echo "   • UFW Firewall (SSH, 80, 443, 3000, 5173, 8080)"
echo "   • fail2ban"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Reconnect as your user:"
echo "   ssh $USERNAME@YOUR_SERVER_IP"
echo ""
echo "2. Authenticate Tailscale:"
echo "   sudo tailscale up"
echo ""
echo "3. Set your git identity:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your@email.com\""
echo ""
echo "4. Start coding!"
echo "   cd ~/projects"
echo "   git clone your-repo"
echo ""
echo "=========================================="
