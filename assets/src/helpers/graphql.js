function apolloErrorMessages (error) {
  return error.graphQLErrors.map(function (e){
    if(e.code != "validation_error") { return e.message; }
    return Object.keys(e.fields).map(key => `${key}: ${e.fields[key].join(', ')}`);
  }).reduce((a, b) => a.concat(b));
};

export { apolloErrorMessages }
