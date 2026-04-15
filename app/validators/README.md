# Custom Validators

This directory contains reusable custom validators for your models.

## Usage

Add validators to your models:

```ruby
class User < ApplicationRecord
  validates :email, presence: true, email: true
  validates :website, url: true, allow_blank: true
end
```

## Built-in Validators

### EmailValidator

Validates that a field contains a valid email address.

```ruby
validates :email, email: true
```

Options:
- `allow_blank: true` - Allow blank values
- `allow_nil: true` - Allow nil values

### UrlValidator

Validates that a field contains a valid HTTP(S) URL.

```ruby
validates :website, url: true
```

Options:
- `allow_blank: true` - Allow blank values
- `allow_nil: true` - Allow nil values

## Creating Custom Validators

Create a new file `app/validators/my_validator.rb`:

```ruby
class MyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless meets_criteria?(value)
      record.errors.add(attribute, :invalid, value: value)
    end
  end

  private

  def meets_criteria?(value)
    # Your validation logic here
    true
  end
end
```

Use in models:

```ruby
validates :field, my: true
```

## Resources

- [Rails Validations Documentation](https://guides.rubyonrails.org/active_record_validations.html)
- [Custom Validators Guide](https://guides.rubyonrails.org/active_record_validations.html#custom-validators)
