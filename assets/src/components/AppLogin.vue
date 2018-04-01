<template>
  <div>
    <div>
      <b-form @submit="confirm">
        <b-list-group :show="hasErrors">
          <b-list-group-item variant="danger" v-for="error in gqlErrors">{{ error }}</b-list-group-item>
        </b-list-group>
        <br>

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
  </div>
</template>

<script>
import loginMutation from '../graphql/mutations/login.graphql'
import createUserMutation from '../graphql/mutations/createUser.graphql'

export default {
  name: "AppLogin",
  computed: {
    hasErrors() {
      return this.gqlErrors != null
    }
  },
  data() {
    return {
      email: "",
      login: true,
      password: "",
      gqlErrors: null
    };
  },
  methods: {
    confirm() {
      this.errors = null
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
          console.log(result)
          this.saveUserData(result.data.login.user, result.data.login.token)
        }).catch((error) => {
          this.handleGraphqlError(error)
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
          this.handleGraphqlError(error)
        })
      }
    },
    handleGraphqlError(error) {
      console.dir(error)
      this.gqlErrors = error.graphQLErrors.map(function(error) {
        return error.message
      })
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
