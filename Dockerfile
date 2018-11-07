FROM ubuntu

MAINTAINER Chip Wolf <hello@chipwolf.uk>

ENV HOME /root
ENV LANG en_US.UTF-8
ENV TERM xterm-256color

RUN apt-get update && \
    apt-get install -y \
        zsh git tmux vim curl sudo exuberant-ctags make build-essential \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        wget curl llvm libncurses5-dev libncursesw5-dev xz-utils libffi-dev \
        liblzma-dev gnupg

ENV USER chip
ENV DIRPATH /home/$USER
ENV HOME $DIRPATH
RUN useradd $USER \
    && usermod -aG sudo $USER \
    && usermod -s /bin/zsh $USER \
    && mkdir $DIRPATH
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/00-$USER
WORKDIR $DIRPATH
RUN chown -R $USER:$USER $DIRPATH
USER chip

RUN git clone --recursive git://github.com/ChipWolf/etc.git $DIRPATH/.etc
RUN  $DIRPATH/.etc/link.sh/link.sh -u $DIRPATH/.etc/.link.conf -b \
    && $DIRPATH/.etc/link.sh/link.sh -u $DIRPATH/.etc/.link.conf -wf \
    && sed -i "s/#{loadavg}.*$/#{loadavg} \'/g" $DIRPATH/.tmux.conf.local \
    && sed -i "s/#(\$HOME\/.etc\/scripts\/spotinfo.sh ) | //" $DIRPATH/.tmux.conf.local \
    && rm -rf $DIRPATH/.etc.bak
COPY 00-bullettrain.zsh $DIRPATH/.zsh/zsh-os-conf/local-pre/00-bullettrain.zsh

RUN curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | sudo -E bash -

RUN git clone git://github.com/yyuu/pyenv.git $DIRPATH/.pyenv \
    && git clone https://github.com/yyuu/pyenv-virtualenv.git $DIRPATH/.pyenv/plugins/pyenv-virtualenv \
    && echo "eval \"\$(pyenv init -)\"" >> $DIRPATH/.zshrc \
    && echo "eval \"\$(pyenv virtualenv-init -)\"" >> $DIRPATH/.zshrc

ENV PYENV_ROOT $DIRPATH/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN sudo apt-get install -y libssl-dev

RUN pyenv install 2.7.15 \
    && pyenv install 3.7.1 \
    && pyenv install pypy2.7-6.0.0 \
    && pyenv install pypy3.5-6.0.0

RUN pyenv global 3.7.1
RUN pip install -U pip tox

RUN sudo npm install -g try-thread-sleep \
    && sudo npm install -g serverless --ignore-scripts spawn-sync

CMD ["zsh"]

