set -e

pushd ytst

export CGO_ENABLED=0
go install ./cmd/yt-http-test

yt write-file '//yt-http-test' < /go/bin/yt-http-test
yt vanilla --tasks '{task={command="./yt-http-test";"file_paths"=[<executable=%true;>"//yt-http-test";];"layer_paths"=["//ubuntu-base-22.04-base-amd64.tar.gz";];"make_rootfs_writable"=%true;"job_count"=1;};}'

popd
