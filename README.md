## Tem Açúcar API

[Tem Açúcar](http://temacucar.com) API, built with [Ruby](https://www.ruby-lang.org/) + [Pliny](https://github.com/interagent/pliny) + [JSON Schema](http://json-schema.org/).

### Installation

1. clone the project
2. run `gem install bundler` if not yet installed
3. run `bin/setup`

### Configuration

1. Copy `.env.sample` to `.env` to create development environment and set the config vars.
2. Copy `.env.sample` to `.env.test` to create test environment and set the config vars.
3. Copy `.env.sample` to `.env.production` to create production environment and set the config vars.

### Running tests

`rake`

### Running the server

`foreman start`

### Running the console

`foreman run bin/console`

### Running commands with environment loaded

`foreman run your_command`
