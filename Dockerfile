FROM ubuntu

MAINTAINER Chip Wolf <hello@chipwolf.uk>

ENV HOME /root
ENV LANG en_US.UTF-8
ENV TERM xterm-256color

RUN apt-get update \
    && apt-get install -y zsh git tmux vim curl sudo exuberant-ctags

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

CMD ["zsh"]

