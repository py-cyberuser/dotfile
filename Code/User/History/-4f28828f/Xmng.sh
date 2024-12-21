#!/bin/bash
source ./packages.sh

green='\033[0;32m'
no_color='\033[0m'

# 最好别加noconfirm(arch manpage上所说)，加了也行

dialog_main() {
    cmd=(dialog --clear --title "Main Menu"
        --menu "Choice what to do next.\
        \nRemain default if unsure what to do"
        40 50 2)
    options=(1 "Config" 2 "Install")
    main_menu_choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [ $? == 1 ]; then
        # 表明在dialog_main中选择了取消，
        # 那么就要取消安装了
        flag=exit
        clear
        echo "You have canceled installtion."
        echo "Notining has changed."
        exit 1
    fi

    case $main_menu_choice in
    1) flag=config ;;
    2) flag=install ;;
    esac
}

dialog_config() {
    # --clear: clear screen for not showing previous diaglog
    cmd=(dialog --clear --title "Config Menu" --menu "Choice what to config." 40 50 2)
    options=(1 "beautification software" 2 "additional software")
    main_menu_choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ $? == 1 ]; then
        flag=main
    else
        case $main_menu_choice in
        1) flag=bs ;;
        2) flag=as ;;
        esac
    fi

}

dialog_bs() {
    cmd=(dialog
        --clear
        --checklist
        "Select (with space) what software to install.\\n
        If unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        i3 "WindowManager" $ii3
        zsh "Shell" $izsh
        fish "Frendily inactive shell" $ifish
        alacritty "Terminal" ialacritty
        polybar "Status bar" on
        picom "a compositor for X11" on
        rofi "A window switcher, application launcher, ssh dialog, dmenu replacement and more" off
        dunst "notification dameon" off
    )
    options_bs=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    flag=config
}

dialog_as() {
    cmd=(dialog
        --clear
        --checklist
        "Select (with space) what software to install.\\n
        If unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        fzf "fuzzy finder" on
    )
    options_bs=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    flag=config
}

dialog_aas() {
    # install aur additional software
    cmd=(dialog
        --clear
        --checklist
        "Select (with space) what software to install.\\n
        If unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        spotify "music player" off
    )
    options_bs=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    flag=config
}
main() {
    sudo pacman --noconfirm --needed -S dialog
    flag='main'
    while [ flag != 'exit' ]; do
        case $flag in
        main) dialog_main ;;
        config) dialog_config ;;
        bs) dialog_bs ;;
        as) dialog_as ;;
        aas) dialog_aas ;;
        esac
    done
    clear
    echo Error
    exit 1
}

main
