package ws

import (
	"encoding/json"

	"github.com/google/uuid"
	"github.com/labstack/gommon/log"
	"github.com/shinjam/simpleChat/pkg/repository"
	"github.com/shinjam/simpleChat/platform/cache"
	"github.com/shinjam/simpleChat/platform/database"
)

const PubSubGeneralChannel = "general"

type WsServer struct {
	clients    map[*Client]bool
	register   chan *Client
	unregister chan *Client
	broadcast  chan []byte
	rooms      map[*Room]bool
	Users      []repository.User
}

// NewWebsocketServer creates a new WsServer type
func NewWebsocketServer() *WsServer {
	wsServer := &WsServer{
		clients:    make(map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		rooms:      make(map[*Room]bool),
	}
	return wsServer
}

// Run our websocket server, accepting various requests
func (server *WsServer) Run() {
	go server.listenPubSubChannel()

	for {
		select {
		case client := <-server.register:
			server.registerClient(client)
		case client := <-server.unregister:
			server.unregisterClient(client)
		case message := <-server.broadcast:
			server.broadcastToClients(message)
		}
	}
}

func (server *WsServer) registerClient(client *Client) {
	// Publish user in PubSub
	server.publishClientJoined(client)
	server.listOnlineClients(client)
	server.clients[client] = true
}

func (server *WsServer) unregisterClient(client *Client) {
	if _, ok := server.clients[client]; ok {
		delete(server.clients, client)
		// Remove user from repo
		db, err := database.OpenDBConnection()
		if err != nil {
			log.Error(err)
			return
		}
		err = db.SoftDeleteeUserByID(client.ID)
		if err != nil {
			log.Error(err)
			return
		}

		// Publish user left in PubSub
		server.publishClientLeft(client)
	}
}

func (server *WsServer) listOnlineClients(client *Client) {
	for _, user := range server.Users {
		message := &Message{
			Action: UserJoinedAction,
			Sender: user,
		}
		client.send <- message.encode()
	}
}

func (server *WsServer) broadcastToClients(message []byte) {
	for client := range server.clients {
		client.send <- message
	}
}

func (server *WsServer) findRoomByName(name string) *Room {
	var foundRoom *Room
	for room := range server.rooms {
		if room.GetName() == name {
			foundRoom = room
			break
		}
	}
	// if there is no room, try to create it from the repo
	if foundRoom == nil {
		// Try to run the room from the repository, if it is found.
		foundRoom, _ = server.runRoomFromRepository(name)
	}

	return foundRoom
}

func (server *WsServer) runRoomFromRepository(name string) (*Room, error) {
	var room *Room
	db, err := database.OpenDBConnection()
	if err != nil {
		log.Error(err)
		return nil, err
	}
	dbRoom, err := db.GetRoomByName(name)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	room = NewRoom(dbRoom.GetName(), dbRoom.GetPrivate())
	room.ID, _ = uuid.Parse(dbRoom.GetId())

	go room.RunRoom()
	server.rooms[room] = true

	return room, nil
}

func (server *WsServer) findRoomByID(id string) *Room {
	var foundRoom *Room
	for room := range server.rooms {
		if room.GetId() == id {
			foundRoom = room
			break
		}
	}

	return foundRoom
}

func (server *WsServer) createRoom(name string, private bool) (*Room, error) {
	room := NewRoom(name, private)

	db, err := database.OpenDBConnection()
	if err != nil {
		log.Error("Something wrong with database connection")
		return nil, err
	}
	err = db.CreateRoom(room)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	go room.RunRoom()
	server.rooms[room] = true

	return room, nil
}

func (server *WsServer) findUserByID(id string) repository.User {
	var foundUser repository.User
	for _, client := range server.Users {
		if client.GetId() == id {
			foundUser = client
			break
		}
	}

	return foundUser
}

// Publish userJoined message in pub/sub
func (server *WsServer) publishClientJoined(client *Client) {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}
	message := &Message{
		Action: UserJoinedAction,
		Sender: client,
	}

	if err := connRedis.Publish(ctx, PubSubGeneralChannel, message.encode()).Err(); err != nil {
		log.Error(err)
	}
}

// Publish userleft message in pub/sub
func (server *WsServer) publishClientLeft(client *Client) {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}

	message := &Message{
		Action: UserLeftAction,
		Sender: client,
	}

	if err := connRedis.Publish(ctx, PubSubGeneralChannel, message.encode()).Err(); err != nil {
		log.Error(err)
	}
}

// Listen to pub/sub general channels
func (server *WsServer) listenPubSubChannel() {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}

	pubsub := connRedis.Subscribe(ctx, PubSubGeneralChannel)
	ch := pubsub.Channel()
	for msg := range ch {

		var message Message
		if err := json.Unmarshal([]byte(msg.Payload), &message); err != nil {
			log.Printf("Error on unmarshal JSON message %s", err)
			return
		}

		switch message.Action {
		case UserJoinedAction:
			server.handleUserJoined(message)
		case UserLeftAction:
			server.handleUserLeft(message)
		case JoinRoomPrivateAction:
			server.handleUserJoinPrivate(message)
		}
	}
}
func (server *WsServer) handleUserJoinPrivate(message Message) {
	// Find client for given user, if found add the user to the room.
	targetClient := server.findClientByID(message.Message)
	if targetClient != nil {
		targetClient.joinRoom(message.Target.GetName(), message.Sender)
	}
}

func (server *WsServer) handleUserJoined(message Message) {
	// Add the user to the slice
	server.Users = append(server.Users, message.Sender)
	server.broadcastToClients(message.encode())
}

func (server *WsServer) handleUserLeft(message Message) {
	// Remove the user from the slice
	for i, user := range server.Users {
		if user.GetId() == message.Sender.GetId() {
			server.Users[i] = server.Users[len(server.Users)-1]
			server.Users = server.Users[:len(server.Users)-1]
		}
	}
	server.broadcastToClients(message.encode())
}

func (server *WsServer) findClientByID(id string) *Client {
	var foundClient *Client
	for client := range server.clients {
		if client.GetId() == id {
			foundClient = client
			break
		}
	}

	return foundClient
}
