FROM almalinux:9.2

ADD incluster-auth-test /usr/sbin/incluster-auth-test

ENTRYPOINT ["/usr/sbin/incluster-auth-test"]
