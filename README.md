# Internal Authentication API

This is an internal authentication API that can be used to authenticate users.

## Approach

In order to build this API out following the requirements, I'm using Rails as the platform (without any DB support of active record) and Redis for data storage. However, I still have models that are basically just pure ruby objects.

Since it's only an authentication app, I only have the `User` model. I have used custom validators that inherit from `ActiveModel::EachValidator` to perform model validation on the user's `username` and `password`.

Next, I have a `RedisRecordConcern` that takes care of storing and retrieving records from `redis`. This concern has a `find` class method that can retrieve a record using a primary key (pk). The user model's pk is `username` and records are stored in redis as `User-<username>`. 

It also has a `create` class method that will initialize the object after the individual models have run their specific validations. It will be the responsibility of the individual models that include `RedisRecordConcern` to call `save_to_redis` method BECAUSE the models will decide what the hash name will be. E.g. for `User` model, the hash name in redis is the model instance's `username` method with `User-` prefixed to it.

I've used `bcrypt` to hash the user's password, so at no point in time is the bare password available or stored. `BCrypt` has the ability to compare raw strings to the hashed password and that's what I'm using to authenticate users.

When a new user creates a new login, the `User.create` call will hash their password and store in the redis db once the complexity of the password and uniqueness of the username have been validated. Note the `hset` call that stores the user in redis is wrapped in a transaction to prevent race conditions that will break the uniqueness of usernames in the database after the uniqueness validation has run at both the model and database level. More on this in *Limitations* section.

When a user attempts to login with username and password, I will initialze a temporary `User` object calling `User.new` and passing in the stored user's user name and a hash of the stored user's password and then call `.correct_password?` on that instance to compare the password sent to the login endpoint against the hash.

Once authenticated, I will then provide the user with a `JWT` token that expires in 2 hours authenticating them for every other request in the api such as `GET /api/foo`.

Before every request I will authenticate the request by checking the headers for an `Authorization` header `JWT`. I decode the `JWT` and confirm that the user tied to the `JWT` exists in redis.


## Future solutions

This submission doesn't take backups of redis into account. However, in a future solution in order to back up redis and ensure that data stored there is persisted:

1. Set up cron job that will call `BGSAVE` on my redis instance and generate the redis dump file
2. Store this dump file in a remote location
3. On data loss, retrieve the backed up data from backup dump.

### Limitations 

- Race conditions: In order to enforce the uniqueness of primary keys (`#{Model}-{record.pk}`) even in the event of a race condition, I have wrapped every transaction that creates a record (`hset`) in redis in a redis transaction. This will ensure that whilst writing to redis, redis doesn't accept any other requests. This has the potential to slow down the application; however, it's a risk worth taking to preserve uniqueness of primary keys. Before the transaction begins, a uniqueness check will be done at the database level as well. 

## API Documentation

1. *Create a new user*

To create a new user, send a `POST` request to `/api/users` as follows:

```
curl -X POST -H "Content-Type: application/json" \
    --data-raw '{"user": {"username": "example", "password": "StrongPasswoird123!"}}' \
    http://localhost:3000/api/users
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
    http://localhost:3000/api/authentication/login
```

Succesful requests will receive a `200` status code as well as a token to be used for subsequent requests. The token expires after 2 hours. Unsuccesful requests will receive a `401` status code.

3. *Consume other resources on API*

Send a `GET` request to `/api/foo` making sure to pass in a valid non-expired token as a header:

```
curl -X GET http://localhost:3000/api/foo -H 'Authorization:<valid_token>'
```

Successful requests will receive a `200` status code. Unsuccesful requests will receive a `401` status code.


## Tests

To run the full suite of tests (unit and integration), do the following:

1. Pull the `master` branch
2. run `bundle` to install dependencies
3. run `rspec spec/` to run the full suite of specs.

To manually test the API, do the following:

1. Ensure you have `redis` installed. `brew install redis`
2. Start your redis server `brew services start redis`.
3. Generate a secret key, or get your default rails secret key
4. Create a `_env.rb` file under `config/` and add 
```ruby
ENV["SECRET_KEY"] = <your secret key>
```
5. start your rails server `rails s`.
6. Use your favorite api client to make API requests as documented above.


## Dependencies

- JWT: `JWT` is used for generating authentication tokens.
- Bcrypt: `Bcrypt` is used for hashing user passwords before storing in DB
- Redis: `Redis` is used for data storage
- Mock Redis: `MockRedis` is used for mocking redis during tests
- ActiveModel: `ActiveModel` is used for validations on the pure ruby object models.
