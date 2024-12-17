#/bin/bash
function funcsave() {
  ShortOpts='h,d:'
  LongOpts='help,description:'
  ARGS=$(
    getopt --options $ShortOpts --longoptions $LongOpts -- "$@"
  )
  eval set -- $ARGS
  while true; do
    case "$1" in
    -h | --help)
      echo "Usage:
          -d, --description       leave yout description
          -h, --help              display this help and exit

          example1: testGetopt -i192.168.1.1 -p80
          example2: testGetopt --ip=192.168.1.1 --port=p80"
      return 0
      ;;
    -d | --description)
      echo "Output result to $2 directory"
      shift 2
      ;;
    --)
      echo "hello"
      shift
      break
      ;;
    esac
  done
  echo "Remaining arguments:"
  for arg; do
    echo '--> '"\`$arg'"
  done
}
