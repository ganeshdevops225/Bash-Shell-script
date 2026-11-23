#!/bin/bash
if [ $(id -u) -ne 0 ]
then
    echo "This script must be run as root."
    exit 1
fi

date
uptime
df -hTP |grep -v tmpfs | awk '{print $7, $2, $6}'
df -iP |grep -v tmpfs | awk '{print $7, $2, $6}'
echo "Checking the filesystems are able to read & write"
filesystem=$(df -hT |grep -v tmpfs | awk 'NR>1 {print $7, $2, $6}')
fs=$(awk '{print $1}' <<< "$filesystem")

for i in $fs; do
    if [[ -r "$i" && -w "$i" ]]
    then
        echo " $i is RW "
    elif [[ -r "$i" && ! -w "$i" ]]
    then
        echo "The filesystem $i is readable but not writable."
        mp=$(mount | grep "$i" | awk '{print $6}' | tr -d '()' | tr "," " "| awk '{print $1}')
        if [[ "$mp" == *"ro"* ]]
        then
            echo "The filesystem $i is mounted as read-only."
        fi
    else
        echo "The filesystem $i is not readable."
    fi
done