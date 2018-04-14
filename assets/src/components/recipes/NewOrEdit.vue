<template>
<div>
  <apollo-errors-view variant="dismissible-alert" :error="error"></apollo-errors-view>
  <b-form v-if="recipe" @submit="onSubmit">
    <b-row>
      <b-col cols="2">
        <b-form-group label="Name:">
          <b-form-input type="text" v-model="recipe.name" :state="!$v.recipe.name.$invalid" ></b-form-input>
        </b-form-group>

        <b-form-group label="Weight cooked:">
          <b-form-input type="number" v-model="recipe.weightCooked"  :state="!$v.recipe.weightCooked.$invalid"></b-form-input>
        </b-form-group>


        <fieldset class="b-form-group form-group">
          <b-form-checkbox v-model="recipe.eaten" id="eaten"> Eaten </b-form-checkbox>
        </fieldset>

        <b-button type="submit" :block="true" variant="primary" :disabled="!!$v.recipe.$invalid">Submit recipe</b-button>
        <br/>
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
              :v="$v.recipe.recipeIngredients.$each[index]"
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
import getRecipe from "@/graphql/queries/getRecipe.graphql";
import formRow from "./form/Row.vue";
import updateRecipeMutation from "@/graphql/mutations/updateRecipe.graphql";
import createRecipeMutation from "@/graphql/mutations/createRecipe.graphql";
import marked from "marked";
import { EventBus } from "@/config/eventBus.js";
import { required, minValue } from "vuelidate/lib/validators";

function newRecipe() {
  return {
    weight: 0,
    name: "",
    description: "",
    recipeIngredients: []
  };
}

export default {
  name: "recipes-new-or-edit",
  components: {
    "form-row": formRow
  },
  data() {
    return {
      getRecipe: null,
      recipe: this.$route.params["id"] == "new" ? newRecipe() : null,
      error: null
    };
  },
  validations: {
    recipe: {
      weightCooked: { minValue: minValue(1) },
      name: { required },
      recipeIngredients: {
        $each: {
          weight: { minValue: minValue(1) },
          ingredient: {
            name: { required },
            protein: { minValue: minValue(0) },
            fat: { minValue: minValue(0) },
            carbonhydrate: { minValue: minValue(0) },
            energy: { minValue: minValue(0) }
          }
        }
      }
    }
  },
  computed: {
    compiledMarkdownDescription() {
      return marked(this.recipe.description || "", { sanitize: true });
    },
    updateRecipeInput() {
      return {
        name: this.recipe.name,
        eaten: this.recipe.eaten,
        weightCooked: Number(this.recipe.weightCooked),
        description: this.recipe.description,
        recipeIngredients: this.recipe.recipeIngredients.map(function(ri) {
          let riParams = { weight: Number(ri.weight) };
          if (ri.id) {
            riParams.id = ri.id;
          }

          if (ri.ingredient.id) {
            riParams.ingredientId = ri.ingredient.id;
          } else {
            riParams.ingredient = _.pick(
              ri.ingredient,
              "name",
              "protein",
              "fat",
              "carbonhydrate",
              "energy"
            );
          }

          return riParams;
        })
      };
    },
    totals() {
      let data = { protein: 0, fat: 0, carbonhydrate: 0, energy: 0 };
      if (!this.recipe || this.recipe.weightCooked == 0) {
        return data;
      }
      const weightCooked = this.recipe.weightCooked;
      let ingredientsWeight = 0;

      this.recipe.recipeIngredients.forEach(function(ri) {
        const weight = Number(ri.weight);

        if (weight > 0) {
          Object.keys(data).forEach(function(key) {
            data[key] += Number(ri.ingredient[key]) * weight / 100;
          });
          ingredientsWeight += weight;
        }
      });

      if (ingredientsWeight > 0) {
        Object.keys(data).forEach(function(key) {
          const prescision = key == "energy" ? 0 : 2;
          data[key] = (data[key] * weightCooked / ingredientsWeight).toFixed(
            prescision
          );
        });
      }

      return data;
    }
  },
  apollo: {
    getRecipe: {
      query: getRecipe,
      variables() {
        return { id: this.$route.params["id"] };
      },
      update: data => data.node,
      error(e) {
        this.error = e;
      },
      result(result) {
        this.recipe = this._.merge({}, result.data.node);
      },
      skip() {
        return (
          this.$route.params["id"] == "new" ||
          (this.recipe && this.recipe.id == this.$route.params.id)
        );
      }
    }
  },
  methods: {
    onSubmit(e) {
      e.preventDefault();
      let vars = { input: this.updateRecipeInput };
      let mutations = {
        createRecipe: createRecipeMutation,
        updateRecipe: updateRecipeMutation
      };
      let mutationName = null;

      if (this.$route.params["id"] == "new") {
        mutationName = "createRecipe";
      } else {
        vars.id = this.$route.params["id"];
        mutationName = "updateRecipe";
      }

      this.$apollo
        .mutate({
          mutation: mutations[mutationName],
          variables: vars
        })
        .then(result => {
          const created = this.$route.params.id == "new";
          EventBus.$emit(
            "notification",
            `Recipe "${this.recipe.name}" has been successfully ${
              created ? "created" : "updated"
            }.`
          );

          this.recipe = this._.merge({}, result.data[mutationName]);

          if (created) {
            this.$router.push({
              path: `/recipes/${result.data[mutationName].id}`
            });
          }
        })
        .catch(error => {
          this.error = error;
        });
    },
    addIngredient() {
      this.recipe.recipeIngredients.push({
        weight: 0,
        ingredient: {
          protein: 0,
          fat: 0,
          carbonhydrate: 0,
          energy: 0,
          name: ""
        }
      });
    }
  },
  beforeRouteUpdate(to, from, next) {
    next();

    if (this.$route.params.id == "new") {
      this.recipe = newRecipe();
    } else {
      if (this.recipe.id != this.$route.params.id) {
        this.recipe = null;
        this.$apollo.queries.getRecipe.refetch();
      }
    }
  }
};
</script>
