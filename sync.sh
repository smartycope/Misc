#!/bin/bash


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


# Functions

usage() { echo "Usage: $0 use -c for commiting, -q for quiet" 1>&2; exit 1; }

ensureExists(){
    if [ -e "$1" ]; then
        return
        # echo "$1" exists!
    else
        mkdir "$1"
    fi
}

echoclr(){
    # echo -e -n $1
    echo -e $@
    echo -e -n $RESET
}

log(){
    echoclr $BLUE $@
    # echo -e $@
}



# Make sure the project, working, and backup directories are all there
projectsdir=~/hello;
# workingdir=/tmp/syncFiles;
workingdir=$projectsdir;
backupsdir=~/.syncBackups;
backupdir="$backupsdir/$(date)";
log "Backup directory set as" $backupdir

# gitUsername="smartycope@gmail.com"
gitUsername="smartycope"

libsPath=$projectsdir
miscPath=$workingdir

libs=$libsPath/Libs
misc=$miscPath/Misc

installLibsScript=$libs/installLibs.sh
commitmsg="Standard Sync at $(date) from $USER"

# repos[<git link>]=<where it should be stored>
declare -A repos
repos["https://github.com/smartycope/Libs.git"]="$libsPath"
repos["https://github.com/smartycope/Boilerplate.git"]="$projectsdir"
repos["https://github.com/smartycope/Misc.git"]="$miscPath"
repos["https://github.com/smartycope/MathTranspiler.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/MindustryCompiler.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/2DKSP.git"]="$projectsdir/GDScript"
# repos["https://github.com/smartycope/Nifty-Python-Programs.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/Sonix.git"]="$projectsdir/C++"
# repos["https://github.com/smartycope/Oneko2.0.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/Blinkus-and-Boopus.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/Submission.git"]="$projectsdir/GDScript"
# repos["https://github.com/smartycope/Lunar-Lander.git"]="$projectsdir/python"
# repos["https://github.com/smartycope/AntAI.git"]="$projectsdir/python"

# syncfiles[<where to find it after cloning>]=<where it needs to go>
declare -A syncfiles
syncfiles["$misc/CustomGlobalSnippets.code-snippets"]="${HOME}/.config/VSCodium/User/snippets/CustomGlobalSnippets.code-snippets"
syncfiles["$misc/EasyMindustryCodeSnippets.code-snippets"]="${HOME}/.config/VSCodium/User/snippets/EasyMindustryCodeSnippets.code-snippets"
syncfiles["$misc/VSCodiumKeybindings.json"]="${HOME}/.config/VSCodium/User/keybindings.json"
syncfiles["$misc/VSCodiumSettings.json"]="${HOME}/.config/VSCodium/User/settings.json"
# syncfiles["$misc/chromiumExtensions"]="${HOME}/.config/chromium/Webstore Downloads"
syncfiles["$misc/chromiumBookmarks"]="${HOME}/.config/chromium/Default/Bookmarks"
syncfiles["$misc/chromiumPreferences"]="${HOME}/.config/chromium/Default/Preferences"
# syncfiles["$misc/keymapSetup"]="${HOME}/.xkb"
syncfiles["$misc/bashrc.sh"]="${HOME}/bashrc.sh"
syncfiles["$misc/sync.sh"]="${HOME}/sync.sh"
syncfiles["$misc/startup.sh"]="${HOME}/startup.sh"
syncfiles["$misc/globalGitignore"]="${HOME}/.globalGitignore"




# Make sure everything exists
ensureExists "$projectsdir"
ensureExists "$workingdir"
ensureExists "$backupsdir"
ensureExists "$backupdir"


# First get command line parameters
COMMIT=""
quiet=""
nuke=0

options=$(getopt -l "commit,quiet,nuke" -o "hq" -a -- "$@")
eval set -- "$options"

while true; do
case $1 in
    -c|--commit)
        COMMIT="$commitmsg";;
    -q|--quiet)
        quiet="-q";;
    --nuke)
        nuke=1;;
    --)
        shift
        break;;
    *)
        echo "Unrecognized arguement: $1"
        usage;;
esac
shift
done


# while getopts c:commit:q:quiet: flag; do
#     # if [ $OPTARG ]; then
#     #     case "${flag}" in
#     #         c) COMMIT=${OPTARG};;
#     #         commit) COMMIT=${OPTARG};;
#     #         q) quiet="-q";;
#     #         quiet) quiet="-q";;
#     #     esac
#     # else
#         case "${flag}" in

#         esac
#     # fi
# done

# Make sure we're working from the right place
cd ~/

githubToken=$(cat .githubToken)

if [ "${COMMIT}" ]; then
    log Copying all the files back to their repos...
    for file in "${!syncfiles[@]}"; do
        dest="${syncfiles[$file]}"
        cp -r $dest "$file"
    done

    log Commiting repos...
    for repo in "${!repos[@]}"; do
        dest="${repos[$repo]}"
        # This just gets the name of the repo from the link by dropping the .git at the end
        base=$(basename $repo)
        size=$(echo -n "$base" | wc -m)
        name=${base:0:$(($size-4))}
        log "Commiting $name"
        # If the repo exists
        if [[ -d "$dest/$name" ]]; then
            cd "$dest/$name"
            # git rm -r --cached

            # echo base: $base
            # echo size: $size
            # echo name: $name
            # echo repo: $repo
            # echo dest: $dest
            # echo commit: $COMMIT
            # echo quiet: $quiet

            git add .
            git commit -m "${COMMIT}" ${quiet}

            drophttps=${repo:8}
            url="https://$gitUsername:$gitToken@$drophttps"
            echo url: $url

            # Most use master, a couple use main
            git push $url master
            if [ $? -ne 0 ]; then
                git push url main
                if [ $? -ne 0 ]; then
                    echoclr $RED "Failed to pull from $repo into $dest/$name using the url '$url'."
                    # exit 1
                fi
            fi
        else
            echoclr $RED "It seems that $dest/$name doesn't exist. Have you synced yet?"
            exit 1
        fi
    done


else
    # Double check that we actually want to nuke everything
    if [ "${COMMIT}" ]; then
        read -p " Are you sure you want to nuke all the repositories (y/n)?" choice
        case "$choice" in
          y|Y ) ;;
          n|N )
            echo Exiting...
            exit 0;;
          * ) echo "invalid";;
        esac
    fi

    log "Backing up everything we're about to overwrite..."
    for file in "${!syncfiles[@]}"; do
        dest="${syncfiles[$file]}"
        what="$backupdir/$(basename "$file")"
        ensureExists "$what"
        cp -r $dest "$what"
    done

    log Fetching repos...
    for repo in "${!repos[@]}"; do
        dest="${repos[$repo]}"
        # This is intense.
        # This just gets the name of the repo from the link by dropping the .git at the end
        base=$(basename $repo)
        size=$(echo -n "$base" | wc -m)
        name=${base:0:$(($size-4))}

        echo "$dest/$name"
        if [ $nuke -ne 0 ]; then
            log Nuking and cloning $dest/$name
            cd "$dest"
            rm -rf "$dest/$name"
            git clone "$repo"
        else
            # If the repo exists
            log "Fetching $name into $dest"
            if [[ -d "$dest/$name" ]]; then
                cd "$dest/$name"
                git pull origin master $quiet
                if [ $? -ne 0 ]; then
                    git pull origin main $quiet
                    if [ $? -ne 0 ]; then
                        echoclr $RED "Failed to pull from $repo. Have you committed yet?"
                        exit 1
                    fi
                fi
            else
                cd "$dest"
                git clone "$repo"
            fi
        fi
    done
    cd ~/

    log Replacing everything...
    for file in "${!syncfiles[@]}"; do
        dest="${syncfiles[$file]}"
        cp -r "$file" "$dest"
        # mv "$file" "$dest"
    done

    echo Installing...
    chmod +x $installLibsScript
    $installLibsScript

    git config --global core.excludesfile ${syncfiles["$misc/globalGitignore"]}
fi

# log Removing the working directory...
# rm -rf $workingdir

log Done!

# echo Overwriting old symlinks:
# read -p "Continue (y/n)?" choice
# case "$choice" in
#   y|Y ) echo "yes";;
#   n|N ) echo "no";;
#   * ) echo "invalid";;
# esac

# if [[ -f <file> ]]; then
#     echo "<file> exists on your filesystem."
# fi

# https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html

# Extracts $length characters of substring from $string at $position.
# ${string:position:length}

# length of a string:
# ${#<var>}

# This is intense.
# This just gets the name of the repo from the link by dropping the .git at the end
# name=$(basename $repo)
# ${$name:0:$(($(#name)-4))}


# bro checovic is a good linear algebra teacher
# I need to buy a logic analyzer
# final project is graded on creativity, techinical merit and professionalism
# board support package = bootloader
# his name is Jacob
# to the right is dallin


# DO THIS

# touch ~/.gitignore_global
# Add the file to the Git configuration:
# git config --global core.excludesfile ~/.gitignore_global