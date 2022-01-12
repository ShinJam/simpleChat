<template>
    <div class="vue-tempalte">
        <form @submit.prevent="submitForm">
            <h3>Sign Up</h3>

            <div class="form-group">
                <label>Email address</label>
                <input type="email" class="form-control form-control-lg" v-model="form.email"/>
            </div>

            <div class="form-group">
                <label>Password</label>
                <input type="password" class="form-control form-control-lg" v-model="form.password"/>
            </div>

            <button type="submit" class="btn btn-dark btn-lg btn-block">Sign Up</button>

            <p class="forgot-password text-right">
                Already registered
                <router-link :to="{name: 'login'}">sign in?</router-link>
            </p>
        </form>
    </div>
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
        .post("http://localhost/api/v1/user/sign/up", this.form)
        .then((response) => {
          console.log(response.data);
        })
        .catch((err) => {
          console.log(err)
        });
    },
  },
};
</script>
