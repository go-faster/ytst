export YT_PROXY="$(kubectl get node "$(hostname)" -o json | jq -r .status.addresses[0].address):$(kubectl -n yt get svc http-proxies-lb -o json | jq .spec.ports[0].nodePort)"
export YT_CONFIG_PATCHES='{proxy={enable_proxy_discovery=%false}}'
export YT_TOKEN=password

echo "API: $YT_PROXY"
echo "UI: http://$(kubectl get node "$(hostname)" -o json | jq -r .status.addresses[0].address):$(kubectl -n yt get svc ytsaurus-ui -o json | jq .spec.ports[0].nodePort)"
