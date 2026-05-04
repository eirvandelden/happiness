DATA_MIGRATE_HELP = <<~HELP
  Data Migration Help
  ===================

  Data migrations are separate from schema migrations and are used for:
  - Populating new columns with default values
  - Transforming existing data
  - Adding or removing records
  - Complex data corrections

  Usage:
    rails generate data_migration AddInitialCategories
    rails data:migrate                    # Run all pending data migrations
    rails data:migrate:status              # Check data migration status
    rails data:migrate:down VERSION=20240101000000  # Rollback specific migration

  Files are stored in db/data/ and follow the same pattern as schema migrations.

  Example data migration:
  ---
  class AddInitialCategories < ActiveRecord::Migration[7.1]
    def change
      Category.create!(name: "Default") if Category.count.zero?
    end
  end
  ---
HELP

namespace :data do
  desc "Show data migration help and usage"
  task migrate_help: :environment do
    puts DATA_MIGRATE_HELP
  end
end
