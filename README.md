# Decidim::CombinedBudgeting

**NOTE:** This module is no longer needed and is therefore deprecated. Since
Decidim core version 0.23 it has been possible to include multiple budgets
within a single budgeting component. This module was solving the same problem
scope and therefore you should migrate to using the core method instead.

[![Build Status](https://travis-ci.com/mainio/decidim-module-combined_budgeting.svg?branch=master)](https://travis-ci.com/mainio/decidim-module-combined_budgeting)
[![codecov](https://codecov.io/gh/mainio/decidim-module-combined_budgeting/branch/master/graph/badge.svg)](https://codecov.io/gh/mainio/decidim-module-combined_budgeting)

The gem has been developed by [Mainio Tech](https://www.mainiotech.fi/).

A [Decidim](https://github.com/decidim/decidim) module that makes it possible to
combine the budget voting from different components to a single combined voting
process to streamline the voting process. This will also hide all other parts of
the participatory space page except for the voting feature itself to make it
easier to understand for the users.

The actual budgeting components used by this module are the ones provided by the
core and they can exist in different participatory spaces, e.g. when the voting
process is separated by areas to different participatory spaces. This is not
necessary in order to use this module but it was built with this particular
aspect in mind.

This module is solely meant to ease up the voting process when a single voting
process has multiple voting components (`decidim-budgets` components). The
process works as follows:

1. The user signs in to the system, as the user needs to be signed in to perform
   the budgeting voting actions.
1. The user authorizes themselves with all the authorization methods required
   for the voting process. These can be configured for the voting process using
   this module. In case no authorizations are configured, this step is skipped.
1. The user is shown a list of all the possible voting components configured
   using this module.
1. The user picks the budget component where they want to vote (these can be
   e.g. areas of the city). In case there is only a single process, the user is
   redirected directly to that budget voting component without the selection
   phase. The available budgeting components shown to the user are only those
   where they are able to vote based on the component permissions.
1. The user performs the budget voting in the selected component.
1. The user is redirected back to the list. In case they can vote in other
   components as well, they can repeat the described process for all the
   components. Otherwise the user is shown a message indicated that they have
   completed the voting and a link to the voting they completed.

The combination of the budgeting components makes it possible to add the
following features to the actual process:

- Having a dedicated page which lists all the budgeting components for the
  combined process, to allow users to select their voting area directly from a
  single page or redirect the user directly to the desired budgeting component.
- Showing the user quick links to the voting process on the front page of the
  system for quick access to the voting process. This is done through the
  content blocks feature available in the core.

Development of this gem has been sponsored by the
[City of Helsinki](https://www.hel.fi/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-combined_budgeting"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_combined_budgeting:install:migrations
$ bundle exec rails db:migrate
```

## Usage

In order to use the module, you need to configure the combined processes first.
Browse to the admin panel of the system and you should see a new section in the
admin menu named "Combined budgeting". Go there.

Create a new combined process and define the details for the process:

- Name: the name of the process, visible e.g. in the process listing.
- Description: the description of the process, visible e.g. in the process
  listing.
- Slug: a unique URL slug that identifies the process. The process will be found
  under the `/budgeting/{slug}` URL where `{slug}` is the one that you define
  here.
- Authorizations: the authorizations the user needs to complete before accessing
  the list of the components. This can be empty in case no authorizations are
  required to perform the voting in the selected components.
- Components: the components that will be listed for the user where they can
  vote in.

Once the process is configured, go again to the editing page to publish the
process. After this, you will see a new menu item in the system front-end named
"Budgeting".

Browse to the bugdeting section of the site to test the module in action. You
will also note that the budget components will be shown without the process UI
overhead making it clearer for the user to perform the voting.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repositories also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ cd development_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-combined-budgeting

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
