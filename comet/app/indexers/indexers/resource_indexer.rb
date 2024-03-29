# frozen_string_literal: true

module Indexers
  ##
  # Dynamically creates a new +ResourceIndexer+ class for the provided
  # (+Resource+) model class.
  def self.ResourceIndexer(model_class)
    Class.new(Hyrax::ValkyrieWorkIndexer) do
      @model_class = model_class

      prepend ::Indexers::ResourceIndexer

      include Hyrax::Indexer(:core_metadata)
      include Hyrax::Indexer(model_class.availability, index_loader: ::SchemaLoader.new)

      def self.inspect
        return "ResourceIndexer(#{@model_class})" if name.blank?
        super
      end
    end
  end

  ##
  # This is defined as a module and prepended because its +to_solr+ method needs
  # to override those defined in the more specific indexer classes.
  module ResourceIndexer
    def to_solr
      super.transform_values do |value|
        cast_literals(value)
      end.merge(
        rendering_ids_ssim: resource.rendering_ids.map(&:to_s),
        source_tesim: resource.alternate_ids.map(&:to_s),
        workflow_state_name_ssim: (sipity_entity&.workflow_state ? sipity_entity.workflow_state.name : [])
      )
    end

    def cast_literals(value)
      case value
      when Enumerable
        value.map { |v| cast_literals(v) }
      when RDF::Literal
        # For unrecognized +RDF::Literal+s or anything which makes use of the
        # default implementation, +#object+ defaults to whatever is passed in as
        # the first argument. Use the lexical value in these cases instead. The
        # +#object+ value is only desirable for datatypes which explicitly cast
        # it, for example dates.
        #
        # Also use the lexical value for any invalid literal, as the object is
        # not meaningful in this case.
        if value.instance_of?(RDF::Literal) || !value.valid? # not a valid subclass
          value.value
        else
          value.object
        end
      else
        value
      end
    end

    # Retrieve Sipity::Entity for workflow state
    def sipity_entity
      @sipity_entity ||= Sipity::Entity(resource)
    rescue Sipity::ConversionError => e
      Hyrax.logger.error { "Error retrieving Sipity::Entity for resource with id #{resource.id}: #{e}" }
      nil
    end

    ##
    # Dynamically returns a new ResourceIndexer subclass for the provided
    # Resource.
    def self.for(resource:)
      ::Indexers::ResourceIndexer(resource.class).new(resource: resource)
    end
  end
end
