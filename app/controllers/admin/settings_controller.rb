module Admin
  class SettingsController < Admin::ApplicationController
    # NOTE: The "show" action uses a lot of partials, this makes it easier to
    # reference them.
    prepend_view_path("app/views/admin/settings")

    layout "admin"

    def create; end

    def show
      @confirmation_text = confirmation_text
    end

    private

    def extra_authorization_and_confirmation
      not_authorized unless current_user.has_role?(:super_admin)
      raise_confirmation_mismatch_error if params.require(:confirmation) != confirmation_text
    end

    def confirmation_text
      "My username is @#{current_user.username} and this action is 100% safe and appropriate."
    end

    def raise_confirmation_mismatch_error
      raise ActionController::BadRequest.new, MISMATCH_ERROR
    end
  end
end
