# frozen_string_literal: true

require 'forwardable'
require 'bundler/setup'
require 'active_record'
require 'byebug'
require 'database_cleaner/active_record'

ActiveRecord::Base.logger = ActiveSupport::Logger.new(nil)
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Migration.create_table :it_operations do |t|
  t.integer :entity_id, null: false
  t.string :entity_class, null: false
  t.string :arguments
  t.string :operation, index: true
  t.boolean :processed, null: false, default: false
  t.boolean :successful, null: false, default: false
  t.text :result
  t.timestamps null: false
end

require 'it_operations/it_operation'
require 'it_operations'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
