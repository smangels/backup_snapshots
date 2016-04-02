#!/bin/bash



#
#   Make your changes here
#
NR_SNAPSHOTS=31
SNAPSHOTS=""
BACKUP_SRC="/home/bastian/Dropbox/Vetekornet/"


#
#   Do not edit below this line
#
#   ###########################################################################

FLAG_INIT=false
FLAG_BACKUP=false
FLAG_DEBUG=false
FOLDER_BACKUP=""
FOLDER_SOURCE=""


function _my_exit()
{
    if [[ $? -gt 0 ]]; then
        rm -rf backup.*
    fi
}


function print_debug()
{
    if $FLAG_DEBUG; then
        echo "DBG : => $1"
    fi
}

function perror()
{
    echo "ERROR : $1"
}


function _help()
{
    local _BASENAME=$(basename $0)
    echo
    echo " usage: ${_BASENAME}"
    echo
    echo "  Mandatory:"
    echo "  ----------"
    echo "   -I                 init a backup system"
    echo "   -S   FOLDER        source folder"
    echo "   -B   FOLDER        backup folder"
    echo "   -N   NR            number of rotating snapshots to take"
    echo
    echo "  Optional:"
    echo "  ---------"
    echo "   -v                 verbose mode"
    echo
}


function check_arguments()
{
    if [[ -n $FOLDER_BACKUP ]]; then
        if [[ ! -d $FOLDER_BACKUP ]]; then
            perror "Could not find backup folder [$FOLDER_BACKUP]"
            return 1
        fi
    fi
    if [[ -n $FOLDER_SOURCE ]]; then
        if [[ ! -d $FOLDER_SOURCE ]]; then
            perror "Could not find source folder [$FOLDER_SOURCE]"
            return 1
        fi
    fi
    return 0
}


while getopts ":IhvB:S:" opt; do
    case $opt in
        I)
            echo "-I init a backup system"
            FLAG_INIT=true
            ;;
        S)
            FOLDER_SOURCE=${OPTARG}
            ;;
        B)
            FOLDER_BACKUP=${OPTARG}
            ;;
        h)
            _help
            exit 0
            ;;
        v)
            FLAG_DEBUG=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


if ! check_arguments; then
    exit 1
fi


trap _my_exit INT




exit 0



for i in $(seq $NR_SNAPSHOTS -1 1); do
    _ID=$(printf "%02d" $i)
    SNAPSHOTS="$SNAPSHOTS backup.${_ID}"
done


#
#   Ensure that backup source directory will be available
#
if [[ ! -d ${BACKUP_SRC} ]]; then
    echo "ERROR. can not find source directory"
    exit 1
fi

#
#   Create backup folder of not available
#
for snap in $SNAPSHOTS; do
    if [[ ! -d $snap ]]; then
        mkdir $snap
    fi
done


#
#   Lets rotate backups
#
CNTR=0
for snap in ${SNAPSHOTS}; do
    if [[ ${CNTR} -lt 1 ]]; then
        rm -rf ${snap}
    else
        mv ${snap} ${TARGET}
    fi
    TARGET=${snap}
    let "CNTR+=1"
done

rsync -a --delete --link-dest=../backup.02 ${BACKUP_SRC}  backup.01/
    

exit 0


# EOF