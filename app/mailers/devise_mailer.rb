class DeviseMailer < Devise::Mailer
  before_action :use_site_config_values

  def use_site_config_values
    Devise.mailer_sender =
      "#{Settings::Community.community_name} <#{ForemInstance.email}>"
    ActionMailer::Base.default_url_options[:host] = Settings::General.app_domain
  end
end
