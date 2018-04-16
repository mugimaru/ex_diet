import { ApolloClient } from "apollo-client";
import { InMemoryCache } from "apollo-cache-inmemory";
import { ApolloLink } from "apollo-link";
import { HttpLink } from "apollo-link-http";
import VueApollo from "vue-apollo";

const httpLink = new HttpLink({
  uri:
    process.env.NODE_ENV == "production"
      ? "http://exdiet.tk/api/graphql"
      : "http://localhost:4000/api/graphql"
});

const authMiddleware = new ApolloLink((operation, forward) => {
  const token = localStorage.getItem("authToken");

  operation.setContext({
    headers: {
      authorization: token ? `Bearer ${token}` : null
    }
  });

  return forward(operation);
});

// Create the apollo client, with the Apollo caching.
const apolloClient = new ApolloClient({
  link: authMiddleware.concat(httpLink),
  cache: new InMemoryCache(),
  connectToDevTools: true
});

import { EventBus } from "./eventBus.js";
const apolloProvider = new VueApollo({
  defaultClient: apolloClient,
  watchLoading(state) {
    EventBus.$emit("apollo-global-loading-state", state);
  }
});

export { apolloProvider, VueApollo };
