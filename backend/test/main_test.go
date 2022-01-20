package test

import (
	"database/sql"
	"fmt"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/lib/pq"
	"github.com/ory/dockertest/v3"
	"github.com/ory/dockertest/v3/docker"
	"github.com/shinjam/simpleChat/pkg/configs"
	"os"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/alicebob/miniredis"
	"github.com/go-testfixtures/testfixtures/v3"

	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/labstack/gommon/log"
)

var (
	fixtures *testfixtures.Loader
	db       *sql.DB
)

const (
	dbName     = "testDB"
	dbPassword = "1234"
	dbUser     = "testUser"
)

func MockQuery() (*sql.DB, sqlmock.Sqlmock) {
	db, mock, err := sqlmock.New()
	if err != nil {
		log.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}

	return db, mock
}

func TestMain(m *testing.M) {
	// Run redis
	RunRedis()

	// Run postgres
	pool, resource := RunTestDatabase()

	// Migrations
	MigrateUp()

	// Load Fixtures
	LoadFixtures()

	code := m.Run()
	// You can't defer this because os.Exit doesn't care for defer
	if err := pool.Purge(resource); err != nil {
		log.Fatalf("Could not purge resource: %s", err)
	}
	os.Exit(code)
}

func RunRedis() {
	mr, err := miniredis.Run()
	if err != nil {
		log.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}

	err = os.Setenv("REDIS_URL", mr.Addr())
	if err != nil {
		log.Error(err)
	}
}

func RunTestDatabase() (*dockertest.Pool, *dockertest.Resource) {
	pool, err := dockertest.NewPool("")
	if err != nil {
		log.Fatalf("Could not connect to docker: %s", err)
	}

	// pulls an image, creates a container based on it and runs it
	resource, err := pool.RunWithOptions(&dockertest.RunOptions{
		Repository: "postgres",
		Tag:        "11",
		Env: []string{
			"POSTGRES_PASSWORD=" + dbPassword,
			"POSTGRES_USER=" + dbUser,
			"POSTGRES_DB=" + dbName,
			"listen_addresses = '*'",
		},
	}, func(config *docker.HostConfig) {
		// set AutoRemove to true so that stopped container goes away by itself
		config.AutoRemove = true
		config.RestartPolicy = docker.RestartPolicy{Name: "no"}
	})
	if err != nil {
		log.Fatalf("Could not start resource: %s", err)
	}

	hostAndPort := resource.GetHostPort("5432/tcp")
	databaseUrl := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", dbUser, dbPassword, hostAndPort, dbName)
	os.Setenv("DATABASE_URL", databaseUrl)
	log.Print("Connecting to database on url: ", databaseUrl)

	err = resource.Expire(120)
	if err != nil {
		log.Error(err)
	} // Tell docker to hard kill the container in 120 seconds

	// exponential backoff-retry, because the application in the container might not be ready to accept connections yet
	pool.MaxWait = 120 * time.Second
	if err = pool.Retry(func() error {
		db, err = sql.Open("postgres", databaseUrl)
		if err != nil {
			return err
		}
		return db.Ping()
	}); err != nil {
		log.Fatalf("Could not connect to docker: %s", err)
	}

	return pool, resource
}

func MigrateUp() {
	fileURL := "file://" + configs.RootDir + "/platform/migrations"
	log.Print(fileURL)
	m, err := migrate.New(
		fileURL,
		os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	if err := m.Up(); err != nil {
		log.Fatal(err)
	}
}

func LoadFixtures() {
	db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Error(err)
	}
	fixtures, err = testfixtures.New(
		testfixtures.Database(db),            // You database connection
		testfixtures.Dialect("postgres"),     // Available: "postgresql", "timescaledb", "mysql", "mariadb", "sqlite" and "sqlserver"
		testfixtures.Directory("./fixtures"), // The directory containing the YAML files
	)
	if err != nil {
		log.Error(err)
	}
}

func PrepareTestDatabase() {
	if err := fixtures.Load(); err != nil {
		log.Error(err)
	}
}
