# docker-compose-manage-sh

```
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
```
