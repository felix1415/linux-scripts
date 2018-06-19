#!/bin/bash
set -eu

#save our current directory and change to the temp directory
current_dir=$(pwd)
firefox_install_dir="/opt/firefox"
firefox_dated_destination="firefox_$(echo `date '+%d_%m_%Y_%H_%M_%S'`)"
firefox_tar="${firefox_dated_destination}.tar.bz2"

#get latest, GB, linux64 firefox as a tar file from Mozilla
firefox_remote_location="https://download.mozilla.org/?\
product=firefox-latest-ssl&\
os=linux64&\
lang=en-GB"

cd /tmp/
wget "$firefox_remote_location" -O "$firefox_tar" -L
sudo mv "$firefox_tar" "/opt/${firefox_tar}"
cd /opt/

#kill all current firefox processes
killall firefox

#remove symlink or move current firefox to firefox.backup, else error.
if [[ -L "$firefox_install_dir" ]]
then
    #remove symbolic link
    sudo rm -f "$firefox_install_dir"
    echo "removed symlink $firefox_install_dir"
elif [[ -d "$firefox_install_dir" ]]
then
    #move directory to back up
    sudo mv "$firefox_install_dir" "${firefox_install_dir}.backup"
    echo "moved $firefox_install_dir to ${firefox_install_dir}.backup"
else
    echo "$firefox_install_dir is not a directory or symbolic link directory"
    exit 1;
fi

# untar firefox and move firefox directory to firefox_current_date
sudo tar xf "$firefox_tar"
sudo mv "$firefox_install_dir" "$firefox_dated_destination"

#soft link the firefox_current_date to firefox, remove the downloaded tar file
sudo ln -s "$firefox_dated_destination" "$firefox_install_dir"
sudo rm -f "$firefox_tar"

#restart firefox daemonised and go back to the current directory
/opt/firefox/firefox &> /dev/null &
cd $current_dir
