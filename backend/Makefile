.PHONY: clean critic security lint test build run

APP_NAME = apiserver
BUILD_DIR = $(PWD)/build
MIGRATIONS_FOLDER = $(PWD)/platform/migrations
DATABASE_URL = postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST)/$(POSTGRES_DB)?sslmode=disable


clean:
	rm -rf ./build

critic:
	@rm -rf ./docs
	gocritic check -enableAll ./...
	@swag init

security:
	gosec ./...

lint:
	golangci-lint run ./...

build: env
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(APP_NAME) main.go
	rm .env

test: clean critic security lint
	go test -v -timeout 30s -coverprofile=cover.out -cover ./...
	go tool cover -func=cover.out

run: swag build
	$(BUILD_DIR)/$(APP_NAME)

docker.redis:
	docker-compose -f docker/compose.yml --env-file=./.env.$(stage) up -d redis

docker.postgres:
	docker-compose -f docker/compose.yml --env-file=./.env.$(stage) up -d postgres

compose.build:
	docker-compose -f docker/compose.yml --env-file=./.env.$(stage) build

compose.up: swag
	docker-compose -f docker/compose.yml --env-file=./.env.$(stage) up

compose.down:
	docker-compose -f docker/compose.yml down

migrate.up:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" up

migrate.down:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" down

migrate.force:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" force $(version)

swag:
	swag init

env:
	chmod +x exportEnvs.sh
	./exportEnvs.sh
