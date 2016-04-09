# ActsAsBytefield

[![Build Status](https://travis-ci.org/cblackburn/acts_as_bytefield.svg?branch=master)](https://travis-ci.org/cblackburn/acts_as_bytefield)

**Version: 0.1.0**

Use a string column as a bytefield on an ActiveRecord model.

Requires Rails 4.x. Untested with other versions.

## Example

```ruby
class User < ActiveRecord::Base
  include ActsAsBytefield
  acts_as_bytefield :game_data, keys: [:health, :mana, :ammo]
end

user = User.create(health: 100, mana: 100, ammo: 200)
user.game_data #=> "dd\xC8"
user.health     #=> 'd'
user.health.ord #=> 100
user.mana       #=> 'd'
user.mana.ord   #=> 100
user.ammo       #=> "\xC8"
user.ammo.ord   #=> 200

# Set integers
user.health = 50
user.save
user.game_data #=> "2d\xC8"
user.health     #=> '2'
user.health.ord #=> 50
user.mana       #=> 'd'
user.mana.ord   #=> 100
user.ammo       #=> "\xC8"
user.ammo.ord   #=> 200

# Set the original column directly
user.game_data = 'ABC'
user.health     #=> 'A'
user.health.ord #=> 65
user.mana       #=> 'B'
user.mana.ord   #=> 66
user.ammo       #=> 'C'
user.ammo.ord   #=> 67

# Store zero/null
user.update_attributes(ammo: 0)
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

You can still use the string column as a regular string column.

```ruby
user.game_data = 'this is a test'

user.health #=> 't'
user.mana   #=> 'h'
user.ammo   #=> 'i'
```

#### Using Integers

When setting a field to an integer it will convert that integer to a byte with that ordinal value.

If the value is negative it will use the absolute value.

```ruby
user = User.create(health: -100, mana: -100, ammo: -200)
user.game_data #=> "dd\xC8"
user.health     #=> 'd'
user.health.ord #=> 100
user.mana       #=> 'd'
user.mana.ord   #=> 100
user.ammo       #=> "\xC8"
user.ammo.ord   #=> 200
```

Depending on your database encoding, values greater than 255 may raise an encoding error. Sqlite3 seems to have this restriction regardless of the encoding. Your mileage may vary.  However, PostgreSQL with `unicode` encoding will allow values up to 1114111 `"\u{10FFFF}"` for each byte field.

```ruby
user = User.create(health: 1114111, mana: 229, ammo: 51)
user.game_data #=> "\u{10FFFF}å3"
user.health     #=> "\u{10FFFF}"
user.health.ord #=> 1114111
user.mana       #=> "å"
user.mana.ord   #=> 229
user.ammo       #=> "3"
user.ammo.ord   #=> 51
```

### Indexing

You don't need to do anything special. Indexing works as expected.

### Database Issues

It has been tested with `sqlite3` and `postgres`. Make sure you pay attention to the encoding as things can change depending on how you set that up.

## Contributing and Support

Bug reports and pull requests are welcome on GitHub at https://github.com/cblackburn/acts_as_bytefield.

I'm fairly responsive. So don't be shy if you have a problem.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
