require 'acts_as_bytefield/version'
require 'active_record'

module ActsAsBytefield
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_bytefield(column, options = {})
      fail(
        ArgumentError,
        "Hash expected, got #{options.class.name}"
      ) unless options.is_a?(Hash) || options.empty?

      unless respond_to?(:bytefields)
        class_eval { cattr_accessor :bytefields }
        self.bytefields = {}
      end

      column = column.to_sym
      bytefields[column] = create_field_hash(options[:keys])
      bytefields[column].keys.each do |key|
        define_bytefield_methods(column, key)
      end

      include ActsAsBytefield::InstanceMethods
    end

    private

    def create_field_hash(fields)
      attrs = {}
      fields.inject(0) do |n, f|
        attrs[f] = n
        n += 1
      end
      attrs
    end

    def define_bytefield_methods(column, field)
      define_method(field) { bytefield_value(column, field) }
      define_method("#{field}=") { |value| set_bytefield_value(column, field, value) }
    end
  end

  module InstanceMethods
    def bytefield_value(column, field)
      self[column][byte_index(column, field)]
    end

    def set_bytefield_value(column, field, value)
      self[column] ||= ''
      null_pad(column)
      self[column][byte_index(column, field)] = guarded_value(value)
    end

    private

    def null_pad(column)
      self[column] << "\0" * (column_length(column) - self[column].length)
    end

    def column_length(column)
      bytefields[column].keys.count
    end

    def byte_index(column, field)
      bytefields[column][field]
    end

    def guarded_value(value)
      if value.is_a?(String)
        value.first
      elsif value.is_a?(Fixnum)
        value.chr
      else
        fail "#{value} must be a Fixnum or String"
      end
    end
  end
end

# Add class methods
ActiveRecord::Base.send(:extend, ActsAsBytefield)
