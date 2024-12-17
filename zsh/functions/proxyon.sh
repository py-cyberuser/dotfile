function proxyon() {
  default_proxy=${1:-'172.17.122.10:7890'}
  export http_proxy=$default_proxy
  export https_proxy=$default_proxy
  echo "Set [http_proxy] as $default_proxy"
  echo "Set [https_proxy] as $default_proxy"
}
