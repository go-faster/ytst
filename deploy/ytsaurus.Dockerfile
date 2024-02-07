FROM ytsaurus/ytsaurus:stable-23.1.0-relwithdebinfo

RUN ln -s /usr/bin/ytserver-all /usr/bin/ytserver-master-cache
