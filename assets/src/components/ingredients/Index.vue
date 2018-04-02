<template>
<b-row>
  <b-col cols="8">
    <b-input-group>
      <b-form-input v-model="filter" placeholder="Type to Search" />
      <b-input-group-append>
        <b-btn variant="danger" :disabled="!filter" @click="filter = ''">Clear search</b-btn>
      </b-input-group-append>
    </b-input-group>
    <b-table bordered :items="nodes" :fields="fields" :sort-by="sortBy" :filter="filter">
      <template slot="actions" slot-scope="row">
        <b-button-group size="sm">
          <b-button variant="outline-success" size="sm" @click.stop="editIngredient(row.item)"> Edit </b-button>
          <b-button variant="outline-danger" size="sm" @click.stop="deleteIngredient(row.item)"> Delete </b-button>
        </b-button-group>
      </template>
    </b-table>
  </b-col>

  <b-col>
    <b-card no-body header-tag="header">
      <h6 slot="header" class="mb-0">
        <span v-if="ingredient.id"> Edit "{{ingredient.name}}"</span>
        <span v-else>New ingredient</span>
      </h6>

      <b-list-group flush :show="gqlErrors">
        <b-list-group-item variant="danger" v-for="error in gqlErrors">{{ error }}</b-list-group-item>
      </b-list-group>

      <div class="card-body">
        <b-form @submit="createOrUpdateIngredient" @reset="resetIngredient">

          <b-form-group label="Name:">
            <b-form-input type="text" v-model="ingredient.name" required></b-form-input>
          </b-form-group>

          <b-form-group label="Protein:">
            <b-form-input type="number" v-model="ingredient.protein" required></b-form-input>
          </b-form-group>

          <b-form-group label="Fat:">
            <b-form-input type="number" v-model="ingredient.fat" required></b-form-input>
          </b-form-group>

          <b-form-group label="Carbonhydrate:">
            <b-form-input type="number" v-model="ingredient.carbonhydrate" required></b-form-input>
          </b-form-group>

          <b-form-group label="Energy:">
            <b-form-input type="number" v-model="ingredient.energy" required></b-form-input>
          </b-form-group>

          <b-button-group>
            <b-button type="submit" variant="primary">
              {{ingredient.id ? "Update ingredient" : "Create ingredient"}}
            </b-button>
            <b-button type="reset" variant="danger">Reset</b-button>
          </b-button-group>
        </b-form>
      </div>
    </b-card>
  </b-col>
</b-row>
</template>

<script>
import allIngredientsQuery from '../../graphql/queries/listIngredients.graphql'
import createIngredientMutation from '../../graphql/mutations/createIngredient.graphql'
import updateIngredientMutation from '../../graphql/mutations/updateIngredient.graphql'
import deleteIngredientMutation from '../../graphql/mutations/deleteIngredient.graphql'
import * as h from '../../helpers/graphql.js'

export default {
  name: 'ingredients-table',
  data () {
    return {
      ingredient: this.emptyIngredient(),
      gqlErrors: null,
      sortBy: 'name',
      filter: null,
      fields: [
        { key: 'name', sortable: true },
        { key: 'protein', sortable: true },
        { key: 'fat', sortable: true },
        { key: 'carbonhydrate', sortable: true },
        { key: 'energy', sortable: true },
        { key: 'actions', sortable: false }
      ],
      allIngredients: []
    }
  },
  computed: {
    nodes() {
      return (this.$data.allIngredients.length == 0) ? this.$data.allIngredients : this.$data.allIngredients.edges.map(edge => edge.node)
    }
  },
  apollo: {
    allIngredients: {
      query: allIngredientsQuery,
      update: data => data.listIngredients,
      error(e) {
        console.dir(e)
      }
    }
  },
  methods: {
    emptyIngredient() {
      return {
        id: null,
        name: '',
        protein: 0,
        fat: 0,
        carbonhydrate: 0,
        energy: 0
      }
    },
    resetIngredient () {
      this.ingredient = this.emptyIngredient()
    },
    editIngredient (item) {
      this.ingredient = Object.assign({}, item)
    },
    deleteIngredient(item){
      this.performMutation(deleteIngredientMutation, { id: item.id })
    },
    createOrUpdateIngredient() {
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
        this.resetIngredient()
        this.$apollo.queries.allIngredients.refetch()
      }).catch((error) => {
        this.gqlErrors = h.apolloErrorToHuman(error)
      })
    }
  }
}
</script>
