# Rails Extensions

This directory contains framework-level customizations and extensions.

## Purpose

Use this directory for:
- Custom inflections (pluralization rules)
- ActiveRecord extensions
- ActionController enhancements
- Module mixins and concerns that extend Rails itself

## Pattern

Each file in this directory is automatically required by the initializer at `config/initializers/rails_extensions.rb`.

## Example: Custom Inflections

Create `lib/rails_ext/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural 'media', 'media'
  inflect.singular 'media', 'media'
  inflect.irregular 'person', 'people'
  inflect.uncountable %w(equipment)
end
```

## Not for App Code

This is NOT for application-level concerns. Use instead:
- `app/models/` for models and model concerns
- `app/controllers/` for controllers and controller concerns
- `lib/` for utility classes and helper modules
