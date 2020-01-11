FROM fedora:27

ENV LANG=en_US.utf8

RUN dnf -y install make unzip which perl git automake autoconf readline-devel ncurses-devel openssl-devel libyaml-devel libxslt-devel libffi-devel libtool unixODBC-devel procps
RUN rm -rf ~/.asdf; git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
RUN echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
RUN echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

RUN ~/.asdf/bin/asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN ~/.asdf/bin/asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

ENV PATH=$PATH:/root/.asdf/bin:/root/.asdf/shims
ENV KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"

RUN asdf install erlang 22.2.1
RUN asdf install elixir 1.9.4
RUN asdf reshim erlang
RUN asdf reshim elixir
RUN asdf global erlang 22.2.1
RUN asdf global elixir 1.9.4

RUN mix local.hex --force && mix local.rebar --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force
