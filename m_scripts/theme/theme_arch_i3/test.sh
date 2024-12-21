#!/usr/bin/

default_config_path="./pkgs.pkg"
source $default_config_path

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
        elif [ "$(echo $var_name | grep -c '^as')" == 1 ]; then
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
                pkgs_as+=($pkg_name)
                pkgs_full_aas+=($pkg_name)
            else
                echo "wrong pkg status"
            fi
        fi
    done
    echo ${pkgs_full_bs[@]}
    echo ${pkgs_full_as[@]}
}
analysis_pkgs
