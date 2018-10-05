# frozen_string_literal: true

module ViewResourceMacros
  def has_resource(name, &block)
    before do
      # Creates the resource
      @resource ||= yield
      # Assign to the symbol we wanted, so it's available in the view
      assign(name, @resource)

      # Assigns to @name so that we can use that in our assertions
      instance_variable_set("@#{name}", @resource)

      # If we pass an array, it's for stubing a collection, if not it's for stubbing a single object
      if @resource.is_a?(Array)
        allow(view).to receive(:collection).and_return(@resource)
        allow(view).to receive(:resource_class).and_return(@resource.first.class)
      else
        allow(view).to receive(:resource).and_return(@resource)
        allow(view).to receive(:resource_class).and_return(@resource.class)
      end
    end
  end
end
