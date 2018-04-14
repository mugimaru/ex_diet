<template>
<div>

  <apollo-errors-view variant="dismissible-alert" :error="error"></apollo-errors-view>
  <b-input-group v-if="searchEnabled">
    <b-form-input v-model="filter" placeholder="Search ingredients" @input="onSearchInput" @keyup.esc.native="clearSearch"  />
    <b-input-group-append>
      <b-btn variant="danger" :disabled="!filter" @click="clearSearch">Clear search</b-btn>
    </b-input-group-append>
  </b-input-group>
  <b-table bordered :items="nodes" :fields="fields" :sort-by="sortBy">
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
import allIngredientsQuery from "@/graphql/queries/listIngredients.graphql";
import deleteIngredientMutation from "@/graphql/mutations/deleteIngredient.graphql";

export default {
  name: "ingredients-table",
  props: {
    perPage: { default: 10, type: Number },
    searchEnabled: { default: true, type: Boolean }
  },
  data() {
    return {
      error: null,
      sortBy: "name",
      filter: null,
      queryFilter: null,
      fields: [
        { key: "name", sortable: true },
        { key: "protein", sortable: true },
        { key: "fat", sortable: true },
        { key: "carbonhydrate", sortable: true },
        { key: "energy", sortable: true },
        { key: "actions", sortable: false }
      ],
      allIngredients: null
    };
  },
  computed: {
    fetchMoreEnabled() {
      return this.allIngredients && this.allIngredients.pageInfo.hasNextPage;
    },
    nodes() {
      return this.allIngredients
        ? this.allIngredients.edges.map(edge => edge.node)
        : [];
    }
  },
  apollo: {
    allIngredients: {
      query: allIngredientsQuery,
      variables() {
        return { first: this.perPage, filter: this.queryFilter };
      },
      update: data => data.listIngredients,
      error(e) {
        this.error = e;
      }
    }
  },
  methods: {
    onSearchInput: _.debounce(function (){
      this.queryFilter = this.filter;
      this.refetch();
    }, 600),
    clearSearch() {
      this.filter = null;
      this.queryFilter = null;
      this.refetch();
    },
    refetch() {
      this.error = null;
      this.$apollo.queries.allIngredients.refetch();
    },
    editIngredient(item) {
      this.$emit("edit", Object.assign({}, item));
    },
    deleteIngredient(item) {
      this.error = null;
      this.$apollo
        .mutate({
          mutation: deleteIngredientMutation,
          variables: { id: item.id }
        })
        .then(result => {
          this.$emit("deleted", item);
          this.refetch();
        })
        .catch(error => {
          this.error = error;
        });
    },
    fetchMore() {
      this.error = null;
      this.$apollo.queries.allIngredients.fetchMore({
        variables: {
          first: this.perPage,
          filter: this.queryFilter,
          cursor: this.allIngredients.pageInfo.endCursor
        },
        updateQuery: (previousResult, { fetchMoreResult }) => {
          const prevRes = previousResult.listIngredients;
          const res = fetchMoreResult.listIngredients;

          return {
            listIngredients: {
              __typename: prevRes.__typename,
              edges: [...prevRes.edges, ...res.edges],
              pageInfo: res.pageInfo
            }
          };
        }
      });
    }
  }
};
</script>

<style>
button#fetchMore {
  margin-bottom: 12px;
}
</style>
