##
# A label, intended to be used as a nested resource in agents and concepts.
#
# This uses the SurflinerSchema class resolver to initialize the class with its
# mappings, and then reopens it to build out some additional methods. This is
# necessary to ensure that the class defined here (the const) matches the one
# SurflinerSchema will use when building nested +Label+ objects inside of
# +Concept+s and +Agent+s.
Valkyrie.config.resource_class_resolver.call(:Label).class_eval do
  # compare label equality on all configured label fields, deliberately
  # excluding +:id+
  include Dry::Equalizer(*(fields - reserved_attributes))

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
