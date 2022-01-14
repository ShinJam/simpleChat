package repository

type User interface {
	GetId() string
	GetEmail() string
}

type Room interface {
	GetId() string
	GetName() string
	GetPrivate() bool
}
