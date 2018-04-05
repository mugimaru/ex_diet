<template>
<div>
  <apollo-errors-view variant="dismissible-alert" :error="error"></apollo-errors-view>

  <b-form v-if="recipe" @submit="onSubmit">
    <b-row>
      <b-col cols="2">
        <b-form-group label="Name:">
          <b-form-input type="text" v-model="recipe.name" required></b-form-input>
        </b-form-group>

        <b-form-group label="Weight cooked:">
          <b-form-input type="number" v-model="recipe.weightCooked" required></b-form-input>
        </b-form-group>

        <b-button type="submit" :block="true" variant="primary">Submit recipe</b-button>
      </b-col>

      <b-col cols="10">

        <table class="table table-bordered" id="ri-form">
          <thead>
            <th>Ingredient</th>
            <th>Weight</th>
            <th>Protein</th>
            <th>Fat</th>
            <th>Carbonhydrate</th>
            <th>Energy</th>
            <th></th>
          </thead>
          <tbody>
            <form-row
              v-for="(ri, index) in recipe.recipeIngredients"
              :key="index"
              @delete="recipe.recipeIngredients.splice(index, 1)"
              v-model="recipe.recipeIngredients[index]">
            </form-row>
          </tbody>
          <tfoot>
            <th colspan="2">
              <b-button variant="success" @click="addIngredient">Add ingredient</b-button>
            </th>
            <th>{{totals.protein}}</th>
            <th>{{totals.fat}}</th>
            <th>{{totals.carbonhydrate}}</th>
            <th>{{totals.energy}}</th>
          </tfoot>
        </table>
      </b-col>
    </b-row>


    <b-card header="Recipe description">
      <b-row>
        <b-col>
          <b-form-textarea rows="12" v-model="recipe.description"></b-form-textarea>
        </b-col>
        <b-col v-html="compiledMarkdownDescription"></b-col>
      </b-row>
    </b-card>
  </b-form>
</div>
</template>

<script>
import getRecipe from '../../graphql/queries/getRecipe.graphql'
import formRow from './form/Row.vue';
import updateRecipeMutation from '../../graphql/mutations/updateRecipe.graphql'
import createRecipeMutation from '../../graphql/mutations/createRecipe.graphql'
import marked from 'marked'
function newRecipe(){
  return {
    weight: 0,
    name: "",
    description: "",
    recipeIngredients: []
  }
}

export default {
  name: 'recipes-new-or-edit',
  components: {
    'form-row': formRow
  },
  data () {
    return {
      getRecipe: null,
      recipe: (this.$route.params['id'] == 'new') ? newRecipe() : null,
      error: null
    }
  },
  computed: {
    compiledMarkdownDescription(){
      return marked(this.recipe.description, { sanitize: true })
    },
    updateRecipeInput(){
      return {
        name: this.recipe.name,
        weightCooked: Number(this.recipe.weightCooked),
        description: this.recipe.description,
        recipeIngredients: this.recipe.recipeIngredients.map(function(ri) {
          let riParams = { weight: Number(ri.weight) }
          if(ri.id) { riParams.id = ri.id }

          if(ri.ingredient.id) {
            riParams.ingredientId = ri.ingredient.id
          } else {
            riParams.ingredient = _.pick(ri.ingredient, 'name', 'protein', 'fat', 'carbonhydrate', 'energy')
          }

          return riParams
        })
      }
    },
    totals () {
      let data = {protein: 0, fat: 0, carbonhydrate: 0, energy: 0}
      if(!this.recipe || this.recipe.weightCooked == 0) { return data }
      const weightCooked = this.recipe.weightCooked
      let ingredientsWeight = 0

      this.recipe.recipeIngredients.forEach(function(ri) {
        const weight = Number(ri.weight)

        if(weight > 0) {
          Object.keys(data).forEach(function(key) {
            data[key] += Number(ri.ingredient[key]) * weight / 100
          })
          ingredientsWeight += weight
        }
      })

      if(ingredientsWeight > 0) {
        Object.keys(data).forEach(function(key) {
          const prescision = key == 'energy' ? 0 : 2
          data[key] = (data[key] * weightCooked / ingredientsWeight).toFixed(prescision)
        })
      }

      return data
    }
  },
  apollo: {
    getRecipe: {
      query: getRecipe,
      variables() {
        return { id: this.$route.params['id'] }
      },
      update: data => data.node,
      error(e) {
        this.error = error
      },
      result(result) {
        this.recipe = this._.merge({}, result.data.node)
      },
      skip () {
        return this.$route.params['id'] == 'new'
      }
    }
  },
  methods: {
    onSubmit(e) {
      e.preventDefault()
      let vars = { input: this.updateRecipeInput }
      let mutations = { createRecipe: createRecipeMutation, updateRecipe: updateRecipeMutation }
      let mutationName = null

      if(this.$route.params['id'] == 'new') {
        mutationName = 'createRecipe'
      } else {
        vars.id = this.$route.params['id']
        mutationName = 'updateRecipe'
      }

      this.$apollo.mutate({
        mutation: mutations[mutationName],
        variables: vars,
      }).then((result) => {
        this.recipe = this._.merge({}, result.data[mutationName])
      }).catch((error) => {
        console.dir(error)
        this.error = error
      })
    },
    addIngredient(){
      this.recipe.recipeIngredients.push({
        weight: 0,
        ingredient: { protein: 0, fat: 0, carbonhydrate: 0, energy: 0, name: "" }
      })
    }
  },
  beforeRouteUpdate (to, from, next) {
    next()

    if(this.$route.params.id == 'new') {
      this.recipe = newRecipe()
    } else {
      this.recipe = null
      this.$apollo.queries.getRecipe.refetch()
    }
  }
}
</script>
