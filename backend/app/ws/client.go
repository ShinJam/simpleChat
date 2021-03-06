package ws

import (
	"encoding/json"

	"sync"
	"time"

	"github.com/gofiber/websocket/v2"
	"github.com/google/uuid"
	"github.com/labstack/gommon/log"
	"github.com/shinjam/simpleChat/pkg/repository"
	"github.com/shinjam/simpleChat/platform/cache"
)

const (
	// Max wait time when writing message to peer
	writeWait = 10 * time.Second

	// Max time till next pong from peer
	pongWait = 60 * time.Second

	// Send ping interval, must be less then pong wait time
	pingPeriod = (pongWait * 9) / 10

	// Maximum message size allowed from peer.
	maxMessageSize = 10000
)

var (
	newline = []byte{'\n'}
	// space   = []byte{' '}
)

// Client represents the websocket client at the server
type Client struct {
	// The actual websocket connection.
	conn     *websocket.Conn
	wsServer *WsServer
	send     chan []byte
	ID       uuid.UUID `json:"id"`
	Email    string    `json:"email"`
	rooms    map[*Room]bool
}

func newClient(conn *websocket.Conn, wsServer *WsServer, email string) *Client {
	return &Client{
		ID:       uuid.New(),
		Email:    email,
		conn:     conn,
		wsServer: wsServer,
		send:     make(chan []byte, 256),
		rooms:    make(map[*Room]bool),
	}
}

// Add the GetId method to make Client compatible with repository.UserType interface
func (client *Client) GetId() string {
	return client.ID.String()
}

func (client *Client) GetEmail() string {
	return client.Email
}

func (client *Client) readPump(wg *sync.WaitGroup) {
	defer wg.Done()
	defer func() {
		client.disconnect()
	}()

	client.conn.SetReadLimit(maxMessageSize)
	err := client.conn.SetReadDeadline(time.Now().Add(pongWait))
	if err != nil {
		log.Error(err)
		return
	}
	client.conn.SetPongHandler(func(string) error {
		if err := client.conn.SetReadDeadline(time.Now().Add(pongWait)); err != nil {
			log.Error(err)
		}
		return nil
	})

	// Start endless read loop, waiting for messages from client
	for {
		_, jsonMessage, err := client.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("unexpected close error: %v", err)
			}
			break
		}

		client.handleNewMessage(jsonMessage)
	}

}

func (client *Client) writePump(wg *sync.WaitGroup) {
	defer wg.Done()
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		err := client.conn.Close()
		if err != nil {
			log.Error(err)
		}
	}()
	for {
		select {
		case message, ok := <-client.send:
			err := client.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err != nil {
				log.Error(err)
				return
			}
			if !ok {
				// The WsServer closed the channel.
				err = client.conn.WriteMessage(websocket.CloseMessage, []byte{})
				if err != nil {
					log.Error(err)
				}
				return
			}

			w, err := client.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			_, err = w.Write(message)
			if err != nil {
				log.Error(err)
				return
			}

			// Attach queued chat messages to the current websocket message.
			n := len(client.send)
			for i := 0; i < n; i++ {
				_, err = w.Write(newline)
				if err != nil {
					log.Error(err)
				}
				_, err = w.Write(<-client.send)
				if err != nil {
					log.Error(err)
				}
			}

			if err := w.Close(); err != nil {
				return
			}
		case <-ticker.C:

			if err := client.conn.SetWriteDeadline(time.Now().Add(writeWait)); err != nil {
				log.Error(err)
				return
			}
			if err := client.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				log.Error(err)
				return
			}
		}
	}
}

func (client *Client) disconnect() {
	client.wsServer.unregister <- client
	close(client.send)
	if err := client.conn.Close(); err != nil {
		log.Error(err)
		return
	}
}

func (client *Client) handleNewMessage(jsonMessage []byte) {

	var message Message
	if err := json.Unmarshal(jsonMessage, &message); err != nil {
		log.Printf("Error on unmarshal JSON message %s", err)
		return
	}

	message.Sender = client

	switch message.Action {
	case SendMessageAction:
		roomID := message.Target.GetId()
		if room := client.wsServer.findRoomByID(roomID); room != nil {
			room.broadcast <- &message
		}

	case JoinRoomAction:
		client.handleJoinRoomMessage(message)

	case LeaveRoomAction:
		client.handleLeaveRoomMessage(message)

	case JoinRoomPrivateAction:
		client.handleJoinRoomPrivateMessage(message)
	}

}
func (client *Client) handleJoinRoomMessage(message Message) {
	roomName := message.Message

	client.joinRoom(roomName, nil)
}

func (client *Client) handleLeaveRoomMessage(message Message) {
	room := client.wsServer.findRoomByID(message.Message)
	if room == nil {
		return
	}

	delete(client.rooms, room)

	room.unregister <- client
}

func (client *Client) handleJoinRoomPrivateMessage(message Message) {
	target := client.wsServer.findUserByID(message.Message)
	if target == nil {
		return
	}

	// create unique room name combined to the two IDs
	roomName := message.Message + client.ID.String()

	// Join room
	joinedRoom := client.joinRoom(roomName, target)

	// Instead of instantaneously joining the target client.
	// Let the target client join with a invite request over pub/sub
	if joinedRoom != nil {
		client.inviteTargetUser(target, joinedRoom)
	}
}

func (client *Client) joinRoom(roomName string, sender repository.User) *Room {

	room := client.wsServer.findRoomByName(roomName)
	if room == nil {
		room, _ = client.wsServer.createRoom(roomName, sender != nil)
	}

	// Don't allow to join private rooms through public room message
	if sender == nil && room.Private {
		return nil
	}

	if !client.isInRoom(room) {
		client.rooms[room] = true
		room.register <- client
		client.notifyRoomJoined(room, sender)
	}
	return room

}

// Send out invite message over pub/sub in the general channel.
func (client *Client) inviteTargetUser(target repository.User, room *Room) {
	connRedis, err := cache.RedisConnection()
	if err != nil {
		log.Error(err)
		return
	}
	inviteMessage := &Message{
		Action:  JoinRoomPrivateAction,
		Message: target.GetId(),
		Target:  room,
		Sender:  client,
	}

	if err := connRedis.Publish(ctx, PubSubGeneralChannel, inviteMessage.encode()).Err(); err != nil {
		log.Error(err)
	}
}

func (client *Client) isInRoom(room *Room) bool {
	if _, ok := client.rooms[room]; ok {
		return true
	}

	return false
}

func (client *Client) notifyRoomJoined(room *Room, sender repository.User) {
	message := Message{
		Action: RoomJoinedAction,
		Target: room,
		Sender: sender,
	}

	client.send <- message.encode()
}

// ServeWs handles websocket requests from clients requests.
func ServeWs(conn *websocket.Conn) {
	wsServer := conn.Locals("wsServer").(*WsServer)
	email := conn.Query("email")
	if email == "" {
		log.Error("Url Param 'email' is missing")
		return
	}
	client := newClient(conn, wsServer, email)
	wsServer.register <- client

	var wg sync.WaitGroup
	wg.Add(2)
	go client.writePump(&wg)
	go client.readPump(&wg)
	wg.Wait()

}
