FROM busybox:latest

COPY x-ui-linux-amd64.tar.gz /x-ui.tar.gz

RUN mkdir -p /usr/local/x-ui && \ 
    tar -xzf /x-ui.tar.gz -C /usr/local && \
    rm -rf /x-ui.tar.gz

WORKDIR /usr/local/x-ui

EXPOSE 54321

CMD ["/usr/local/x-ui/x-ui"]