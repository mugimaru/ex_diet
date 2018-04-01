import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink } from 'apollo-link';
import { HttpLink } from 'apollo-link-http';
import VueApollo from 'vue-apollo';

const httpLink = new HttpLink({
  uri: 'http://localhost:4000/api/graphql'
});

const authMiddleware = new ApolloLink((operation, forward) => {
  const token = localStorage.getItem('authToken');

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

const apolloProvider = new VueApollo({
  defaultClient: apolloClient
});

export {apolloProvider, VueApollo}
