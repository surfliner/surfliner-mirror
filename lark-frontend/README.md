# lark-frontend
Lark frontend - project to demonstrate using the Javascript framework [VueJS](https://vuejs.org/)
 to develop the frontend for Lark.

## Prerequisites

Install and start [Lark](https://gitlab.com/surfliner/surfliner/tree/master/lark):

1. [`Solr`][solr] version >= 5.x
1. [`PostgreSQL`][postgres]

```
$ rackup config.ru
```

## Project setup
```
cd lark-frontend
```

Install `npm`:
```
npm install
```

### Configure Lark URL
Edit `.env`:
```
VUE_APP_ROOT_API=http://localhost:9292/
```

### Compiles and hot-reloads for development
```
npm run serve
```

The frontend will be available at http://localhost:8080/.

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Running with Docker
You will need Docker installed on your host/local system.
To setup a development environment:
1. `docker build -t lark-frontend:latest .`  to build images
1. `docker run -it -p 8080:80 --rm --name lark-frontend lark-frontend:latest`  to run dev environment
1. Access the `lark` API on `http://localhost:8080`

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).


[solr]: http://lucene.apache.org/solr/
[postgres]: https://www.postgresql.org/
