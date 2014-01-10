# ProtesteScaffold


Proteste Scaffold its a meta-gem wich all developers in Proteste Company must use to make new projects. In general terms the gem install dependencies and custom generator using bootstrap.

Some other functions:

- Crud with datatable, export and import
- Versions of data saved in any model
- Fixed layout


## Requirements

- RVM with ruby 1.9.3
- Rails 3.2.13 in a general gemset
- Current gemset already set


## Installation and first app

Install ruby 1.9.3 in your rvm

    $ rvm install 1.9.3

Create and set a gemset for your application

    $ rvm use 1.9.3@first_application --create

Install rails

    $ gem install rails --version=3.2.13 --no-ri --no-rdoc

Create a new application

    $ rails new first_application

Now its time to configure the proteste_scaffold.
In your Gemfile comment the line (because our gem defines it)

    # gem 'jquery-rails'

Add this line to your application Gemfile:

    gem 'proteste_scaffold',    git: 'git@github.com:proteste/paf-scaffold.git'


Execute in your application root path:

    $ bundle

## Install the gem

    $ rails generate proteste_scaffold:install

If there are some conflict in this execution then you need to accept with Y

Run migrate:

    $ rake db:migrate

## Example
    
    $ rails g scaffold Category name
    $ rails g scaffold Color name
    $ rails g scaffold Accessory name
    $ rails g scaffold Specification name
    $ rails g scaffold ColorsProducts color:references product:references
    $ rails g scaffold AccessoriesProducts accessory:references product:references
    $ rails g scaffold ProductsSpecifications specification:references product:references
    $ rails g scaffold Product name published_at:date category:references colors:n_to_n_inline accessories:n_to_n_2_columns specifications:n_to_n_2_columns description:text
    $ rake db:migrate    
    $ rails s

## This gem is updated and your project isn't?

Update the gem and run install without the first install process

    $ bundle update
    $ rails g proteste_scaffold:install --skip-first-install


## Components

Command

    $ rails g scaffold Product name published_at:date category:references colors:n_to_n_inline accessories:n_to_n_2_columns specifications:n_to_n_2_columns description:text


If you need change after generated here are a few examples:

NxN two columns

    # <%= f.input :categories, :wrapper => :prepend do %>
    #     <div class="chosen-multiple-2-columns" id="nxn_categories" data-search-placeholder="<%= t('general.terms.multiple-select.search-placeholder') %>" data-deselect-all="<%= t('general.terms.multiple-select.deselect-all') %>"><%= f.association :categories %></div>
    # <% end %>

NxN inline

    # <%= f.association :categories, input_html: {class: 'span5 chosen-multiple'} %>

Datepicker

    # <%= f.input :published_at, as: :datepicker %>
