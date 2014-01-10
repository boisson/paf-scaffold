require 'rails'
module ProtesteScaffold
  class Engine < Rails::Engine
    require 'jquery-rails'
    require 'twitter-bootstrap-rails'
    require 'simple_form'
    require 'will_paginate'
    require 'paperclip'
    require 'ckeditor'
    require 'paper_trail'
    require 'roo'
    require 'simple_xlsx'
    require 'acts_as_xlsx'
    require 'prawn'
    require 'ransack'
  end
end