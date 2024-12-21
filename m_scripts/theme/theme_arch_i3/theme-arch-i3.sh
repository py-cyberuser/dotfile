#!/bin/bash
default_config_path="./pkgs.pkg"
source $default_config_path

green='\033[0;32m'
no_color='\033[0m'

# 最好别加noconfirm(arch manpage上所说)，加了也行

load_config() {
    if test -e ./modi_pkgs.pkg; then
        source ./modi_pkgs.pkg
    else
        source $default_config_path
    fi
}

analysis_pkgs() {
    # 读取配置文件中需要安装的包
    #
    # -c：计算输出的行数
    # -E：使用加强的正则表达式（可以使用|了）
    # -v：除了正则表达式的情况，其他情况均匹配
    # ^#：以#开头的行
    # ^$：空行
    # 读取非空非注释的行
    pkgs_lines=$(grep -E -v '^#|^$' $default_config_path)
    for line in ${pkgs_lines[*]}; do
        # 获取变量名称和变量数值（pkg_status）
        var_name=$(echo $line | awk -F "=" '{print $1}')
        pkg_status=$(echo $line | awk -F "=" '{print $2}')
        if [ "$(echo $var_name | grep -c '^bs')" == 1 ]; then
            # 发现以bs开头的变量名称
            # 加入pkg_bs数列
            if [ "$pkg_status" == "off" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,3,length($1))}')
                pkgs_full_bs+=($pkg_name)
            elif [ "$pkg_status" == "on" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,3,length($1))}')
                pkgs_bs+=($pkg_name)
                pkgs_full_bs+=($pkg_name)
            else
                echo "wrong pkg status"
            fi
        elif [ "$(echo $var_name | grep '^as' | grep -c -v '^aas')" == 1 ]; then
            if [ "$pkg_status" == "off" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,3,length($1))}')
                pkgs_full_as+=($pkg_name)
            elif [ "$pkg_status" == "on" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,3,length($1))}')
                pkgs_as+=($pkg_name)
                pkgs_full_as+=($pkg_name)
            else
                echo "wrong pkg status"
            fi

        elif [ "$(echo $var_name | grep -c '^aas')" == 1 ]; then
            if [ "$pkg_status" == "off" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,4,length($1))}')
                if [ "$pkg_name" == "vscode" ]; then
                    # 部分aur仓库里的文件有横杠，无法作为变量名
                    # 这里替换一下
                    # （后面可以用其他配置文件代替目前的sh配置文件）
                    pkg_name="visual-studio-code-bin"
                fi

                pkgs_full_aas+=($pkg_name)
            elif [ "$pkg_status" == "on" ]; then
                pkg_name=$(echo $var_name | awk '{print substr($1,4,length($1))}')
                if [ "$pkg_name" == "vscode" ]; then
                    # 部分aur仓库里的文件有横杠，无法作为变量名
                    # 这里替换一下
                    # （后面可以用其他配置文件代替目前的sh配置文件）
                    pkg_name="visual-studio-code-bin"
                fi
                pkgs_aas+=($pkg_name)
                pkgs_full_aas+=($pkg_name)
            else
                echo "wrong pkg status"
            fi
        fi
    done

}

cts() {
    # config file load to software_name
    if [ "$pkg_name" == "vscode" ]; then
        # 部分aur仓库里的文件有横杠，无法作为变量名
        # 这里替换一下
        # （后面可以用其他配置文件代替目前的sh配置文件）
        cts_name="visual-studio-code-bin"
    fi

}

stc() {
    # software_name export to config variable
    if [ "$1" == "visual-studio-code-bin" ]; then
        # 部分aur仓库里的文件有横杠，无法作为变量名
        # 这里替换一下
        # （后面可以用其他配置文件代替目前的sh配置文件）
        stc_name="vscode"
    else
        stc_name=$1
    fi

}

print_full_pkgs() {
    # 测试用，没写完
    # 将所有从pkgs_full_...读取的包输出到full_pkgs文件
    echo "# [Beautification Software]" >>full_pkgs
    for pkg in ${pkgs_full_bs[@]}; do
        echo $pkg >>full_pkgs
    done
}

find_remain_pkgs() {
    # 获得没有在dialog中设置为安装的包
    if [ $1 == "bs" ]; then
        pkgs_tmp=${pkgs_full_bs[@]}
        config_on=${config_on_bs[@]}

    elif [ $1 == "as" ]; then
        pkgs_tmp=${pkgs_full_as[@]}

        config_on=${config_on_as[@]}

    elif [ $1 == "aas" ]; then
        pkgs_tmp=${pkgs_full_aas[@]}
        config_on=${config_on_aas[@]}

    else
        echo "wrong param for find_remain_pkgs"
        exit 2
    fi
    if test -z "$config_on"; then
        notify-send "$1 zero config"
        pkgs_remain=${pkgs_tmp[@]}
    else
        for pkg_on in ${config_on[@]}; do
            # 先检查修改过的第一个包名
            # 通过sed将该包名从pkgs_tmp中去除
            # 以此类推，第二次去除第二个设置为on的包名
            tmp=$(echo ${pkgs_tmp[*]} | sed 's/\<'$pkg_on'\>//')
            unset pkgs_tmp
            pkgs_tmp=${tmp[@]}
        done
        pkgs_remain=${pkgs_tmp[@]}
    fi
    echo "----------pkgs_remain------" >>./process.pkg
    echo ${pkgs_remain[@]} >>./process.pkg
}

create_config() {
    if test -e ./modi_pkgs.pkg; then
        rm ./modi_pkgs.pkg
    fi
    if test -e ./process.pkg; then
        rm ./process.pkg
    fi
    # 保存配置文件
    echo "# [Beautification Software]" >>modi_pkgs.pkg
    if test -n "$modi_pkgs_bs"; then
        # 说明修改过关于bs的对话框了
        config_on_bs=${modi_pkgs_bs[@]}
    elif [ "$flag_cn_bs" == 1 ]; then
        config_on_bs=()
    else
        config_on_bs=${pkgs_bs[@]}
    fi
    for pkg in ${config_on_bs[@]}; do
        var_name="bs""$pkg"
        line_content="$var_name""=on"
        echo $line_content >>modi_pkgs.pkg
    done
    find_remain_pkgs bs
    for pkg in ${pkgs_remain[@]}; do
        var_name="bs""$pkg"
        line_content="$var_name""=off"
        echo $line_content >>modi_pkgs.pkg
    done

    echo "# [Additional Software]" >>modi_pkgs.pkg
    if test -n "$modi_pkgs_as"; then
        config_on_as=${modi_pkgs_as[@]}
    elif [ "$flag_cn_as" == 1 ]; then
        config_on_as=()
    else
        config_on_as=${pkgs_as[@]}
    fi
    for pkg in ${config_on_as[@]}; do
        var_name="as""$pkg"
        line_content="$var_name""=on"
        echo $line_content >>modi_pkgs.pkg
    done
    find_remain_pkgs as
    for pkg in ${pkgs_remain[@]}; do
        var_name="as""$pkg"
        line_content="$var_name""=off"
        echo $line_content >>modi_pkgs.pkg
    done

    echo "# [AUR Additional Software]" >>modi_pkgs.pkg
    if test -n "$modi_pkgs_aas"; then
        config_on_aas=${modi_pkgs_aas[@]}
    elif [ "$flag_cn_aas" == 1 ]; then
        config_on_aas=()
    else
        config_on_aas=${pkgs_aas[@]}
    fi
    for pkg in ${config_on_aas[@]}; do
        stc $pkg
        var_name="aas""$stc_name"
        line_content="$var_name""=on"
        echo $line_content >>modi_pkgs.pkg
    done
    find_remain_pkgs aas
    for pkg in ${pkgs_remain[@]}; do
        stc $pkg
        var_name="aas""$stc_name"
        line_content="$var_name""=off"
        echo $line_content >>modi_pkgs.pkg
    done
    load_config
}

dialog_main() {
    cmd=(dialog --clear --title "Main Menu"
        --colors
        --menu "Choice what to do next.\
        \nRemain default if unsure what to do\
        \n\Zb\Z1Before installtion, save config first.\Zn"
        40 50 2)
    options=(1 "Config" 2 "Install")
    main_menu_choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [ $? == 1 ]; then
        # 表明在dialog_main中选择了取消，
        # 那么就要取消安装了
        flag=exit
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
    options=(1 "beautification software" 2 "additional software" 3 "AUR additional software")
    main_menu_choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ $? == 1 ]; then
        flag=main
    else
        case $main_menu_choice in
        1) flag=bs ;;
        2) flag=as ;;
        3) flag=aas ;;
        esac
    fi

}

dialog_bs() {
    cmd=(dialog
        --clear
        --title "Beautification Software to Install"
        --separate-output
        --checklist
        "Select (with space) what software to install.\
        \nIf unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        i3 "WindowManager" $bsi3
        zsh "Shell" $bszsh
        fish "Frendily inactive shell" $bsfish
        alacritty "Terminal" $bsalacritty
        polybar "Status bar" $bspolybar
        picom "a compositor for X11" $bspicom
        demu "i3 default appication launcher" $bsdemu
        rofi "A window switcher, application launcher, ssh dialog, dmenu replacement and more" $bsrofi
        dunst "notification dameon" $bsdunst
    )
    result=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$?" == 0 ]; then
        # 按下了确认按钮
        if test -n "$result"; then
            flag_cn_bs=0
            modi_pkgs_bs=$result
        else
            # 如果一个都没选按下确认按钮
            # result返回空
            flag_cn_bs=1
        fi
    fi
    create_config
    flag=config
    flag_bs=1
}

dialog_as() {
    cmd=(dialog
        --clear
        --title "Additional Software to Install"
        --separate-output
        --checklist
        "Select (with space) what software to install.\
        \nIf unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        fzf "fuzzy finder" $asfzf
    )
    result=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$?" == 0 ]; then
        if test -n "$result"; then
            flag_cn_as=0
            modi_pkgs_as=$result
        else
            flag_cn_as=1
        fi
    fi
    create_config
    flag=config
    flag_as=1
}

dialog_aas() {
    # install aur additional software
    cmd=(dialog
        --clear
        --title "AUR Additional Software to Install"
        --checklist
        "Select (with space) what software to install.\
        \nIf unkown what to do, remain DEFAULT options."
        26 86 16)
    options=(
        spotify "music player" $aasspotify
        visual-studio-code-bin "official community maintained binary repo" $aasvscode
    )
    # modified packages selection(string)
    result=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$?" == 0 ]; then
        notify-send "agree"
        if test -n "$result"; then
            flag_cn_aas=0
            modi_pkgs_aas=$result
        else
            flag_cn_aas=1
        fi
    fi
    create_config
    flag=config
    flag_aas=1
}
install() {
    if test -e ./installed.pkg; then
        rm ./installed.pkg
    fi
    install_pacman_pkgs
    install_aur_pkgs
    exit 0
}

install_pacman_pkgs() {
    echo "[pacaman_pkgs]" | tee -a ./installed
    echo "[pkgs_as]" | tee -a ./installed
    for pkg in ${pkgs_as[@]}; do
        echo pkg | tee -a ./installed
    done
    echo "[pkgs_bs]" | tee -a ./installed
    for pkg in ${pkgs_bs[@]}; do
        notify-send $pkg
    done

    sleep 100
    pkgs_pacman=(${pkgs_as[@]} ${pkgs_bs[@]})
    for pkg in ${pkgs_pacman[@]}; do
        notify-send $pkg
    done
}

install_aur_pkgs() {
    return 0
}

main() {
    #sudo pacman --noconfirm --needed -S dialog
    analysis_pkgs

    if test -e ./modi_pkgs.pkg; then
        rm ./modi_pkgs.pkg
    fi
    if test -e ./process.pkg; then
        rm ./process.pkg
    fi
    flag='main'
    while [ flag != 'exit' ]; do
        case $flag in
        main) dialog_main ;;
        config) dialog_config ;;
        bs) dialog_bs ;;
        as) dialog_as ;;
        aas) dialog_aas ;;
        install) install ;;
        esac
    done
    echo "Error: Unexcepted Quit!"
    exit 1
}

main
