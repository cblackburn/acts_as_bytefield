# ActsAsBytefield

**Version: 0.1.0**

Use a string column as a bytefield on an ActiveRecord model.

Requires Rails 4.x. Untested with other versions.

## Example

```ruby
class User < ActiveRecord::Base
  include ActsAsBytefield
  acts_as_bytefield :game_data, keys: [:health, :mana, :ammo]
end

user = User.new(health: 100, mana: 100, ammo: 200)
user.game_data #=> "dd\xC8"

user.health = 50
user.save
user.game_data #=> "2d\xC8"

user.game_data = 'ABC'
user.health #=> 65
user.mana   #=> 66
user.ammo   #=> 67

user.update_attribute(ammo: 0)
user.ammo   #=> "\x00"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_bytefield'
```

And then execute:

    $ bundle

## Usage

### Model

Include the ActsAsBytefield module, and pass the column name to `acts_as_bytefield` along with the keys you want to use.

```ruby
class User < ActiveRecord::Base
  include ActsAsBytefield
  acts_as_bytefield :game_data, keys: [:health, :mana, :ammo]
end
```

The order of the keys matches the byte order of the string column. So, in the above example `game_data` with contain 3 bytes, from left to right representing `health`, `mana` and `ammo`.

### Indexing

You don't need to do anything special. Indexing works as expected.

### Database Issues

It has been tested with `sqlite3` and `postgres`. Make sure you pay attention to the encoding as things can change depending on how you set that up.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cblackburn/acts_as_bytefield.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
