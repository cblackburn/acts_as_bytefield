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

      declare_class_accessors
      column = column.to_sym
      bytefields[column] = create_field_hash(options[:keys])
      define_bytefield_methods(column)

      include ActsAsBytefield::InstanceMethods
    end

    private

    def declare_class_accessors
      return nil if respond_to?(:bytefields)
      class_eval { cattr_accessor :bytefields }
      self.bytefields = {}
    end

    def create_field_hash(fields)
      attrs = {}
      fields.inject(0) do |index, key|
        attrs[key] = index
        index += 1
      end
      attrs
    end

    def define_bytefield_methods(column)
      bytefields[column].keys.each do |key|
        define_method(key) { bytefield_value(column, key) }
        define_method("#{key}=") { |value| set_bytefield_value(column, key, value) }
      end
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
        value.abs.chr
      else
        fail "#{value} must be a Fixnum or String"
      end
    end
  end
end

# Add class methods
ActiveRecord::Base.send(:extend, ActsAsBytefield)
