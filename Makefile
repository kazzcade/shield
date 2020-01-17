build:
	GOARCH=amd64 GOOS=linux go build -o bin/handler src/main.go
debug-build:
	GOARCH=amd64 GOOS=linux go build -gcflags "all=-N -l" -o bin/handler src/main.go
	GOARCH=amd64 GOOS=linux go build -o debug/dlv github.com/go-delve/delve/cmd/dlv
	#sam local invoke -t inf/buildStatusEventHandler.sam.yml -d 5986 --debugger-path ./bin --debug-args "-delveAPI=2"
