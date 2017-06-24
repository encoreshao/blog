module Machinist
  module Machinable
    private
    def decode_args_to_make(*args) #:nodoc:
      shift_arg = lambda {|klass| args.shift if args.first.is_a?(klass) }
      count      = shift_arg[Integer]
      name       = shift_arg[Symbol] || :master
      attributes = shift_arg[Hash]   || {}
      raise ArgumentError.new("Couldn't understand arguments") unless args.empty?

      @blueprints ||= {}
      blueprint = @blueprints[name]
      raise NoBlueprintError.new(self, name) unless blueprint

      if count.nil?
        yield(blueprint, attributes)
      else
        Array.new(count) { yield(blueprint, attributes) }
      end
    end
  end

  class Lathe
    protected
    def make_attribute(attribute, args, &block) #:nodoc:
      count = args.shift if args.first.is_a?(Integer)
      if count
        Array.new(count) { make_one_value(attribute, args, &block) }
      else
        make_one_value(attribute, args, &block)
      end
    end
  end
end
