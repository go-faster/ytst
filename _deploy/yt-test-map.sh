set -e

echo '{"column_1": "aaa", "column_2" : 10}' | yt write-table --table //home/my_tbl --format=json
yt map --binary cat --src //home/my_tbl --dst //tmp/my_tbl_mapped --format yson --spec '{mapper={layer_paths=["//ubuntu-base-20.04.5-base-amd64.tar.gz"]}}'
