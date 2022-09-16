FROM golang:1.19.1-alpine3.16 as builder

COPY go.mod go.sum /go/src/github.com/igstbagusdharmaputra/golang-postgresql-rest-api/
WORKDIR /go/src/github.com/igstbagusdharmaputra/golang-postgresql-rest-api
RUN go mod download
COPY . /go/src/github.com/igstbagusdharmaputra/golang-postgresql-rest-api
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o build/golang-postgresql-rest-api github.com/igstbagusdharmaputra/golang-postgresql-rest-api

FROM alpine
RUN apk add --no-cache ca-certificates && update-ca-certificates
COPY --from=builder /go/src/github.com/igstbagusdharmaputra/golang-postgresql-rest-api/build/golang-postgresql-rest-api /usr/bin/golang-postgresql-rest-api
EXPOSE 8080 8080
ENTRYPOINT ["/usr/bin/golang-postgresql-rest-api"]
