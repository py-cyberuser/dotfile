function proxyoff() {
  unset http_proxy
  unset https_proxy
  echo "Unset [http_proxy] & [https_proxy]"
}
