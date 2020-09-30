#####################
## Go plugins - https://github.com/Kong/docker-kong/issues/326
#####################
FROM kong:ubuntu as compiler

USER root

# proxy
#ENV http_proxy http://127.0.0.1:1080
#ENV https_proxy http://127.0.0.1:1080

# Install build tools
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential ca-certificates git

# Download and configure Go compiler
RUN curl -s https://storage.googleapis.com/golang/go1.13.5.linux-amd64.tar.gz | tar -v -C /usr/local -xz
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH $PATH:/usr/local/go/bin

# Go proxy
#ENV GO111MODULE on
#ENV GOPROXY https://goproxy.io

# Copy and compile go-plugins
COPY go-hello.go /tmp/go-hello.go
RUN go get github.com/Kong/go-pluginserver \
  && cd /tmp; go build -buildmode plugin go-hello.go

#####################
## Release image
#####################
FROM kong:ubuntu

RUN mkdir -p /usr/local/kong \
  && chown -R kong:0 /usr/local/kong \
  && chmod -R g=u /usr/local/kong

# Copy Go files
COPY --from=compiler /tmp/*.so /usr/local/kong/
COPY --from=compiler /go/bin/go-pluginserver /usr/local/bin/go-pluginserver

USER kong

