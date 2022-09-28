# Internal Authentication API

This is an internal authentication API that can be used to authenticate users.


## API Documentation

1. *Create a new user*

To create a new user, send a `POST` request to `/api/users` as follows:

```
curl -X POST -H "Content-Type: application/json" \
    --data-raw '{"user": {"username": "example", "password": "StrongPasswoird123!"}}' \
    http://localhost:3000/users
```

*Note:* The password must meet the following requirements:
- Between 8-70 characters in length
- At least one uppercase character
- At least one lowercase character
- At least one special character
- At least one number

Successful requests will receive a 200 status code and the `username` of the created user. Unsuccessful requests will receive a `422` status code as well as the error message indicating what went wrong.

2. *Login with an existing user to obtain a token*

To consume authenticated resources on the api, clients need a token. To obtain this token, send a `POST` request to `/api/authentication/login`, passing in the username and password of an existing user as follows:

```
curl -X POST -H "Content-Type: application/json" \
    --data-raw '{"username": "example", "password": "StrongPasswiord123!"}' \
    http://localhost:3000/authentication/login
```

Succesful requests will receive a `200` status code as well as a token to be used for subsequent requests. The token expires after 2 hours. Unsuccesful requests will receive a `401` status code.

3. *Consume other resources on API*

Send a `GET` request to `/api/foo` making sure to pass in a valid non-expired token as a header:

```
curl -X GET http://localhost:3000/foo -H 'Authorization:<valid_token>'
```

Successful requests will receive a `200` status code. Unsuccesful requests will receive a `401` status code.


# Tests

To run the full suite of tests (unit and integration), do the following:

1. Pull the `master` branch
2. run `bundle` to install dependencies
3. run `rails db:create` to setup development and test databases
4. run `rails db:migrate` to run data migrations migrations.
5. run `rails db:migrate RAILS_ENV=test` to run migration sfor test env.
6. run `rspec spec/` to run the full suite of specs.

To manually test the API, do the following:

1. Ensure you have `redis` installed. `brew install redis`
2. Ensure you have `postgresql` installed. `brew install postgresql`
3. Start your redis server `brew services restart redis`.
4. start your rails server `rails s`.
5. Use your favorite api client to make API requests.
