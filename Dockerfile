FROM ubuntu:focal

USER root 

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Update package lists and install base packages
RUN apt-get update && \
    apt-get install -y \
    git gettext curl make gcc golang python3 python3-dev python3-pip bash luarocks \
    cmake libtool lua5.3 libssl-dev pkg-config unzip binutils clang ripgrep
RUN apt-get install -y nodejs

# Set environment variables for Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Create user with disabled password (security best practice)
RUN useradd -m coderad && \
    echo "coderad:" | chpasswd -e

# Install NeoVim
WORKDIR /home/coderad
RUN git clone https://github.com/neovim/neovim.git && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    cd ..

# Copy NeoVim configuration
COPY . /tmp/src

# Create target directory if it doesn't exist
RUN mkdir -p /home/coderad/.config/ && \
    mkdir -p /home/coderad/.local/share/ && \
    mkdir -p /home/coderad/.local/state/


# Copy files and exclude packer_compiled.lua
RUN cp -a /tmp/src/.config/nvim /home/coderad/.config/ &&\
    cp -a /tmp/src/.local/share/nvim /home/coderad/.local/share/ && \
    cp -a /tmp/src/.local/state/nvim /home/coderad/.local/state/ 

# Set ownership and permissions
RUN chown -R root:root /home/coderad/* && \
    chmod -R 777 /home/coderad/* 
# Set user and working directory for container entrypoint
WORKDIR /home/coderad/.config/nvim

CMD ["nvim"]


