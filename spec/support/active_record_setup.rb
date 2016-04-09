# Be careful using sqlite3 as it may have encoding issues with high-bit chars
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
  encoding: 'unicode'
)
ActiveRecord::Schema.verbose = false

def setup_db
  ActiveRecord::Schema.define(version: 1) do
    create_table :bytefield_models do |t|
      t.string :my_bytefield

      t.timestamps null: false
    end
  end
end

class BytefieldModel < ActiveRecord::Base
  include ActsAsBytefield
  acts_as_bytefield :my_bytefield, keys: [:a, :b, :c]
end
