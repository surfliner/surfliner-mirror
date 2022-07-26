class AclsController < ApplicationController
  def show
    id = params.require(:resource)
    mode = params.require(:mode)
    group = Hyrax::Acl::Group.new(params.require(:group))

    # It's possible that we want to scope the information this endpoint provides
    # based on caller; i.e. hand out ACL info about users and groups that are
    # relevant to a caller/platform, but not about other groups. for example, is
    # it okay to leak information about Shoreline's access (or individual
    # shoreline users' access) to Tidewater?
    #
    # For now, we assume all platforms and callers can find out about
    # access from the public group, so we are limiting functionality to just
    # that group.
    unless group.name == "public"
      render(plain: "0") && return
    end

    resource = begin
      Superskunk.comet_query_service.find_by(id: id)
    rescue Valkyrie::Persistence::ObjectNotFoundError => err
      Rails.logger.info("Fielded access request for unknown resource: #{id}\n\t#{err}")
      render(plain: "0") && return
    end

    acl = AccessControlList.new(resource: resource)

    if acl.has_grant?(mode: mode.to_sym, agent: group)
      render plain: "1"
    else
      render plain: "0"
    end
  end
end
