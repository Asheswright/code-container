FROM archlinux:base-devel

# Set common environment variables
ENV LANG=en_AU.UTF-8
ENV LANGUAGE=en_AU.UTF-8

# Password for ssh
ENV USER_PASSWORD=archssh5678

# Install core
RUN pacman -Syu --noconfirm openssh \
    # Utils
    base-devel mc htop iotop ncdu zip nano vim fzf wget unzip tmux git cmake lazygit fd ripgrep tree-sitter-cli neovim github-cli age fastfetch curl \
    nodejs npm python3 ffmpeg gcc libffi procps uv rust go go-tools\
    nss atk at-spi2-core cups libdrm libxkbcommon mesa pango cairo alsa-lib \
    # Net utils
    inetutils dnsutils iperf nmap \
    # Install Extras
    gum eza bat asciinema \
    #Install fonts
    nerd-fonts \
    # Utils
    lychee pandoc-cli typst d2 jq yq yt-dlp ddgr \
    # Tools
    obsidian opencode

# install helper and add a user for it
ADD deploy/add-aur.sh /root
RUN bash /root/add-aur.sh "aur" "paru"

USER aur

#install aur packages now there is a user setup.
RUN paru -Sy --noconfirm qwen-code-bin
RUN paru -Sy --noconfirm forgejo-mcp-bin
RUN paru -Sy --noconfirm kimi-code

USER root

# Deleting keys
RUN rm -rf /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa* /etc/ssh/ssh_host_ed25519* /etc/ssh/ssh_host_rsa*

# sudo access for arch user
RUN echo "arch ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
#RUN echo "arch ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/arch \
#    && chmod 0440 /etc/sudoers.d/arch

RUN useradd -m -d /home/arch -s /bin/bash -U arch
RUN echo 'arch:arch' | chpasswd

#Create the home structure
COPY deploy/home-scripts /home/arch
RUN chown -R arch:arch /home/arch

USER arch
WORKDIR /home/arch
#RUN source .bashrc

# Prepare SSH configuration
RUN mkdir -p /home/arch/.ssh \
    && touch /home/arch/.ssh/known_hosts

# Preload GitHub host keys (non-interactive Git usage)
RUN ssh-keyscan -T 5 github.com 2>/dev/null >> /home/arch/.ssh/known_hosts || true

#RUN git clone https://github.com/LazyVim/starter /home/arch/.config/nvim \
#    && rm -rf /home/arch/.config/nvim/.git


RUN mkdir -p /home/arch/workspace

#RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | sed 's/npx playwright/echo npx playwright/' | bash

USER root

COPY deploy/entrypoint /
RUN chmod +x /entrypoint.sh

EXPOSE 22/tcp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
