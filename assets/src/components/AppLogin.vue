<template>
<b-row align-h="center">
  <b-col cols="4">

    <b-card no-body no-header>
      <apollo-errors-view :error="error"></apollo-errors-view>

      <div class="card-body">
        <b-form @submit="confirm">
          <b-form-group label="Email address:">
            <b-form-input type="email" v-model="email" required placeholder="Enter email"></b-form-input>
          </b-form-group>

          <b-form-group label="Password:">
            <b-form-input type="password" v-model="password" required placeholder="Enter password"></b-form-input>
          </b-form-group>

          <b-button type="submit" variant="primary">
            {{login ? 'Login' : 'Register'}}
          </b-button>

          <b-button variant="link" @click="login = !login">
            {{login ? 'need to create an account?' : 'already have an account?'}}
          </b-button>
        </b-form>
      </div>
    </b-card>

  </b-col>
</b-row>
</template>

<script>
import loginMutation from '../graphql/mutations/login.graphql'
import createUserMutation from '../graphql/mutations/createUser.graphql'

export default {
  name: "AppLogin",
  data() {
    return {
      email: "",
      login: true,
      password: "",
      error: null
    };
  },
  methods: {
    confirm() {
      this.error = null
      const { email, password } = this.$data

      if (this.login) {
        this.$apollo.mutate({
          mutation: loginMutation,
          variables: {
            input: {
              email,
              password
            }
          }
        }).then((result) => {
          this.saveUserData(result.data.login.user, result.data.login.token)
        }).catch((error) => {
          this.error = error
        })
      } else {
        this.$apollo.mutate({
          mutation: createUserMutation,
          variables: {
            input: {
              email,
              password
            }
          }
        }).then((result) => {
          this.saveUserData(result.data.createUser.user, result.data.createUser.token)
        }).catch((error) => {
          this.error = error
        })
      }
    },
    saveUserData(user, token) {
      localStorage.setItem('authToken', token);
      localStorage.setItem('userEmail', user.email);
      this.$root.$data.userEmail = localStorage.getItem('userEmail');
      this.$router.push({path: '/'})
    }
  }
};
</script>
