<template>
  <section class="vh-100 gradient-custom">
    <div class="container py-5 h-100">
      <div class="row d-flex justify-content-center align-items-center h-100">
        <div class="col-12 col-md-8 col-lg-6 col-xl-5">
          <div class="card bg-dark text-white" style="border-radius: 1rem">
            <div class="card-body p-5 text-center">
              <form class="mb-md-5 mt-md-4 pb-5" name="form" @submit.prevent="handleLogin">
                <h2 class="fw-bold mb-2 text-uppercase">Login</h2>
                <p class="text-white-50 mb-5">
                  Please enter your login and password!
                </p>


                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="email">Email</label>
                  <input
                    v-model="user.email"
                    type="text"
                    class="form-control form-control-lg"
                    name="email"
                  />
                </div>

                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="password">Password</label>
                  <input
                    v-model="user.password"
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
                  <router-link class="text-white-50 fw-bold" to="/signup">Sign Up</router-link >
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

export default {
  name: "Login",
  data() {
    return {
      user: new User("", ""),
      loading: false,
      message: "",
    };
  },
  computed: {
    loggedIn() {
      return this.$store.state.auth.status.loggedIn;
    },
  },
  created() {
    if (this.loggedIn) {
      this.$router.push("/");
    }
  },
  methods: {
    handleLogin() {
      this.loading = true;
      if (this.user.email && this.user.password) {
        this.$store.dispatch("auth/login", this.user).then(
          () => {
            this.$router.push("/");
          },
          (error) => {
            this.loading = false;
            this.message =
              (error.response && error.response.data) ||
              error.message ||
              error.toString();
          }
        );
      }
    },
  },
};
</script>

