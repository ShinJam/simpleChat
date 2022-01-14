package ws

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/labstack/gommon/log"
	"github.com/shinjam/simpleChat/platform/cache"
)

var ctx = context.Background()

const welcomeMessage = "%s joined the room"

type Room struct {
	ID         uuid.UUID `json:"id"`
	Name       string    `json:"name"`
	clients    map[*Client]bool
	register   chan *Client
	unregister chan *Client
	broadcast  chan *Message
	Private    bool `json:"private"`
}

// NewRoom creates a new Room
func NewRoom(name string, private bool) *Room {
	return &Room{
		ID:         uuid.New(),
		Name:       name,
		clients:    make(map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan *Message),
		Private:    private,
	}
}

// RunRoom runs our room, accepting various requests
func (room *Room) RunRoom() {
	go room.subscribeToRoomMessages()

	for {
		select {

		case client := <-room.register:
			room.registerClientInRoom(client)

		case client := <-room.unregister:
			room.unregisterClientInRoom(client)

		case message := <-room.broadcast:
			room.publishRoomMessage(message.encode())
		}

	}
}

func (room *Room) registerClientInRoom(client *Client) {
	if !room.Private {
		room.notifyClientJoined(client)
	}
	room.clients[client] = true
}

func (room *Room) unregisterClientInRoom(client *Client) {
	delete(room.clients, client)
}

func (room *Room) broadcastToClientsInRoom(message []byte) {
	for client := range room.clients {
		client.send <- message
	}
}

func (room *Room) notifyClientJoined(client *Client) {
	message := &Message{
		Action:  SendMessageAction,
		Target:  room,
		Message: fmt.Sprintf(welcomeMessage, client.GetEmail()),
	}

	room.publishRoomMessage(message.encode())
}

func (room *Room) GetId() string {
	return room.ID.String()
}

func (room *Room) GetName() string {
	return room.Name
}

// GetPrivate method to make Room compatible with model.Room interface
func (room *Room) GetPrivate() bool {
	return room.Private
}

func (room *Room) publishRoomMessage(message []byte) {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}

	err = connRedis.Publish(ctx, room.GetName(), message).Err()
	if err != nil {
		log.Error(err)
	}
}

func (room *Room) subscribeToRoomMessages() {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}

	pubsub := connRedis.Subscribe(ctx, room.GetName())
	if err != nil {
		log.Error(err)
	}

	ch := pubsub.Channel()

	for msg := range ch {
		room.broadcastToClientsInRoom([]byte(msg.Payload))
	}
}
