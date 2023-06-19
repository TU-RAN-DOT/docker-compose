FROM alpine:3.18

RUN apk add bash openssh

COPY --chmod=755 ./entrypoint.sh /

ENTRYPOINT /entrypoint.sh
