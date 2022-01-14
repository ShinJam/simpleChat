<template>
  <div class="container">
    <header class="jumbotron">
      <h3 v-if="currentUser">
        Hello <strong>{{ currentUser.email }}</strong>
      </h3>
    </header>
    <div class="container h-100">
      <div class="row justify-content-center h-100">
        <div class="col-12 form" v-if="!ws">
          <h1>Something wrong with web socket</h1>
        </div>

        <div class="col-12 room" v-if="ws != null">
          <div class="input-group">
            <input
              v-model="roomInput"
              class="form-control name"
              placeholder="Type the room you want to join"
              @keyup.enter.exact="joinRoom"
            />
            <div class="input-group-append">
              <span class="input-group-text send_btn" @click="joinRoom">
                >
              </span>
            </div>
          </div>
        </div>

        <div class="chat" v-for="(room, key) in rooms" :key="key">
          <div class="card">
            <div class="card-header msg_head">
              <div class="d-flex bd-highlight justify-content-center">
                {{ room.name }}
                <span class="card-close" @click="leaveRoom(room)">leave</span>
              </div>
            </div>
            <div class="card-body msg_card_body">
              <div
                v-for="(message, key) in room.messages"
                :key="key"
                class="d-flex justify-content-start mb-4"
              >
                <div class="msg_cotainer">
                  {{ message.message }}
                  <span class="msg_name" v-if="message.sender">{{
                    message.sender.name
                  }}</span>
                </div>
              </div>
            </div>
            <div class="card-footer">
              <div class="input-group">
                <textarea
                  v-model="room.newMessage"
                  name=""
                  class="form-control type_msg"
                  placeholder="Type your message..."
                  @keyup.enter.exact="sendMessage(room)"
                ></textarea>
                <div class="input-group-append">
                  <span
                    class="input-group-text send_btn"
                    @click="sendMessage(room)"
                    >></span
                  >
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- <p>
      <strong>Token:</strong>
      {{currentUser.accessToken.substring(0, 20)}} ... {{currentUser.accessToken.substr(currentUser.accessToken.length - 20)}}
    </p>
    <p>
      <strong>Id:</strong>
      {{currentUser.id}}
    </p>
    <p>
      <strong>Email:</strong>
      {{currentUser.email}}
    </p>
    <strong>Authorities:</strong>
    <ul>
      <li v-for="(role,index) in currentUser.roles" :key="index">{{role}}</li>
    </ul> -->
  </div>
</template>

<script>
export default {
  name: "Home",
  data() {
    return {
      ws: null,
      serverUrl: "ws://localhost:5000/ws/v1",
      roomInput: null,
      rooms: [],
      user: {
        email: "",
      },
      users: []
    };
  },
  computed: {
    currentUser() {
      return this.$store.state.auth.user;
    },
  },
  mounted() {
    if (!this.currentUser) {
      this.$router.push("/login");
    } else {
      this.user.email = this.currentUser.email
    }

    this.connectToWebsocket();
  },
  methods: {
    connectToWebsocket() {
      this.ws = new WebSocket(this.serverUrl + "?email=" + this.user.email);
      this.ws.addEventListener("open", (event) => {
        this.onWebsocketOpen(event);
      });
      this.ws.addEventListener("message", (event) => {
        this.handleNewMessage(event);
      });
    },
    onWebsocketOpen() {
      console.log("connected to WS!");
    },

    handleNewMessage(event) {
      let data = event.data;
      data = data.split(/\r?\n/);

      for (let i = 0; i < data.length; i++) {
        let msg = JSON.parse(data[i]);
        switch (msg.action) {
          case "send-message":
            this.handleChatMessage(msg);
            break;
          case "user-join":
            this.handleUserJoined(msg);
            break;
          case "user-left":
            this.handleUserLeft(msg);
            break;
          case "room-joined":
            this.handleRoomJoined(msg);
            break;
          default:
            break;
        }
      }
    },
    handleChatMessage(msg) {
      const room = this.findRoom(msg.target.id);
      if (typeof room !== "undefined") {
        room.messages.push(msg);
      }
    },
    handleUserJoined(msg) {
      this.users.push(msg.sender);
    },
    handleUserLeft(msg) {
      for (let i = 0; i < this.users.length; i++) {
        if (this.users[i].id == msg.sender.id) {
          this.users.splice(i, 1);
        }
      }
    },
    handleRoomJoined(msg) {
      const room = msg.target;
      room.name = room.private ? msg.sender.name : room.name;
      room["messages"] = [];
      this.rooms.push(room);
    },
    sendMessage(room) {
      if (room.newMessage !== "") {
        this.ws.send(
          JSON.stringify({
            action: "send-message",
            message: room.newMessage,
            target: {
              id: room.id,
              name: room.name,
            },
          })
        );
        room.newMessage = "";
      }
    },
    findRoom(roomId) {
      for (let i = 0; i < this.rooms.length; i++) {
        if (this.rooms[i].id === roomId) {
          return this.rooms[i];
        }
      }
    },
    joinRoom() {
      this.ws.send(
        JSON.stringify({ action: "join-room", message: this.roomInput })
      );
      this.roomInput = "";
    },
    leaveRoom(room) {
      this.ws.send(JSON.stringify({ action: "leave-room", message: room.id }));

      for (let i = 0; i < this.rooms.length; i++) {
        if (this.rooms[i].id === room.id) {
          this.rooms.splice(i, 1);
          break;
        }
      }
    },
    joinPrivateRoom(room) {
      this.ws.send(
        JSON.stringify({ action: "join-room-private", message: room.id })
      );
    },
  },
};
</script>
