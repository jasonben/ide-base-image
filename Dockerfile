FROM alpine:3.18

ARG \
  IDE_BASE_IMAGE

ENV \
  IDE_USER=ide \
  IDE_HOME=/jasonben/ide

ENV \
  IDE_BASE_IMAGE=${IDE_BASE_IMAGE} \
  HOME=$IDE_HOME \
  TERM=tmux-256color \
  LANG=C.UTF-8 \
  SHELL=/bin/zsh \
  EDITOR=vim \
  GOPATH=$IDE_HOME/go \
  GEM_HOME=$IDE_HOME/bundle \
  PNPM_HOME=$IDE_HOME/pnpm

ENV \
  BUNDLE_APP_CONFIG="$GEM_HOME" \
  BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  GOPATH_BIN="$GOPATH/bin"

ENV \
  PATH="$PNPM_HOME:$BUNDLE_BIN:$GOPATH_BIN:$PATH"

# hadolint ignore=DL4006
RUN \
  echo "%%%%%%%%%%%%%%===> System: Installing build deps" && \
  apk add --no-cache \
  autoconf \
  automake \
  binutils-gold \
  build-base \
  ca-certificates \
  ffmpeg \
  file \
  g++ \
  gcc \
  gcompat \
  glib-dev \
  gnupg \
  jpeg \
  libffi-dev \
  libgcc \
  libgit2 \
  libjpeg-turbo-dev \
  libpq \
  libstdc++ \
  libtool \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  make \
  mariadb-dev \
  musl-dev \
  nasm \
  ncurses \
  pacman \
  pkgconf \
  poppler \
  postgresql-client \
  postgresql-dev \
  py3-pip \
  py3-pygit2 \
  py3-setuptools \
  py3-wheel \
  python3-dev \
  ruby-dev \
  sqlite-dev \
  tiff \
  tzdata \
  vips-dev \
  yaml-dev \
  zlib \
  zlib-dev \
  && \
  echo "%%%%%%%%%%%%%%===> System: Installing frequently used apps" && \
  apk add --no-cache \
  atuin \
  bash \
  bat \
  bind-tools \
  broot \
  btop \
  ctags \
  curl \
  delta \
  doas \
  docker \
  docker-cli-buildx \
  docker-cli-compose \
  doctl \
  exa \
  fd \
  fzf \
  git \
  github-cli \
  gum \
  hcloud \
  highlight \
  httpie \
  jq \
  less \
  libqalculate \
  miller \
  ncdu \
  nodejs \
  npm \
  onefetch \
  openssh-client \
  python3 \
  ranger \
  ripgrep \
  rsync \
  ruby \
  shadow \
  shellcheck \
  shfmt \
  starship \
  tailscale \
  the_silver_searcher \
  tmux \
  tree \
  unzip \
  util-linux-misc \
  vim \
  wget \
  yarn \
  zoxide \
  zsh \
  && \
  apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
  go \
  rtx \
  && \
  echo "%%%%%%%%%%%%%%===> System: Done installing apps" && \
  echo "%%%%%%%%%%%%%%===> System: Configuring settings" && \
  echo "%%%%%%%%%%%%%%===> System: Changing timezone to US/Central" && \
  cp /usr/share/zoneinfo/US/Central /etc/localtime && \
  echo "US/Central" > /etc/timezone \
  && \
  echo "%%%%%%%%%%%%%%===> System: Creating new user: '$IDE_USER'" && \
  addgroup -g 1000 -S $IDE_USER && \
  mkdir -p $IDE_HOME && \
  adduser -D -u 1000 -G $IDE_USER -S $IDE_USER -h $IDE_HOME && \
  usermod -s /bin/zsh $IDE_USER && \
  echo "$IDE_USER:password" | chpasswd && \
  chown -R "$IDE_USER:$IDE_USER" $IDE_HOME && \
  mkdir -p /etc/doas.d && \
  echo "permit nopass $IDE_USER as root" > /etc/doas.d/doas.conf && \
  chown -c root:root /etc/doas.d/doas.conf && \
  chmod -c 0400 /etc/doas.d/doas.conf && \
  echo "%%%%%%%%%%%%%%===> Ruby: Ignore ri and rdoc" && \
  touch "$IDE_HOME/.gemrc" && \
  echo 'gem: --no-document' >> "$IDE_HOME/.gemrc" && \
  echo "%%%%%%%%%%%%%%===> Tmux: Generate tmux-256color TERM" && \
  infocmp -x tmux-256color > tmux-256color.src && \
  /usr/bin/tic -x tmux-256color.src

USER $IDE_USER
WORKDIR $IDE_HOME

RUN \
  echo "%%%%%%%%%%%%%%===> Vim: Installing vim-plug" && \
    curl -fLo ~/.vim/autoload/plug.vim \
      --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Configuring shell" && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing ohmyzsh" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing powerlevel10k prompt" && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      $IDE_HOME/.oh-my-zsh/custom/themes/powerlevel10k \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing auto suggestions" && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
      $IDE_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing syntax highlighting" && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
      $IDE_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing zsh-fzf-history-search" && \
    git clone --depth=1 https://github.com/joshskidmore/zsh-fzf-history-search.git \
      $IDE_HOME/.oh-my-zsh/custom/plugins/zsh-fzf-history-search \
    && \
  echo "%%%%%%%%%%%%%%===> Zsh: Installing base16-shell" && \
    git clone --depth=1 https://github.com/base16-project/base16-shell.git \
      $IDE_HOME/.base16-shell \
    && \
  echo "%%%%%%%%%%%%%%===> System: Installing lazydocker" && \
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

RUN \
  echo "%%%%%%%%%%%%%%===> Go: Configuring folders" && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
          && \
  echo "%%%%%%%%%%%%%%===> Go: Installing packages" && \
  echo "%%%%%%%%%%%%%%===> Go: jqp" && \
    go install github.com/noahgorstein/jqp@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: sqls" && \
    go install github.com/lighttiger2505/sqls@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: gron" && \
    go install github.com/tomnomnom/gron@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: glow" && \
    go install github.com/charmbracelet/glow@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Go: usql" && \
    go install -tags most github.com/xo/usql@v0.15.6 \
          && \
  echo "%%%%%%%%%%%%%%===> Go: ultimate plumber" && \
    go install github.com/akavel/up@master \
          && \
  echo "%%%%%%%%%%%%%%===> Go: lazygit" && \
    go install github.com/jesseduffield/lazygit@latest \
          && \
  echo "%%%%%%%%%%%%%%===> Random: Install has command" && \
    git clone https://github.com/kdabir/has.git && cd has && doas make install && cd .. && rm -rf has \
  && \
  echo "%%%%%%%%%%%%%%===> Ruby: Configure" && \
    mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME" && chown -R $IDE_USER:$IDE_USER "$GEM_HOME" \
          && \
  echo "%%%%%%%%%%%%%%===> Ruby: Installing packages" && \
    gem install --no-document \
      amazing_print \
      bundler \
      colorls \
      prettier_print \
      pry \
      rubocop \
      rubocop-rspec \
      rubocop-rails \
      rubocop-rake \
      solargraph \
      solargraph-rails \
      standardrb \
      syntax_tree \
      syntax_tree-haml \
      syntax_tree-rbs \
      tmuxinator \
  && \
  echo "%%%%%%%%%%%%%%===> Node: Installing packages" && \
    doas npm install -g pnpm && \
    pnpm add -g \
      @prettier/plugin-ruby \
      bash-language-server \
      chokidar-cli \
      dockerfilelint \
      gzip-size-cli \
      heroku \
      np \
      prettier \
      prettier-plugin-autocorrect \
      prettier-plugin-erb \
      prettier-plugin-jinja-template \
      prettier-plugin-pkg \
      prettier-plugin-prisma \
      prettier-plugin-sh \
      prettier-plugin-sql \
      rename-cli@beta \
      sql-formatter \
      typescript \
      typescript-language-server \
      viewport-list-cli \
      vim-language-server \
      vscode-html-languageserver-bin \
    && \
  echo "%%%%%%%%%%%%%%===> Python: Installing packages" && \
    pip3 install --upgrade --no-cache-dir pip setuptools && \
    pip3 install --user --no-cache-dir \
      black \
      pynvim \
      python-language-server \
      nginx-language-server \
      tldr \
    && \
    go clean -cache && \
    doas rm -rf "$GOPATH/src" && \
    doas rm -rf "$GOPATH/pkg" && \
    doas rm -rf "$IDE_HOME/.cache"

ENV \
  IDE_BASE_IMAGE=${IDE_BASE_IMAGE}
