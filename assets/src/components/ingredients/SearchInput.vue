<template>
<div>
  <div class="dropdown" id="ingredients-search-dropdown">

    <b-input-group>
      <b-input-group-prepend v-if="disabled">
        <b-btn variant="secondary" @click="startNewSearch">Edit</b-btn>
      </b-input-group-prepend>
      <b-input
        type="text"
        v-model="queryFilter"
        @focus.native="focused = true"
        @blur.native="onFocusLost"
        placeholder="Search an ingredient"
        :disabled="disabled"
        autocomplete="off">
      </b-input>
    </b-input-group>

    <div class="dropdown-menu" :class="{ show: (focused && searchable) }">
      <button class="dropdown-item" role="menuitem" type="button" v-if="allowAddNew && queryFilter" @click="onAddIngredientSelected">
        Add ingredient "{{queryFilter}}"
      </button>
      <b-dropdown-divider v-if="dropdownItems.length > 0 && queryFilter"></b-dropdown-divider>
      <b-dropdown-item-button v-for="item in dropdownItems" @click="onSelected(item)">
        {{item.title}}
      </b-dropdown-item-button>
    </div>
  </div>
</div>
</template>

<script>

import allIngredientsQuery from '../../graphql/queries/listIngredients.graphql'

export default {
  name: 'ingredient-search-input',
  data () {
    return {
      queryFilter: null,
      error: null,
      allIngredients: null,
      focused: false,
      disabled: false
    }
  },
  props: {
    perPage: { default: 15, type: Number },
    minInputLength: { default: 3, type: Number },
    allowAddNew: { default: true, type: Boolean }
  },
  computed: {
    searchable (){
      return this.queryFilter && this.queryFilter.length >= this.minInputLength
    },
    dropdownItems() {
      if(!this.allIngredients) { return [] }

      return this.allIngredients.edges.map(function(edge) {
        return { item: edge.node, title: edge.node.name }
      })
    }
  },
  apollo: {
    allIngredients: {
      query: allIngredientsQuery,
      variables() {
        let vars =  { first: this.perPage }
        if(this.queryFilter) { vars['filter'] = this.queryFilter }
        return vars
      },
      update: data => data.listIngredients,
      error(e) {
        this.error = e
      },
      skip () {
        return !this.searchable
      }
    }
  },
  methods: {
    startNewSearch(){
      if(this.disabled) {
        this.disabled = false
        this.queryFilter = null
        this.$emit('reset')
      }
    },
    onFocusLost(e) {
      setTimeout(() => this.focused = false, 100)
    },
    refetch() {
      this.error = null
      this.$apollo.queries.allIngredients.refetch()
    },
    onSelected(node) {
      this.disabled = true
      this.$emit('selected', node.item)
    },
    onAddIngredientSelected() {
      this.disabled = true
      this.$emit('add-new-selected', this.queryFilter)
    }
  }
}
</script>

<style>
  #ingredients-search-dropdown>.dropdown-menu {
    width: 100%;
  }
</style>
