# frozen_string_literal: true

# Methods for minting and editing ARKs
module ARK
  # @param [#to_s] id
  # @return [Hyrax::Work]
  def self.mint_for(id)
    obj = Hyrax.query_service.find_by(id: id.to_s)

    # don't rescue, we want errors to halt everything
    obj.ark = Ezid::Identifier.mint
    saved = Hyrax.persister.save(resource: obj)

    Hyrax.publisher.publish("object.metadata.updated", object: saved, user: User.system_user)
    saved
  end

  # @param [Hyrax::Work] work
  # @param [Hash] args
  # @option args [String] target
  # @option args [Hash] metadata
  # @return [Hyrax::Work]
  def self.update_ark(work, args)
    id = Ezid::Identifier.find(work.ark)

    id.target = args[:target] if args[:target].present?

    if args[:metadata].present?
      args[:metadata].each do |key, value|
        id[key] = value
      end
    end

    id.save

    work
  end
end
