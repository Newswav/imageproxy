# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/wolfi-base as build
LABEL maintainer="Will Norris <will@willnorris.com>"

RUN apk update && apk add build-base git openssh go-1.20

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v ./cmd/imageproxy

FROM cgr.dev/chainguard/static:latest

COPY --from=build /app/imageproxy /app/imageproxy

CMD ["-addr", "0.0.0.0:8080"]
ENTRYPOINT ["/app/imageproxy"]

# Found userAgent flag in main.go, but not sure container capable of accepting this flag
# CMD ["/app/imageproxy","-userAgent=newswav-fetcher"]

EXPOSE 8080
