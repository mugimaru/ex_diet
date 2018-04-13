<template>
<div>
  <apollo-errors-view variant="dismissible-alert" :error="error"></apollo-errors-view>
  <b-row>
    <b-col cols="2">
      <b-form-checkbox v-model="excludeEaten"> Exclude eaten </b-form-checkbox>
    </b-col>
    <b-col>
  <b-input-group v-if="searchEnabled">
    <b-form-input v-model="filter" placeholder="Search recipes" />
    <b-input-group-append>
      <b-btn variant="success" :disabled="!filter || filter == queryFilter" @click="doSearch">Search</b-btn>
      <b-btn variant="danger" :disabled="!filter" @click="clearSearch">Clear search</b-btn>
    </b-input-group-append>
  </b-input-group>
    </b-col>
  </b-row>
  <b-table responsive bordered :items="nodes" :fields="fields" :sort-by="sortBy">
    <template slot="HEAD_actions" slot-scope="actions">
      <b-button variant="outline-primary" block size="sm" @click.stop="addNewRecipe">Add new recipe</b-button>
    </template>
    <template slot="protein" slot-scope="data"> {{Number.parseFloat(data.item.protein).toFixed(2)}} </template>
    <template slot="fat" slot-scope="data"> {{Number.parseFloat(data.item.fat).toFixed(2)}} </template>
    <template slot="carbonhydrate" slot-scope="data"> {{Number.parseFloat(data.item.carbonhydrate).toFixed(2)}} </template>
    <template slot="energy" slot-scope="data"> {{Number.parseFloat(data.item.energy).toFixed(0)}} </template>
    <template slot="actions" slot-scope="row">
      <b-button-group size="sm">
        <b-button variant="outline-secondary" size="sm" @click.stop="row.toggleDetails">
          {{ row.detailsShowing ? 'Hide' : 'Show'}} Details
        </b-button>
        <b-button variant="outline-success" size="sm" :to="'/recipes/' + row.item.id"> Edit </b-button>
        <b-button variant="outline-danger" size="sm" @click.stop="deleteRecipe(row.item)"> Delete </b-button>
      </b-button-group>
    </template>

    <template slot="row-details" slot-scope="row">
      <b-table small :fields="detailsFields" :items="row.item.recipeIngredients">
        <template slot="name" slot-scope="data"> {{data.item.ingredient.name}} </template>
        <template slot="protein" slot-scope="data"> {{Number.parseFloat(data.item.ingredient.protein).toFixed(2)}} </template>
        <template slot="fat" slot-scope="data"> {{Number.parseFloat(data.item.ingredient.fat).toFixed(2)}} </template>
        <template slot="carbonhydrate" slot-scope="data"> {{Number.parseFloat(data.item.ingredient.carbonhydrate).toFixed(2)}} </template>
        <template slot="energy" slot-scope="data"> {{Number.parseFloat(data.item.ingredient.energy).toFixed(0)}} </template>
      </b-table>
    </template>
  </b-table>
  <b-button v-if="fetchMoreEnabled" size="sm" id="fetchMore" class="float-right" variant="outline-primary" @click="fetchMore">Fetch more</b-button>
</div>
</template>

<script>
import listRecipesQuery from '@/graphql/queries/listRecipes.graphql'
import deleteRecipeMutation from '@/graphql/mutations/deleteRecipe.graphql'
import { EventBus } from '@/config/eventBus.js'

export default {
  name: 'recipes-index',
  props: {
    perPage: { default: 10, type: Number },
    searchEnabled: { default: true, type: Boolean }
  },
  data () {
    return {
      error: null,
      sortBy: 'name',
      filter: null,
      excludeEaten: false,
      queryFilter: null,
      detailsFields: [
        { key: 'name', sortable: true },
        { key: 'weight', sortable: true },
        { key: 'protein', sortable: true },
        { key: 'fat', sortable: true },
        { key: 'carbonhydrate', sortable: true },
        { key: 'energy', sortable: true }
      ],
      fields: [
        { key: 'name', sortable: true },
        { key: 'weightCooked', sortable: true },
        { key: 'protein', sortable: true },
        { key: 'fat', sortable: true },
        { key: 'carbonhydrate', sortable: true },
        { key: 'energy', sortable: true },
        { key: 'actions', sortable: false }
      ],
      listRecipes: null
    }
  },
  computed: {
    fetchMoreEnabled() {
      return this.listRecipes && this.listRecipes.pageInfo.hasNextPage
    },
    nodes() {
      return (this.listRecipes) ? this.listRecipes.edges.map(edge => Object.assign({_showDetails: false}, edge.node)) : []
    }
  },
  apollo: {
    listRecipes: {
      query: listRecipesQuery,
      variables() {
        let params = { first: this.perPage }
        if(this.queryFilter) { params.filter = this.queryFilter }
        if(this.excludeEaten) { params.eaten = false }

        return params
      },
      error(e) {
        this.error = e
      }
    }
  },
  methods: {
    doSearch() {
      this.queryFilter = this.filter
      this.refetch()
    },
    clearSearch() {
      this.filter = null
      this.queryFilter = null
      this.refetch()
    },
    refetch() {
      this.error = null
      this.$apollo.queries.listRecipes.refetch()
    },
    addNewRecipe(){
      this.$router.push({path: '/recipes/new'})
    },
    deleteRecipe(item){
      this.error = null
      this.$apollo.mutate({
        mutation: deleteRecipeMutation,
        variables: { id: item.id },
      }).then((result) => {
        EventBus.$emit('notification', `Recipe "${item.name}" has been successfully deleted.`)
        this.refetch()
      }).catch((error) => {
        this.error = error
      })
    },
    fetchMore() {
      this.error = null
      this.$apollo.queries.listRecipes.fetchMore({
        variables: {
          first: this.perPage,
          filter: this.queryFilter,
          cursor: this.listRecipes.pageInfo.endCursor
        },
        updateQuery: (previousResult, { fetchMoreResult }) => {
          const prevRes = previousResult.listRecipes
          const res = fetchMoreResult.listRecipes

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
  },
  watch: {
    excludeEaten: function(n, o) {
      if(n) { this.refetch() }
    }
  }
}
</script>


<style>
  th:nth-child(7){
    width: 220px !important;
  }
</style>
