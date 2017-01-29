# OmniChat

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `yarn`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

# Test Elm

Install `elm-test` CLI (node package) if not yet installed:

    $ yarn global add elm-test

Run tests:

    $ cd test/static/elm
    $ elm-test Main.elm


## Release

Bump application version in `mix.exs` (i.e.: 0.3.3) and run as user `elixir`:

    $ cd dev/omni_chat
    $ git pull
    $ brunch build && mix do phoenix.digest, compile, release
    $ cp -r rel/omni_chat/releases/0.3.3/ /app/releases/
    $ cd /app
    $ ./bin/omni_chat upgrade 0.3.3
