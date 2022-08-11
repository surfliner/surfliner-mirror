class AclsController < ApplicationController
  def show
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
      resource_for(params.permit(:file, :resource))
    rescue Valkyrie::Persistence::ObjectNotFoundError => err
      Rails.logger.info { "Fielded access request for unknown resource: #{params}\n\t#{err}" }
      render(plain: "0") && return
    end

    acl = AccessControlList.new(resource: resource)

    begin
      if acl.has_grant?(mode: mode.to_sym, agent: group)
        Rails.logger.info { "Granting access on #{resource.id} to #{group.agent_key}" }
        Rails.logger.debug { "Granted after finding permissions: #{acl.permissions}" }
        render plain: "1"
      else
        Rails.logger.info { "Denying access on #{resource.id} to #{group.agent_key}" }
        Rails.logger.debug { "Denied after finding permissions: #{acl.permissions}" }
        render plain: "0"
      end
    rescue Valkyrie::Persistence::ObjectNotFoundError => err
      Rails.logger.info do
        "Fielded access request for #{mode} on #{resource.id}, but could not find ACL.\n" /
          "\tParameters: #{params}" \
          "\t#{err}"
      end
      Rails.logger.debug { "Denied after failing to find permissions for #{resource.id}" }
      render plain: "0"
    end
  end

  private

  def resource_for(params)
    if params.key?(:file)
      Superskunk.comet_query_service.custom_queries.find_file_metadata(params[:file])
    else
      Superskunk.comet_query_service.find_by(id: params[:resource])
    end
  end
end
