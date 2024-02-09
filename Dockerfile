FROM golang:bookworm AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod tidy
RUN go build cmd/cli/cli.go
RUN go build cmd/server/server.go

FROM scratch
WORKDIR /app
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/cli /app/cli
COPY --from=builder /app/server /app/server
COPY --from=builder /app/templates /app/templates
COPY --from=builder /app/static /app/static
ENV GIN_MODE=release
EXPOSE 80
ENTRYPOINT ["/app/server"]