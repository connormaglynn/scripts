ENV=${1?No environment specified}

# Set the environment-specific hostname for the oauth2 service
if [[ "$ENV" == "prod" ]]; then
  CLIENT=
  AUTH_HOST="https://sign-in.hmpps.service.justice.gov.uk"
  API_HOST="https://api.prison.service.justice.gov.uk"
elif [[ "$ENV" == "preprod" ]]
then
  echo "Need clientid and secret for this enviromnet"
  exit 1
elif [[ "$ENV" == "dev" ]]
then
  CLIENT=
  AUTH_HOST="https://sign-in-$ENV.hmpps.service.justice.gov.uk"
  API_HOST="https://api-$ENV.prison.service.justice.gov.uk"
else 
 echo "Please enter one of the following environments: dev/prepord/prod"
fi



# Get the token for the client name / secret and store it in the environment variable TOKEN
TOKEN_RESPONSE=$(curl -s -k -d "" -X POST "$AUTH_HOST/auth/oauth/token?grant_type=client_credentials&username=$USER" -H "Authorization: Basic $(echo -n $CLIENT | base64)")
TOKEN=$(echo "$TOKEN_RESPONSE" | jq -er .access_token)
if [[ $? -ne 0 ]]; then
  echo "Failed to read token from credentials response"
  echo "$TOKEN_RESPONSE"
  exit 1
fi

echo "Token: [ $TOKEN ]"
