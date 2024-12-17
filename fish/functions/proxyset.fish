function proxyset --description 'Use Clash from host machine'
    set -l options h/help
    argparse -n proxyset $options -- $argv
    if set -q _flag_help
        echo "Use Clash from host machine
[Arg]
          on:     turn proxy on
          off:    trun proxy off"
        return 0
    end

    for arg in $argv
        switch $arg
            case on
                set -x http_proxy 172.17.122.10:7890
                set -x https_proxy 172.17.122.10:7890
                echo 'set [http_proxy] as 172.17.122.10:7890'
                echo 'set [https_proxy] as 172.17.122.10:7890'
                return 1
            case off
                set -e http_proxy
                set -e https_proxy
                echo 'unset [http_proxy] [https_proxy]'
                return 0
        end
    end
    return 3
end
