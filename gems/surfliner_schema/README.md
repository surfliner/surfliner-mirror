# surfliner_schema

## Installation

Add this line to your application's Gemfile:

```ruby
gem "surfliner_schema", path: "../gems/surfliner_schema"
```

And then execute:

    $ bundle install

## Local Development

You can use the local `Dockerfile` to build an image for testing changes to the gem.

You can build an image locally:

```sh
❯ cd gems/surfliner_schema
❯ docker build -t surfliner_schema .
```

By default, running the image will run the test suite:

```sh
❯ cd gems/surfliner_schema
❯ docker run --rm -it surfliner_schema:latest

Randomized with seed 41281
............................

Finished in 1.74 seconds (files took 0.835 seconds to load)
28 examples, 0 failures
```

You can also volume mount your local code into the image, for quicker iterative development test running tests:

```sh
❯ cd gems/surfliner_schema
❯ docker run --rm -it --volume "$(pwd)/app" surfliner_schema:latest
```


