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

        <b-row>
          <b-col>
            <b-form-group label="Description:">
              <b-form-textarea rows="6" v-model="recipe.description"></b-form-textarea>
            </b-form-group>
          </b-col>
          <b-col v-html="compiledMarkdownDescription"></b-col>
        </b-row>
      </b-col>
    </b-row>

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
  </b-form>
</div>
</template>

<script>
import getRecipe from '../../graphql/queries/getRecipe.graphql'
import formRow from './form/Row.vue';
import updateRecipeMutation from '../../graphql/mutations/updateRecipe.graphql'
import marked from 'marked'

export default {
  name: 'recipes-edit',
  components: {
    'form-row': formRow
  },
  data () {
    return {
      getRecipe: null,
      recipe: null,
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
        weightCooked: this.recipe.weightCooked,
        description: this.recipe.description,
        recipeIngredients: this.recipe.recipeIngredients.map(function(ri) {
          return { weight: Number(ri.weight), ingredientId: ri.ingredient.id, id: ri.id }
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
      }
    }
  },
  methods: {
    onSubmit(e) {
      e.preventDefault()
      console.dir(this.recipe)
      this.$apollo.mutate({
        mutation: updateRecipeMutation,
        variables: {
          input: this.updateRecipeInput,
          id: this.$route.params['id']
        },
      }).then((result) => {
        this.recipe = this._.merge({}, result.data.node)
      }).catch((error) => {
        console.dir(error)
        this.error = error
      })
    },
    addIngredient(){
      this.recipe.recipeIngredients.push({
        ingredient: null
      })
    }
  }
}
</script>
