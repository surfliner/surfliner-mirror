# frozen_string_literal: true

##
# A label, intended to be used as a nested resource in agents and concepts.
Valkyrie.config.resource_class_resolver.call(:Label).class_eval do
  ##
  # Create a new +Label+ from the provided argument or keywords.
  #
  # This is overridden to allow for easy creation of labels from strings;
  # +Label.new("label")+ will return a label with +#literal_form+ of "label".
  def self.new(arg = nil, **args)
    if arg.nil?
      super(args)
    else
      case arg
      when Label
        # If called with a label, pass through its values.
        super(arg.to_h)
      when Hash
        # If called with a hash, merge it with the kwargs. If there is a
        # +"@value"+ and, optionally, +"@language"+, forward that to the
        # `literal_form`.
        if arg.include?("@value")
          super({literal_form: RDF::Literal(arg["@value"],
            language: arg.fetch("@language", nil))}.merge(arg, args))
        else
          super(arg.merge(args))
        end
      else
        # Use the argument as the literal form.
        super({literal_form: arg})
      end
    end
  end

  def schema_attributes
    attributes.except(*self.class.reserved_attributes)
  end

  def to_s
    literal_form.first.to_s
  end
end
