set -e

export CGO_ENABLED=0
go build ../cmd/yt-http-test
yt write-file '//yt-http-test' < yt-http-test
yt vanilla \
  --spec='{stderr_table_path="//tmp/yt-test-stderr";max_failed_job_count=2;}' \
  --tasks '{task={command="./yt-http-test --duration 10s";"file_paths"=[<executable=%true;>"//yt-http-test";];"layer_paths"=["//ubuntu-base-20.04.5-base-amd64.tar.gz";];"make_rootfs_writable"=%true;"job_count"=1;};}'
