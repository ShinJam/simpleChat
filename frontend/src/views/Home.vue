<template>
  <div class="container">
    <header class="jumbotron">
      <h3>
        Hello <strong>{{ state.currentUser.email }}</strong>
      </h3>
    </header>
    <div class="container h-100">
      <div class="row justify-content-center h-100">
        <!-- <div class="col-12 form" v-if="!ws">
              <div class="input-group">
                <input
                  v-model="user.name"
                  class="form-control name"
                  placeholder="Please fill in your (nick)name"
                  @keyup.enter.exact="connect"
                ></input>
                <div class="input-group-append">
                  <span class="input-group-text send_btn" @click="connect">
                  >
                  </span>
                </div>
            </div>
          </div> -->
        <div class="col-12">
          <div class="row">
            <div
              class="col-2 card profile"
              v-for="user in state.usersList"
              :key="user.id"
            >
              <div class="card-header">{{ user.email }}</div>
              <div class="card-body">
                <button class="btn btn-primary" @click="joinPrivateRoom(user)">
                  Send Message
                </button>
              </div>

            </div>
          </div>
        </div>
        <div class="col-12 room" v-if="state.ws != null">
          <div class="input-group">
            <input
              v-model="state.roomInput"
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

        <div class="chat" v-for="(room, key) in state.rooms" :key="key">
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
import { onBeforeMount, reactive, computed } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";

export default {
  name: "Home",
  setup() {
    const router = useRouter();
    const store = useStore();
    const state = reactive({
      ws: null,
      serverUrl: "ws://localhost:5000/ws/v1",
      roomInput: null,
      rooms: [],
      user: {
        email: "",
      },
      users: [],
      currentUser: computed(() => store.state.auth.user),
      usersList: computed(() => state.users.filter(user => user.email != state.currentUser.email))
    });

    onBeforeMount(() => {
      if (!state.currentUser) {
        router.push("/login");
      } else {
        state.user.email = state.currentUser.email;
      }

      connectToWebsocket();
    });

    const connectToWebsocket = () => {
      state.ws = new WebSocket(state.serverUrl + "?email=" + state.user.email);
      state.ws.addEventListener("open", (event) => {
        onWebsocketOpen(event);
      });
      state.ws.addEventListener("message", (event) => {
        handleNewMessage(event);
      });
    };

    const onWebsocketOpen = (event) => {
      console.log("connected to WS!");
    };

    const handleNewMessage = (event) => {
      let data = event.data;
      data = data.split(/\r?\n/);

      for (let i = 0; i < data.length; i++) {
        let msg = JSON.parse(data[i]);
        switch (msg.action) {
          case "send-message":
            handleChatMessage(msg);
            break;
          case "user-join":
            handleUserJoined(msg);
            break;
          case "user-left":
            handleUserLeft(msg);
            break;
          case "room-joined":
            handleRoomJoined(msg);
            break;
          default:
            break;
        }
      }
    }

    const handleChatMessage = (msg) => {
      const room = findRoom(msg.target.id);
      if (typeof room !== "undefined") {
        room.messages.push(msg);
      }
    }

    const handleUserJoined =(msg) => {
      state.users.push(msg.sender);
    }

    const handleUserLeft = (msg) => {
      for (let i = 0; i < state.users.length; i++) {
        if (state.users[i].id == msg.sender.id) {
          state.users.splice(i, 1);
        }
      }
    }

    const handleRoomJoined = (msg) => {
      const room = msg.target;
      room.name = room.private ? msg.sender.name : room.name;
      room["messages"] = [];
      state.rooms.push(room);
    }

    const sendMessage = (room) =>{
      if (room.newMessage !== "") {
        state.ws.send(
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
    }

    const findRoom = (roomId) => {
      for (let i = 0; i < state.rooms.length; i++) {
        if (state.rooms[i].id === roomId) {
          return state.rooms[i];
        }
      }
    }

    const joinRoom = () =>{
      state.ws.send(
        JSON.stringify({ action: "join-room", message: state.roomInput })
      );
      state.roomInput = "";
    }

    const leaveRoom = (room) => {
      state.ws.send(JSON.stringify({ action: "leave-room", message: room.id }));

      for (let i = 0; i < state.rooms.length; i++) {
        if (state.rooms[i].id === room.id) {
          state.rooms.splice(i, 1);
          break;
        }
      }
    }

    const joinPrivateRoom = (room) => {
      state.ws.send(
        JSON.stringify({ action: "join-room-private", message: room.id })
      );
    }


    return {
      state,
      joinRoom,
      joinPrivateRoom,
      leaveRoom,
      sendMessage
    };
  }
};
</script>
