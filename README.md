# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Configuration

## Configuration

### Environment Variables

Copy `.env.template` to `.env` and fill in your values:

```bash
cp .env.template .env
```

### Rails Extensions

Add framework-level customizations to `lib/rails_ext/`:

```ruby
# lib/rails_ext/my_extension.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural 'media', 'media'
end
```

Files are auto-loaded by `config/initializers/rails_extensions.rb`.

### Data Migrations

Use data migrations for data changes (separate from schema):

```bash
rails generate data_migration AddInitialCategories
```

Run with: `rails data:migrate`

### Timezone Support

Users can set their timezone in preferences. The app automatically uses their timezone:

```ruby
@user.timezone       # => "America/New_York"
@user.time_zone     # => ActiveSupport::TimeZone object
Time.current         # Uses user's timezone in controllers
```

### Private Seeds

For local-only seed data, create `db/seeds_private.rb`:

```ruby
# db/seeds_private.rb (gitignored)
User.create!(email: "local@example.com", password: "secure")
```

Reference: `db/seeds_private.rb.example`

### Security

**Content Security Policy**: Configured in `config/initializers/content_security_policy.rb`
- Report-only mode by default (safe for development)
- Adjust policies as needed for your assets

**Permissions Policy**: Configured in `config/initializers/permissions_policy.rb`
- Disables camera, microphone, geolocation, etc.
- Allows fullscreen for same-origin