# dotfiles

Personal dev environment configuration and bootstrap scripts.

## Quick Start

### New Server Setup (Hetzner/DO/etc.)

```bash
# SSH as root, then run:
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/bootstrap.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### After Bootstrap

```bash
# 1. Reconnect as your user
ssh morosanandrei@YOUR_SERVER_IP

# 2. Setup Tailscale
sudo tailscale up

# 3. Set git identity
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 4. (Optional) Start dev services
cd ~/dotfiles/docker
docker compose up -d
```

## What's Included

### Scripts

| Script | Description |
|--------|-------------|
| `scripts/bootstrap.sh` | Full server setup (user, Docker, Volta, Tailscale) |

### Shell

- `.bashrc` - Main bash configuration
- `.aliases` - Command shortcuts
- `.exports` - Environment variables

### Docker

Common development services:

- **PostgreSQL** (port 5432)
- **Redis** (port 6379)
- **Adminer** (port 8081) - DB web UI

```bash
cd docker
docker compose up -d        # Start all
docker compose up -d postgres  # Start specific service
docker compose down         # Stop all
```

### Git

- `.gitconfig` - Git configuration with useful aliases

## Structure

```
dotfiles/
├── README.md
├── scripts/
│   └── bootstrap.sh        # Server bootstrap
├── shell/
│   ├── .bashrc             # Bash config
│   ├── .aliases            # Aliases
│   └── .exports            # Environment variables
├── git/
│   └── .gitconfig          # Git config
├── docker/
│   └── docker-compose.yml  # Dev services
└── config/
    └── .vimrc              # Vim config
```

## Applying Shell Configs (on existing machine)

```bash
# Symlink configs
ln -sf ~/dotfiles/shell/.bashrc ~/.bashrc
ln -sf ~/dotfiles/shell/.aliases ~/.aliases
ln -sf ~/dotfiles/shell/.exports ~/.exports
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/config/.vimrc ~/.vimrc

# Reload
source ~/.bashrc
```

## Customization

1. Fork this repo
2. Update `scripts/bootstrap.sh`:
   - Change `USERNAME` variable
   - Add/remove packages as needed
3. Modify shell configs to your liking
4. Update `docker/docker-compose.yml` with services you need

## License

MIT - Do whatever you want with it.
