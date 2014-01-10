module ProtesteScaffold
  if defined?(Rails)
    require 'proteste_scaffold/engine'
    require "proteste_scaffold/railtie"
  end
end

require 'proteste_scaffold/import'
require 'proteste_scaffold/export'
require 'proteste_scaffold/orm_adapter/adapter'
require 'proteste_scaffold/definitions'
require 'proteste_scaffold/rails/routes'