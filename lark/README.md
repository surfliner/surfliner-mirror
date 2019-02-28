# Lark

Lark is an authority control platform and API. It is a product of the
[Surfliner](https://gitlab.com/surfliner/surfliner) collaboration at the
University of California.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

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

[contributing]: ../CONTRIBUTING.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
