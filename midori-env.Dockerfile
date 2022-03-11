FROM ubuntu:20.04

# UPDATE AND INSTALL REQUIRED PACKAGES
RUN apt-get update -y && apt-get update -y
RUN apt-get install sudo -y
RUN apt-get install zsh -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install neovim -y

# USER INFO
ARG USERNAME=username\
    PASSWORD=password


# ADD USER
RUN groupadd admin &&\
    useradd -m -G sudo -s /usr/bin/zsh ${USERNAME} &&\
    (echo ${PASSWORD}; echo ${PASSWORD}) | passwd ${USERNAME}


# SET ZSH AS DEFAULT SHELL
SHELL ["/usr/bin/zsh", "-c"]


# SET ENVIRONMENT VARIABLES
ENV HOME=/home/${USERNAME}
ENV ZDOTDIR=${HOME}/.local/etc/zsh\
    ZSH_PLUGINS=${HOME}/.local/share/zsh


# COPY SRC TO CONTAINER HOME
COPY --chown=${USERNAME}:admin src/.local ${HOME}/.local


# HOME DIR CLEANUP AND DIRECTORY STRUCTURE SETUP
WORKDIR ${HOME}
RUN rm .bash* .profile &&\
    echo "\nexport ZDOTDIR=\"\${XDG_CONFIG_HOME}\"/zsh" >> /etc/profile


# ZSH PLUGIN SETUP
RUN git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_PLUGINS}/00_completions
RUN git clone https://github.com/desyncr/auto-ls.git ${ZSH_PLUGINS}/10_auto-ls
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_PLUGINS}/20_autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_PLUGINS}/80_syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-history-substring-search.git ${ZSH_PLUGINS}/90_history-substring-search
RUN curl -sSL https://github.com/clvv/fasd/raw/master/fasd -o /usr/bin/fasd &&\
    chmod +x /usr/bin/fasd
RUN curl -sSL https://github.com/starship/starship/raw/master/install/install.sh -o install.sh &&\
    chmod +x install.sh &&\
    ./install.sh --yes &&\
    rm ./install.sh


# SET DEFAULT USER AND ENTRYPOINT
USER ${USERNAME}
ENTRYPOINT /usr/bin/zsh