<template>
<div>
  <b-input-group v-if="searchEnabled">
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
  <b-button v-if="fetchMoreEnabled" size="sm" id="fetchMore" class="float-right" variant="outline-primary" @click="fetchMore">Fetch more</b-button>
</div>
</template>

<script>
import allIngredientsQuery from '../../graphql/queries/listIngredients.graphql'
import deleteIngredientMutation from '../../graphql/mutations/deleteIngredient.graphql'

export default {
  name: 'ingredients-table',
  props: {
    perPage: { default: 10, type: Number },
    searchEnabled: { default: true, type: Boolean }
  },
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
      allIngredients: null
    }
  },
  computed: {
    fetchMoreEnabled() {
      return this.allIngredients && this.allIngredients.pageInfo.hasNextPage
    },
    nodes() {
      return (this.allIngredients) ? this.allIngredients.edges.map(edge => edge.node) : []
    }
  },
  apollo: {
    allIngredients: {
      query: allIngredientsQuery,
      variables() {
        return { first: this.perPage }
      },
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
    },
    fetchMore() {
      this.$apollo.queries.allIngredients.fetchMore({
        variables: {
          first: this.perPage,
          cursor: this.allIngredients.pageInfo.endCursor
        },
        updateQuery: (previousResult, { fetchMoreResult }) => {
          const prevRes = previousResult.listIngredients
          const res = fetchMoreResult.listIngredients

          return {
            listIngredients: {
              __typename: prevRes.__typename,
              edges: [...prevRes.edges, ...res.edges],
              pageInfo: res.pageInfo
            }
          }
        }
      })
    }
  }
}
</script>

<style>
  button#fetchMore {
    margin-bottom: 12px;
  }
</style>
