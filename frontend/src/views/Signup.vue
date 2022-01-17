<template>
  <section class="vh-100 gradient-custom">
    <div class="container py-5 h-100">
      <div class="row d-flex justify-content-center align-items-center h-100">
        <div class="col-12 col-md-8 col-lg-6 col-xl-5">
          <div class="card bg-dark text-white" style="border-radius: 1rem">
            <div class="card-body p-5 text-center">
              <form class="mb-md-5 mt-md-4 pb-5" name="form" @submit.prevent="submitForm">
                <h2 class="fw-bold mb-2 text-uppercase">Registration</h2>
                <p class="text-white-50 mb-5">
                  Please enter your email and password!
                </p>


                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="email">Email</label>
                  <input
                    v-model="form.email"
                    type="text"
                    class="form-control form-control-lg"
                    name="email"
                  />
                </div>

                <div class="form-group form-outline form-white mb-4">
                  <label class="form-label" for="password">Password</label>
                  <input
                    v-model="form.password"
                    type="password"
                    class="form-control form-control-lg"
                    name="password"
                  />
                </div>

                <button class="btn btn-outline-light btn-lg px-5" type="submit">
                  Sign Up
                </button>
              </form>

              <div>
                <p class="mb-0">
                  Do you have your account?
                  <router-link class="text-white-50 fw-bold" to="/login">Login</router-link >
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
export default {
  data() {
    return {
      form: {
        email: "",
        password: "",
      },
    };
  },
  methods: {
    submitForm() {
      this.axios
        .post("http://" + import.meta.env.VITE_API_URL+ "/api/v1/user/sign/up", this.form)
        .then((response) => {
          this.$router.push("/");
        })
        .catch((err) => {
          console.log(err)
        });
    },
  },
};
</script>

