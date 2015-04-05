# JSONValidate

This gem offers very simple way to validate parsed JSON object.
Suppose your program expect an input JSON as below.

```json
    {
      "id": 100,
      "title": "Some title",
      "tags": ["funny", "cute"]
    }
```

It can be validated by the following code.

```ruby
    # assume json_str contains the JSON input
    object = JSON.parse(json_str)
    object.validate( {id: Fixnum, title: String, tags: [String]} )
```

If the JSON doesn't have designated structure, validate method raise a ValidationError.

```ruby
    object = JSON.parse('{"hoge": 1}')
    object.validate( {id:Fixnum} ) # => raise ValidationError
```

## Installation

Add this line to your application's Gemfile:

    gem 'json_validate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_validate

## Usage



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
