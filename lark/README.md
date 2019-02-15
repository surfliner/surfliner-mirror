# Lark

Lark is an authority control platform.

This is a product of the [Surfliner](https://gitlab.com/surfliner/surfliner) collaboration.

## Starting Up

`rackup config.ru`

Or run shotgun to start a server so that the code change is automatic reloaded in development:

`shotgun config.ru`

## Development

```sh
git clone git@gitlab.com:surfliner/surfliner.git
cd surfliner/lark

bundle install
```

### Running the test suite

`bundle exec rspec`
