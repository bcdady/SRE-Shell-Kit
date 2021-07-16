#!/bin/zsh
echo $0

function confirm {

    if [ "$1" ]; then _prompt="$1"; else _prompt="Are you sure"; fi
    _prompt="$_prompt [y/n] ?"

  # Loop forever until the user enters a valid response (Y/N or Yes/No).
    read -rs -k 1 "$_prompt " _response
    while true; do
        case "${_response}" in
            [Yy][Ee][Ss]|[Yy] ) # Yes or Y (case-insensitive).
                return true
            ;;
            [Nn][Oo]|[Nn] )  # No or N.
                return false
            ;;
            * ) # Anything else (including a blank) is invalid.
            ;;
        esac
    done
}

# PROCEED=$(confirm "Is it time to update Homebrew?")
# echo "PROCEED is $PROCEED"

# Thanks to both http://onyxmueller.net/2018/08/31/scheduling-commands-with-cron-on-your-mac/
# and https://medium.com/@waxzce/keeping-macos-clean-this-is-my-osx-brew-update-cli-command-6c8f12dc1731
BREW_UPDATE=true
BREW_STATUS_FILE="$HOME/.brew_updated"
# Look for a file with a recent date, where latest status of HomeBrew update can be shared across shell environments
# If not found, or older than 3 days, then set BREW_UPDATE == true

#if [ $PROCEED = 1 ]; then
    # Check file exists
    if [ -f $BREW_STATUS_FILE ]; then
        # get today's date for reference
        TODAY="$(date -j +%Y%m%d)"
        #echo "Today is $TODAY"
        # check file modified date
        BREWMOD=$(date -j -r $BREW_STATUS_FILE +"%Y%m%d")
        #echo "Homebrew was last updated on $BREWMOD"

        UPDATE_DATE=$(date -j -v+10d -f "%Y%m%d" "$BREWMOD" +"%Y%m%d")
        #echo "UPDATE_DATE is $UPDATE_DATE"
        #calculate if $TODAY is at or past n days since $BREWMOD
        if test $TODAY -lt $UPDATE_DATE; then
            #echo "BREW_UPDATE=false"
            BREW_UPDATE=false
        fi
    #else
    #    echo "File not found!" >&2
    fi
#fi

echo "Homebrew was last updated on $(date -j -f "%Y%m%d" "$BREWMOD" +"%m-%d-%y")"
#echo "BREW_UPDATE is $BREW_UPDATE"

if [ $BREW_UPDATE = true ]; then
    echo " ! Updating Homebrew (and casks)"
    brew update | tee -a $BREW_STATUS_FILE
    brew upgrade | tee -a $BREW_STATUS_FILE
    brew cleanup -s | tee -a $BREW_STATUS_FILE
    brew upgrade --cask | tee -a $BREW_STATUS_FILE # brew cask upgrade

    # now diagnostics
    #brew doctor
    #brew cask doctor

    #brew missing
    
    # Create / update the file to declare that HomeBrew was recently updated
    #echo "touch $BREW_STATUS_FILE"
    #touch -fm $BREW_STATUS_FILE
else
    echo "Homebrew was already updated recently"
fi
