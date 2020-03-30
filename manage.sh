#!/bin/bash

# cd into the current directory
cd "$(dirname "$0")" || exit 2

# if there are no managed repos, try reading from the config file
if [ -z "$MANAGED" ]; then
    # if there is no config file, use '.managed'
    if [ -z "$CONFIG" ]; then
        CONFIG='.managed'
    fi;

    # load the config file or die
    if [ ! -f "$CONFIG" ]; then
        echo "Can't load configuration file $CONFIG"
        exit 1;
    fi;
    MANAGED=( $( cat "$CONFIG" ) )

# if managed repos were given as an argument, make it an array
else
    MANAGED=( $MANAGED )
fi;

# a function to print the usage and exit
function print_usage() {
    cat << EndOfHelpText
manage.sh
    Runs a docker-compose command over multiple directories. 

Usage: $0 [-s] ls|do|rdo [command ...arguments...]
Arguments:
    -s
        Don't perform any commands, print them to STDOUT instead.
    ls
        List managed directories and print them in green or red if they
        exist or not. 
    do
        Run a "docker-compose" command by iterating over all managed
        directories.
    dor
        Run a "docker-compose" command by iterating over all managed
        directories in reverse. 

Managed repositories are by default read from the space-separated variable
\$MANAGED. In the absence of that the config file \$CONFIG is read, with one
folder per line. The default config file is '.managed'. 
EndOfHelpText
}

# iterate through all managed repos forward
function iterate_forward() {
    for f in "${MANAGED[@]}"; do
        $1 $f
    done
}

# iterate through all managed repos backward
function iterate_backward() {
    for ((i=${#MANAGED[@]}-1; i>=0; i--)); do
        $1 "${MANAGED[$i]}"
    done
}

# check if we're simulating
if [ "$1" == "-s" ]; then
    SIMULATE="true"
    shift;
else
    SIMULATE=""
fi;

# no argument => help
if [ $# -eq 0 ]; then
    print_usage
    exit 0;
fi

# read the command
COMMAND=$1
shift

ARGS=$@

function command_ls() {
    if [ ! $SIMULATE ]; then
        if [ -d "$1" ]; then
            echo -e "\033[0;32m$1\033[0m"
        else
            echo -e "\033[0;31m$1\033[0m"
        fi
    else
        echo $1
    fi
}

function command_do() {
    if [ ! $SIMULATE ]; then
        pushd "$1" || return
        docker-compose $ARGS
        popd
    else
        echo pushd "$1"
        echo docker-compose $ARGS
        echo popd
    fi;
}

# and do the command
case $COMMAND in

  ls)
    iterate_forward command_ls
    ;;

  do)
    iterate_forward command_do
    ;;

  dor)
    iterate_backward command_do
    ;;

  *)
    print_usage
    exit 1
    ;;
esac
