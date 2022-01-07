#!/bin/bash

#* This file contains my user specific aliases and functions


#* --Exports--
    export WORK="~/hello"

    # export CC=/usr/bin/clang
    # export CXX=/usr/bin/clang++
    export CC=/usr/bin/gcc
    export CXX=/usr/bin/g++

    export HELLO_DIR="~/hello"
    export PYTHON_NIFTY_DIR="$HELLO_DIR/python/Nifty-Python-Programs"

    export PATH=$PATH:~/.local/bin
    
#     CD_LS_BIND=1


#* --Functions--
    reinstall(){
        sudo dnf remove $1 -y
        sudo dnf install $1 -y
    }
    
#     alias cd="_cd"
#     _cd(){
#         if [ CD_LS_BIND ]; then
#             echo did the thing
#             cd "$@"
#             ls
#         else
#             echo didnt do the thing
#             cd "$@"
#         fi
#     }

    # Function which adds an alias to the current shell and to
    # the ~/.bash_aliases file.
    aliasas(){
        local name=$1 value="$2"
        echo alias $name=\'$value\' >>~/bashrc.sh
        eval alias $name=\'$value\'
        alias $name
    }
    
    addalias(){
        local name=$1 value="$2"
        echo alias $name=\'$value\' >>~/bashrc.sh
        eval alias $name=\'$value\'
        alias $name
    }
    
    resetusb(){
        echo $(lsusb | grep $1)
        device=$( lsusb | grep $1 | perl -nE "/\D+(\d+)\D+(\d+).+/; print qq(\$1/\$2)")
        sudo /home/marvin/hello/C/usbreset /dev/bus/usb/$device
    }

    # Loop a command.
    # Usage: loop 10 echo foo
    loop(){
        local count="$1" i;
        shift;
        for i in $(seq 1 "$count"); do
            eval "$@";
        done
    }
    
    file="_file_"
    loopFiles(){
        local path="$1" file recmd;
        shift;
        for file in $(ls "$path"); do
            recmd=$(python -c "import re; c='$'; print(re.sub(r'_file_', f'{c}file', '$*'))")
#             echo "Executing \""$recmd"\""
#             echo "python="
#             python -c "import re; c='$'; print(re.sub(r'_file_', f'{c}f', $*))"
#             echo "recmd='$recmd'"
#             echo "@='$@'"
            eval "$recmd";
        done
    }

    # Subfunction needed by `loop'. I have no idea what this does.
    seq(){
        local lower upper output;
        lower=$1 upper=$2;

        if [ $lower -ge $upper ]; then return; fi
        while [ $lower -le $upper ];
        do
            echo -n "$lower "
            lower=$(($lower + 1))
        done
        echo "$lower"
    }

    # Searches all the currently running processes for the string given
    psgrep(){
        ps -aux | grep $1 | grep -v grep
    }

    die(){
        local pid

        pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
        echo -n "killing $1 (process $pid)..."
        kill -9 $pid
        echo "slaughtered."
    }

    getsizes(){
        for i in ./*; do
            du -sh "$i"
        done
    }

    search(){
        local cwd=$(pwd)
        cd "$1"
        find -name "$2"
        cd "$cwd"
    }
    
    sudosearch(){
        local cwd=$(pwd)
        cd "$1"
        sudo find -name "$2"
        cd "$cwd"
    }
    
    run(){
        cd build
        if [ $? -eq 0 ]; then 
            make -j$(expr $(nproc) + 1)
            if [ $? -eq 0 ]; then
                cd ..
                __PROG=$1
                shift
                ./$__PROG $@
            else
                cd ..
            fi
        fi
    }
    
    build(){
        cd build
        if [ $? -eq 0 ]; then
            make -j$(expr $(nproc) + 1)
            cd ..
        fi
    }
    
    clean(){
        rm -rf ./build/*
        cd build
        cmake .. $@
        cd ..
    }
    
    alias searchall="sudosearch /"


#* --Aliases/Functions to make existing commands nicer--
    alias minicom='minicom -w -t xterm -l -R UTF-8'
    alias dd="sudo dd status=progress "
    alias swapoff="sudo swapoff -a &"
    alias cowsay="/bin/cowsay"
    alias grep="grep -n"
    alias ls='ls --color'
    alias ll='ls -l'
    # alias dir='ls -ba'

#     cat(){
#         cat $@
#         echo '\n'
#     }


#* --Aliases to make cd-ing to places faster--
    alias hello="cd ~/hello"
    alias downloads="cd ~/Downloads "
    alias documents="cd ~/Documents"
    alias assets="cd ~/Documents/assets"


#* --My own aliases--
    alias update="sudo dnf update -y"
    alias restart="source ~/.bashrc"
    alias install="sudo dnf install"
    alias bashrc="kwrite ~/bashrc.sh &"
    alias activate="source ./bin/activate"
    # alias untar="cd ~/Downloads; tar - "
    alias create="cd ./build; clear; make -j17; cd .."
    # Alias run to run the binary that create builds
    # i.e. alias run="./bin/Rithmatist-Debug"
    alias createrun="create; run"
    alias sss="xscreensaver-command -activate"
    #alias mapkeys="xmodmap ~/.xmodmapKeys"
    alias mapkeys="xkbcomp -w0 -I$HOME/.xkb ~/.xkb/keymap/xkbKeyMap $DISPLAY"
    alias getkeys="kwrite ~/.xmodmapKeys &"
    # alias getsizes="for i in ./*; do du -sh "$i"; done"
    alias sudo_getsizes="for i in ./*; do sudo du -sh "${i}"; done"
    alias scanmonitors="xrandr --listmonitors"
    alias usbreset="sudo /home/marvin/hello/C/usbreset"
    alias sl=ls
    alias cd..="cd .."

    # These are used to get the name of the device you just plugged in.
    # Run wodev with the device unpluged
    # Run wdev with the device plugged in
    # Then run dev to get the name of the device
    # alias wodev="ls /dev > /tmp/dev2"
    # alias wdev="ls /dev > /tmp/dev1"
    # alias dev="LINE=$(cmp /tmp/dev1 /tmp/dev2 | cut -d' ' -f 7); TMP=\"${LINE}!\"; TMP=\"${TMP}d\"; sed \"${TMP}\" /tmp/dev1"

    # Delete this whenever the GTK corruption patch ever reaches the mainline kernel
    alias patch="cd ~/Downloads/tmp/; sudo dnf install ./* -y"
    alias update="sudo dnf update -y; cd ~/Downloads/tmp/; sudo dnf install ./* -y"

    # alias texclean='rm -f *.toc *.aux *.log *.cp *.fn *.tp *.vr *.pg *.ky'
    # alias clean='echo -n "Really clean this directory?";
    #         read yorn;
    #         if test "$yorn" = "y"; then
    #         rm -f \#* *~ .*~ *.bak .*.bak  *.tmp .*.tmp core a.out;
    #         echo "Cleaned.";
    #         else
    #         echo "Not cleaned.";
    #         fi'
    # alias h='history'
    # alias j="jobs -l"
    # alias l="ls -l "
    # alias ll="ls -l"
    # alias ls="ls -F"
    # alias pu="pushd"
    # alias po="popd"

    # alias ss="ps -aux"
    # alias dot='ls .[a-zA-Z0-9_]*'
    # alias news="xterm -g 80x45 -e trn -e -S1 -N &"

    # alias c="clear"
    # alias m="more"
    # alias j="jobs"


#* --Aliases of my own programs because I'm to lazy to add them to PATH--
    # alias geodoodle="/usr/bin/python ${HELLO_DIR}/python/GeoDoodle/src/main.py"
    # alias chemaster="python /home/Robert/hello/chemistry\ programs/ChemMaster/src/ChemMaster.py"
    # alias bin="python $PYTHON_NIFTY_DIR/convertToBinary.py"
    # alias binh='python $PYTHON_NIFTY_DIR/convertToBinary.py 0x'
    # alias goaltracker="python $PYTHON_NIFTY_DIR/goalTracker.py"
    # alias treecapitator="python $PYTHON_NIFTY_DIR/minecraft\ treecapitator.py"
    # alias autominer="python $PYTHON_NIFTY_DIR/minecraft\ miner.py"
    # alias randomquote="python $PYTHON_NIFTY_DIR/getQuote.py | cowsay"
    # alias minecraft="cd /home/Robert/Downloads/minecraft-launcher/; ./minecraft-launcher"
    alias minecraftautocopy="/usr/bin/python $PYTHON_NIFTY_DIR/getMinecraftCoords.py"
    alias randomquote="python $PYTHON_NIFTY_DIR/getQuote.py"
    alias define="python $PYTHON_NIFTY_DIR/define.py"
    alias apod="python $PYTHON_NIFTY_DIR/apod.py"
    alias dim="python $PYTHON_NIFTY_DIR/BlackFace.py"
    alias blackface=dim


#* --Misspellings--
    alias mroe=more
    alias pdw=pwd
    alias unmount=umount


#* --Colors--
    alias color="echo -e"

    # Mike Stewart - http://MediaDoneRight.com
    #  Bunch-o-predefined colors.  Makes reading code easier than escape sequences.

    # Reset
    RESET="\033[0m"       # Text Reset

    # Regular Colors
    BLACK="\033[0;30m"        # Black
    RED="\033[0;31m"          # Red
    GREEN="\033[0;32m"        # Green
    YELLOW="\033[0;33m"       # Yellow
    BLUE="\033[0;34m"         # Blue
    PURPLE="\033[0;35m"       # Purple
    CYAN="\033[0;36m"         # Cyan
    WHITE="\033[0;37m"        # White

    # Bold
    BOLD_BLACK="\033[1;30m"       # Black
    BOLD_RED="\033[1;31m"         # Red
    BOLD_GREEN="\033[1;32m"       # Green
    BOLD_YELLOW="\033[1;33m"      # Yellow
    BOLD_BLUE="\033[1;34m"        # Blue
    BOLD_PURPLE="\033[1;35m"      # Purple
    BOLD_CYAN="\033[1;36m"        # Cyan
    BOLD_WHITE="\033[1;37m"       # White

    # Underline
    UNDERLINE_BLACK="\033[4;30m"       # Black
    UNDERLINE_RED="\033[4;31m"         # Red
    UNDERLINE_GREEN="\033[4;32m"       # Green
    UNDERLINE_YELLOW="\033[4;33m"      # Yellow
    UNDERLINE_BLUE="\033[4;34m"        # Blue
    UNDERLINE_PURPLE="\033[4;35m"      # Purple
    UNDERLINE_CYAN="\033[4;36m"        # Cyan
    UNDERLINE_WHITE="\033[4;37m"       # White

    # Background
    BACKGROUND_BLACK="\033[40m"       # Black
    BACKGROUND_RED="\033[41m"         # Red
    BACKGROUND_GREEN="\033[42m"       # Green
    BACKGROUND_YELLOW="\033[43m"      # Yellow
    BACKGROUND_BLUE="\033[44m"        # Blue
    BACKGROUND_PURPLE="\033[45m"      # Purple
    BACKGROUND_CYAN="\033[46m"        # Cyan
    BACKGROUND_WHITE="\033[47m"       # White

    # High Intensty
    INTENSE_BLACK="\033[0;90m"       # Black
    INTENSE_RED="\033[0;91m"         # Red
    INTENSE_GREEN="\033[0;92m"       # Green
    INTENSE_YELLOW="\033[0;93m"      # Yellow
    INTENSE_BLUE="\033[0;94m"        # Blue
    INTENSE_PURPLE="\033[0;95m"      # Purple
    INTENSE_CYAN="\033[0;96m"        # Cyan
    INTENSE_WHITE="\033[0;97m"       # White

    # Bold High Intensty
    INTENSE_BOLD_BLACK="\033[1;90m"      # Black
    INTENSE_BOLD_RED="\033[1;91m"        # Red
    INTENSE_BOLD_GREEN="\033[1;92m"      # Green
    INTENSE_BOLD_YELLOW="\033[1;93m"     # Yellow
    INTENSE_BOLD_BLUE="\033[1;94m"       # Blue
    INTENSE_BOLD_PURPLE="\033[1;95m"     # Purple
    INTENSE_BOLD_CYAN="\033[1;96m"       # Cyan
    INTENSE_BOLD_WHITE="\033[1;97m"      # White

    # High Intensty backgrounds
    INTENSE_BACKGROUND_BLACK="\033[0;100m"   # Black
    INTENSE_BACKGROUND_RED="\033[0;101m"     # Red
    INTENSE_BACKGROUND_GREEN="\033[0;102m"   # Green
    INTENSE_BACKGROUND_YELLOW="\033[0;103m"  # Yellow
    INTENSE_BACKGROUND_BLUE="\033[0;104m"    # Blue
    INTENSE_BACKGROUND_PURPLE="\033[10;95m"  # Purple
    INTENSE_BACKGROUND_CYAN="\033[0;106m"    # Cyan
    INTENSE_BACKGROUND_WHITE="\033[0;107m"   # White




#* --PS1 promt--
    export PS1="\[\033[38;5;34m\]\u\[$(tput sgr0)\]\[\033[38;5;28m\]:\[$(tput sgr0)\]\[\033[38;5;38m\]\w\[$(tput sgr0)\]\[\033[38;5;37m\]/\[$(tput sgr0)\]\[\033[38;5;1m\]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"

    # Various variables you might want for your PS1 prompt
    Time12h="\T"
    Time12a="\@"
    PathShort="\w"
    PathFull="\W"
    NewLine="\n"
    Jobs="\j"

    # This PS1 snippet was adopted from code for MAC/BSD I saw from: http://allancraig.net/index.php?option=com_content&view=article&id=108:ps1-export-command-for-git&catid=45:general&Itemid=96
    # I tweaked it to work on UBUNTU 11.04 & 11.10 plus made it mo' better

    # export PS1=$IBlack$Time12h$Color_Off'$(git branch &>/dev/null;\
    # if [ $? -eq 0 ]; then \
    #   echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
    #   if [ "$?" -eq "0" ]; then \
        # @4 - Clean repository - nothing to commit
    #     echo "'$Green'"$(__git_ps1 " (%s)"); \
    #   else \
        # @5 - Changes to working tree
    #     echo "'$IRed'"$(__git_ps1 " {%s}"); \
    #   fi) '$BYellow$PathShort$Color_Off'\$ "; \
    # else \
    # @2 - Prompt when not in GIT repo
    #   echo " '$Yellow$PathShort$Color_Off'\$ "; \
    # fi)'

    # export GIT_SSL_NO_VERIFY=true

    # git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"


#* --Notes to myself on how to do certain things--
    unifyAudioFiles(){
        rm list.txt
        for f in ./*; do
            echo "file '$f'" >> list.txt
        done
        ffmpeg -f concat -safe 0 -i list.txt -c copy "$1"
        rm list.txt
        # mv "$1" "/run/media/Robert/0702af25-08c4-4c27-b07d-194cb371fd4e/All mp3 Books"
        # mv "$1" ../
    }

    compileDiscs(){
        local range="1 2 3 4 5 6"
        for i in $range; do
            cd "Steven R. Covey - 6 Events CD$i/"
            unifyAudioFiles "../disc-$i.mp3"
            cd ../
            rm -rf "Steven R. Covey - 6 Events CD$i/"
        done
        unifyAudioFiles "/run/media/Robert/0702af25-08c4-4c27-b07d-194cb371fd4e/All mp3 Books/$1"
    }

    hotspot(){
        # param 1 is the name of the hotspot (no spaces, ', or ")
        # param 2 is the hotspot password
        # param 3 is the name of the wifi card to use (w something, usually)

        # nmcli on add type wifi ifname w* con-name $CON_NAME autoconnect yes ssid $CON_NAME
        nmcli on add type wifi ifname $3 con-name $1 autoconnect yes ssid $1
        nmcli con modify $1 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
        nmcli con modify $1 wifi-sec.key-mgmt wpa-psk
        nmcli con modify $1 wifi-sec.psk "${2}"
        nmcli con up $1
    }

    ungif(){
#         local dir=$2
        mkdir "./$2"
        convert -coalesce -monitor "$1" "./$2/%d.png"
    }

    # convert -coalesce ./Unused/${planet}Animation100.gif ./planets/planetAnimations/${planet}Animation/%d.png
    # alias enableFTP="sudo echo Match Group sftp_users >> /etc/ssh/sshd_config; sudo echo ChrootDirectory /data/%u >> /etc/ssh/sshd_config; sudo echo ForceCommand internal-sftp >> /etc/ssh/sshd_config; sudo systemctl restart sshd"


#* --I have no idea what these do--
    # case $- in
    # *i*)	;;
    # *)	return ;;
    # esac

    # # bogus
    # if [ -f /unix ] ; then
    #     alias ls='/bin/ls -CF'
    # else
    #     alias ls='/bin/ls -F'
    # fi

    # hash -p /usr/bin/mail mail

    # if [ -z "$HOST" ] ; then
    #     export HOST=${HOSTNAME}
    # fi

    # HISTIGNORE="[   ]*:&:bg:fg"

    term(){
        TERM=$1
        export TERM
        tset
    }

    xtitle (){
        echo -n -e "\033]0;$*\007"
    }

    # cd(){
    #     builtin cd "$@" && xtitle $HOST: $PWD
    # }

    bold(){
        tput smso
    }

    unbold(){
        tput rmso
    }

    # if [ -f /unix ] ; then
    # clear()
    # {
    #     tput clear
    # }
    # fi

    rot13(){
        if [ $# = 0 ] ; then
            tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
        else
            tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
        fi
    }

    watch(){
            if [ $# -ne 1 ] ; then
                    tail -f nohup.out
            else
                    tail -f $1
            fi
    }

    #       Remote login passing all 8 bits (so meta key will work)
    rl(){
            rlogin $* -8
    }

    function setenv(){
        if [ $# -ne 2 ] ; then
            echo "setenv: Too few arguments"
        else
            export $1="$2"
        fi
    }

    function chmog(){
        if [ $# -ne 4 ] ; then
            echo "usage: chmog mode owner group file"
            return 1
        else
            chmod $1 $4
            chown $2 $4
            chgrp $3 $4
        fi
    }

    # Csh compatability:
    alias unsetenv=unset
    function setenv () {
        export $1="$2"
    }


#* --Things to actually do--
    # xmodmap -e "keycode 105 = Home"
    # xmodmap -e "keycode 90 = End"
    randomquote
    xmodmap ~/.xmodmapKeys
