FROM ubuntu:latest

ADD incluster-auth-test /usr/sbin/incluster-auth-test

ENTRYPOINT ["/usr/sbin/incluster-auth-test"]
