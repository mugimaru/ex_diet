<template>
  <div>
    <div
      class="dropdown"
      id="ingredients-search-dropdown"
    >

      <b-input-group>
        <b-input-group-prepend v-if="disabled">
          <b-btn
            tabindex="-1"
            :size="size"
            variant="secondary"
            @click="startNewSearch"
          >Edit</b-btn>
        </b-input-group-prepend>
        <b-input
          ref="input"
          :size="size"
          type="text"
          v-model="queryFilter"
          @keyup.prevent.enter="onEnterKeyUp"
          @focus.native="onFocus"
          @blur.native="onFocusLost"
          placeholder="Search an ingredient"
          :disabled="disabled"
          :state="state"
          autocomplete="off"
        >
        </b-input>
      </b-input-group>

      <div
        class="dropdown-menu"
        :class="{ show: (focused && searchable) }"
      >
        <button
          class="dropdown-item"
          role="menuitem"
          type="button"
          v-if="allowAddNew && queryFilter"
          @click="onAddIngredientSelected"
        >
          Add ingredient "{{queryFilter}}"
        </button>
        <b-dropdown-divider v-if="allowAddNew && dropdownItems.length > 0 && queryFilter"></b-dropdown-divider>
        <b-dropdown-item-button
          v-for="(item, i) in dropdownItems"
          :key="i"
          @click="onSelected(item)"
        >
          {{item.title}}
        </b-dropdown-item-button>
        <b-dropdown-item-button v-if="!allowAddNew && dropdownItems.length === 0">
          Nothing found
        </b-dropdown-item-button>
      </div>
    </div>
  </div>
</template>

<script>
import allIngredientsQuery from '@/graphql/queries/listIngredients.graphql';

export default {
  name: 'ingredient-search-input',
  data() {
    return {
      queryFilter: this.value ? this.value.name : null,
      error: null,
      allIngredients: null,
      focused: false,
      disabled: !!this.value && !!this.value.id,
    };
  },
  props: {
    perPage: { default: 15, type: Number },
    minInputLength: { default: 0, type: Number },
    allowAddNew: { default: true, type: Boolean },
    value: { type: Object },
    state: { type: Boolean },
    size: { type: String, default: 'md' },
  },
  computed: {
    searchable() {
      return (this.minInputLength === 0 || (this.queryFilter && this.queryFilter.length >= this.minInputLength));
    },
    dropdownItems() {
      if (!this.allIngredients) {
        return [];
      }

      return this.allIngredients.edges.map((edge) => ({
        item: edge.node,
        title: edge.node.name,
      }));
    },
  },
  apollo: {
    allIngredients: {
      query: allIngredientsQuery,
      variables() {
        const vars = { first: this.perPage };
        if (this.queryFilter) {
          vars.filter = this.queryFilter;
        }
        return vars;
      },
      update: (data) => data.listIngredients,
      error(e) {
        this.error = e;
      },
      skip() {
        return !this.searchable || this.disabled;
      },
    },
  },
  methods: {
    focus() {
      this.$refs.input.focus();
    },
    startNewSearch() {
      if (this.disabled) {
        this.disabled = false;
        this.queryFilter = null;
        this.$emit('input', {});
      }
    },
    onFocus() {
      this.focused = true;
    },
    onFocusLost() {
      setTimeout(() => (this.focused = false), 100);
      this.$emit('focusLost');
    },
    onSelected(node) {
      this.disabled = true;
      this.queryFilter = node.item.name;
      this.$emit('input', node.item);
    },
    onAddIngredientSelected() {
      this.disabled = true;
      this.$emit('input', {
        name: this.queryFilter,
        weight: 0,
        carbonhydrate: 0,
        protein: 0,
        fat: 0,
        energy: 0,
      });
    },
    onEnterKeyUp() {
      if (this.dropdownItems.length === 0) {
        this.onAddIngredientSelected();
      }
    },
  },
};
</script>

<style>
#ingredients-search-dropdown > .dropdown-menu {
  width: 100%;
}
</style>
