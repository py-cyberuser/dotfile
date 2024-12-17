#/bin/bash

test() {
  #set -- $(getopt -o i:p::h --long ip:,port::,help -- "$@")
  while true; do
    case "$1" in
    -i | --ip)
      ip="$2"
      echo "ip:    $ip"
      shift
      ;;
    -p | --port)
      port="$2"
      echo "port:    $port"
      shift
      ;;
    -h | --help)
      usage
      # 打印usage之后直接用exit退出程序
            exit
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "$1 is not option"
      ;;
    esac
    shift
  done
  # 剩余所有未解析到的参数存在$@中，可通过遍历$@来获取
  for param in "$@"; do
    echo "Parameter #$count: $param"
  done
}
