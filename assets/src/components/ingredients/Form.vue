<template>
<b-card no-body header-tag="header">
  <h6 slot="header" class="mb-0">
    <span v-if="ingredient.id"> Edit "{{ingredient.name}}"</span>
    <span v-else>New ingredient</span>
  </h6>

  <apollo-errors-view :error="error"></apollo-errors-view>

  <div class="card-body">
    <b-form @submit="onSubmit" @reset="onReset">

      <b-form-group label="Name:">
        <b-form-input type="text" v-model="ingredient.name" :state="!$v.ingredient.name.$invalid"></b-form-input>
      </b-form-group>

      <b-form-group label="Protein:">
        <b-form-input type="text" v-model="ingredient.protein" :state="!$v.ingredient.protein.$invalid"></b-form-input>
      </b-form-group>

      <b-form-group label="Fat:">
        <b-form-input type="text" v-model="ingredient.fat" :state="!$v.ingredient.fat.$invalid"></b-form-input>
      </b-form-group>

      <b-form-group label="Carbonhydrate:">
        <b-form-input type="text" v-model="ingredient.carbonhydrate" :state="!$v.ingredient.carbonhydrate.$invalid"></b-form-input>
      </b-form-group>

      <b-form-group label="Energy:">
        <b-form-input type="text" v-model="ingredient.energy" :state="!$v.ingredient.energy.$invalid"></b-form-input>
      </b-form-group>

      <b-button-group>
        <b-button type="submit" variant="primary" :disabled="$v.ingredient.$invalid">
          {{ingredient.id ? "Update ingredient" : "Create ingredient"}}
        </b-button>
        <b-button type="reset" variant="danger">Reset</b-button>
      </b-button-group>
    </b-form>
  </div>
</b-card>
</template>

<script>
import createIngredientMutation from '../../graphql/mutations/createIngredient.graphql'
import updateIngredientMutation from '../../graphql/mutations/updateIngredient.graphql'
import { required, minValue } from "vuelidate/lib/validators"

export default {
  name: 'ingredient-form',
  props: ['ingredient'],
  data () {
    return {
      error: null
    }
  },
  validations: {
    ingredient: {
      name: { required },
      protein: { minValue: minValue(0) },
      fat: { minValue: minValue(0) },
      carbonhydrate: { minValue: minValue(0) },
      energy: { minValue: minValue(0) }
    }
  },
  methods: {
    onReset(event){
      event.preventDefault()
      this.error = null
      this.$emit('reset')
    },
    onSubmit(event) {
      this.error = null
      const { name, protein, fat, carbonhydrate, energy } = this.ingredient

      let variables = { input: { name, protein, fat, carbonhydrate, energy} }
      let mutation = createIngredientMutation

      if(this.ingredient.id) {
        variables['id'] = this.ingredient.id
        mutation = updateIngredientMutation
      }

      this.performMutation(mutation, variables)
    },
    performMutation(mutation, variables) {
      this.$apollo.mutate({
        mutation: mutation,
        variables: variables,
      }).then((result) => {
        const event = this.ingredient.id ? 'updated' : 'created'
        this.$emit(event, this.ingredient)
      }).catch((error) => {
        this.error = error
      })
    }
  }
}
</script>
