# There appears to be a bug in the CanCan setup of `@pages` which does not
# properly route permissions through the exhibit—exhibit featured pages show up
# for superadmins, but not ordinatry exhibit admins. This override circumvents
# CanCan behaviour to just list *all* the (published) pages in an exhibit
# regardless of access permissions. NOTE: This still requires permissions to
# view the exhibit to access.
#
# Ideally we would not need to circumvent CanCan here, but nobody is aware of a
# fix as far as we know.
module PagesControllerIndexOverride
  def index
    @page = CanCan::ControllerResource.new(self).send(:build_resource)

    respond_to do |format|
      format.html
      format.json { render json: @exhibit.pages.for_default_locale.published.to_json(methods: [:thumbnail_image_url]) }
    end
  end
end

Spotlight::PagesController.class_eval do
  prepend PagesControllerIndexOverride
end
