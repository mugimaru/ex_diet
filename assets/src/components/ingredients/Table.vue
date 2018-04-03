<template>
<div>
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
</div>
</template>

<script>
import allIngredientsQuery from '../../graphql/queries/listIngredients.graphql'
import deleteIngredientMutation from '../../graphql/mutations/deleteIngredient.graphql'

export default {
  name: 'ingredients-table',
  data () {
    return {
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
      return (this.allIngredients.length == 0) ? this.allIngredients : this.allIngredients.edges.map(edge => edge.node)
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
    refetch() {
      this.$apollo.queries.allIngredients.refetch()
    },
    editIngredient (item) {
      this.$emit('edit', Object.assign({}, item))
    },
    deleteIngredient(item){
      this.$apollo.mutate({
        mutation: deleteIngredientMutation,
        variables: { id: item.id },
      }).then((result) => {
        this.refetch()
      }).catch((error) => {
        console.dir(e)
      })
    }
  }
}
</script>
