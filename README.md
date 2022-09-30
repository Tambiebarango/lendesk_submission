# Internal Authentication API

This is an internal authentication API that can be used to authenticate users.

## Approach

In order to build this API out following the requirements, I'm using Rails as the platform (without any DB support of active record) and Redis for data storage. However, I still have models that are basically just pure ruby objects.

Since it's only an authentication app, I only have the `User` model. I have created a `ValidationConcern` that will take care of all validation issues for all models. These issues include

- presence
- uniqueness 
- complexity (for passwords)

The idea is that any new validation issue should be added to this concern, and the concern will be included in the model.

Next, I have a `RedisRecordConcern` that takes care of storing and retrieving records from `redis`. This concern has a `find_by` class method that can retrieve a record using the hash name it was stored under. It also has a `create` class method that will initialize the object after the individual models have run their specific validations. It will be the responsibility of the individual models that include `RedisRecordConcern` to call `save_to_redis` method BECAUSE the models will decide what the hash name will be. E.g. for `User` model, the hash name in redis is the model instance's `username method.

I've used `bcrypt` to hash the user's password, so at no point in time is the bare password available or stored. `BCrypt` has the ability though to compare raw strings to the hashed password and that's what I'm using to authenticate users.

When a new user creates a new login, the `User.create` call will hash their password and store in the redis db.

When a user attempts to login with username and password, I will initialze a temporary `User` record calling `User.new` and passing in the stored user's user name and a hash of the stored user's password and then call `.authenticate` on that instance to compare 
the password sent to the login endpoint against the hash.

Once authenticated, I will then provide the user with a `JWT` token that expires in 2 hours authenticating them for every other request in the api such as `GET /api/foo`.

Before every request I will authenticate the request by checking the headers for an `Authorization` header `JWT`. I decode the `JWT` and confirm that the user tied to the `JWT` exists in redis.

## Future solutions

This submission doesn't take backups of redis into account. However, in a future solution in order to back up redis and ensure that data stored there is persisted:

1. Set up cron job that will call `BGSAVE` on my redis instance and generate the redis dump file
2. Store this dump file in a remote location
3. On data loss, retrieve the backed up data from backup dump.


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
3. run `rspec spec/` to run the full suite of specs.

To manually test the API, do the following:

1. Ensure you have `redis` installed. `brew install redis`
2. Start your redis server `brew services restart redis`.
3. start your rails server `rails s`.
4. Use your favorite api client to make API requests as documented above.
