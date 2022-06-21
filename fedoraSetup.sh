#!/bin/bash

PS3="Enter number: "
clear

echo "--------------------------"
echo "Fedora Fresh Install Setup"
echo "--------------------------"

options=("Update system" "Check dnf config file" "Enable RPM and flathub" "Install media codecs" "Install additional programs" "Quit")
dnfConfigPath="/etc/dnf/dnf.conf"
dnfEdits=("fastestmirror=True" "max_parallel_downloads=10" "keepcache=True")

select opt in "${options[@]}";
do
    case $opt in

    # updates and upgrades system
    "Update system")
        sudo dnf update -y
        sudo dnf upgrade -y
        printf "\nsystem update successful!"
    ;;

    # edits the dnf config file with QoL improvements
    # always use fastest mirror, increase numnber of downloads at once, and default value Yes
    "Check dnf config file") 
        for val in ${dnfEdits[@]}; 
        do
            if grep -q -F $val $dnfConfigPath;
            then continue
            else
                sudo echo $val >> /etc/dnf/dnf.conf
            fi
        done
        printf "\ndnf config successfully updated!"
    ;;

    # enables rpm package library
    "Enable RPM and flathub")
        sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf group update core

        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        printf "\nrpm and flathub package libraries enabled!"
    ;;

    # installs media codecs not included in initial install
    "Install media codecs")
        sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
        sudo dnf install lame\* --exclude=lame-devel
        sudo dnf group upgrade --with-optional Multimedia -y
        printf "\nmedia codecs successfully installed!"
    ;;

    # installs programs added to this list
    "Install additional programs")
        # vim
        sudo dnf install vim-enhanced -y
        printf "\nvim successfully installed!\n"

        # mpv [celluloid]
        sudo dnf install celluloid
        printf "\nmpv successfully installed!\n"

        # visual studio codium
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        printf '%s\n' \
       '[code]' \
       'name=Visual Studio Code' \
       'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
       'enabled=1' \
       'gpgcheck=1' \
       'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' >> /etc/yum.repos.d/vscode.repo \

        sudo dnf install code -y
        printf "\nvisual studio codium successfully installed!\n"
    ;;

    # quits the program
    "Quit")
        printf "\nclosing program.\n"
        exit
    ;;

    *)
        echo "Invalid selection. Please select a valid option."
    ;;
    esac

done