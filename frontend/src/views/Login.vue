<template>
  <section class="vh-100 gradient-custom">
    <div class="container py-5 h-100">
      <div class="row d-flex justify-content-center align-items-center h-100">
        <div class="col-12 col-md-8 col-lg-6 col-xl-5">
          <div class="card bg-dark text-white" style="border-radius: 1rem">
            <div class="card-body p-5 text-center">
              <form
                class="mb-md-5 mt-md-4 pb-5"
                name="form"
                @submit.prevent="handleLogin"
              >
                <h2 class="fw-bold mb-2 text-uppercase">Login</h2>
                <p class="text-white-50 mb-5">
                  Please enter your login and password!
                </p>

                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="email">Email</label>
                  <input
                    v-model="state.user.email"
                    type="text"
                    class="form-control form-control-lg"
                    name="email"
                  />
                </div>

                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="password">Password</label>
                  <input
                    v-model="state.user.password"
                    type="password"
                    class="form-control form-control-lg"
                    name="password"
                  />
                </div>

                <button class="btn btn-outline-light btn-lg px-5" type="submit">
                  Login
                </button>
              </form>

              <div>
                <p class="mb-0">
                  Don't have an account?
                  <router-link class="text-white-50 fw-bold" to="/signup"
                    >Sign Up</router-link
                  >
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import User from "@/models/user";
import { onBeforeMount, reactive, computed } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";

export default {
  name: "Login",
  setup() {
    const router = useRouter();
    const store = useStore();
    const state = reactive({
      user: new User("", ""),
      loading: false,
      message: "",
      loggedIn: computed(() => store.state.auth.status.loggedIn),
    });

    onBeforeMount(() => {
      if (state.loggedIn) {
        router.push("/");
      }
    });

    const handleLogin = () =>{
      console.log(state.user.email, state.user.password)
      state.loading = true;
      if (state.user.email && state.user.password) {
        store.dispatch("auth/login", state.user).then(
          () => {
            //https://stackoverflow.com/questions/50629549/vue-router-this-router-push-not-working-on-methods
            router.go("/");
          },
          (error) => {
            console.log(error)
            state.loading = false;
            state.message =
              (error.response && error.response.data) ||
              error.message ||
              error.toString();
          }
        );
      }
    }
    return {
      state,
      handleLogin
    }
  }

};
</script>

