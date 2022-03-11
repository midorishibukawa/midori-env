FROM ubuntu:20.04


# UPDATE AND INSTALL REQUIRED PACKAGES
RUN apt-get update -y && apt-get update -y
RUN apt-get install sudo -y
RUN apt-get install zsh -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install neovim -y

ARG USERNAME=auto\
    PASSWORD=auto\
    USER_ID\
    GROUP_ID

# ADD USER
RUN groupadd admin -g ${GROUP_ID} &&\
    useradd -m -g ${GROUP_ID} -G sudo -s /usr/bin/zsh -u ${USER_ID} ${USERNAME} &&\
    (echo ${PASSWORD}; echo ${PASSWORD}) | passwd ${USERNAME}


# SET ZSH AS DEFAULT SHELL
SHELL ["/usr/bin/zsh", "-c"]


# SET ENVIRONMENT VARIABLES
ENV HOME="/home/${USERNAME}"

ENV _LOCAL="${HOME}/.local"

ENV XDG_CONFIG_HOME="${_LOCAL}/etc"\
    XDG_CACHE_HOME="${_LOCAL}/var/cache"\
    XDG_DATA_HOME="${_LOCAL}/share"\
    XDG_STATE_HOME="${_LOCAL}/var/lib"\
    XDG_BIN_HOME="${_LOCAL}/bin"\
    XDG_LIB_HOME="${_LOCAL}/lib"

ENV STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"\
    STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml"\
    ZDOTDIR="${XDG_CONFIG_HOME}/zsh"\
    _FASD_DATA="${XDG_DATA_HOME}/fasd"\
    ZSH_PLUGINS="${XDG_DATA_HOME}/zsh"\
    HISTFILE="${XDG_STATE_HOME}/zsh/history"

# HOME DIR CLEANUP AND DIRECTORY STRUCTURE SETUP
WORKDIR "${HOME}"
RUN rm .bash* .profile

USER root

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

# COPY SRC TO CONTAINER HOME
COPY --chown=${USERNAME}:admin src/.local ${_LOCAL}

USER ${USERNAME}

ENTRYPOINT /usr/bin/zsh