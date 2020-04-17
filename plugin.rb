# name: discourse-starwars
# about: Display Star Wars locales from User's selected locations.
# version: 2.0
# authors: David Forbush
# url: https://github.com/hifihedgehog/discourse-starwars

enabled_site_setting :starwars_enabled

PLUGIN_NAME = "discourse-starwars"

DiscoursePluginRegistry.serialized_current_user_fields << "starwars_iso"

after_initialize do

  module ::DiscourseStarWars
    class Engine < ::Rails::Engine
      engine_name "discourse_stars"
      isolate_namespace DiscourseStarWars
    end
  end

  load File.expand_path('../lib/locales.rb', __FILE__)

  Discourse::Application.routes.append do
    mount ::DiscourseStarWars::Engine, at: 'starwars'
  end

  load File.expand_path('../controllers/starwars.rb', __FILE__)

  ::DiscourseStarWars::Engine.routes.draw do
    get "/starwars" => "starwars#starwars"
  end

  public_user_custom_fields_setting = SiteSetting.public_user_custom_fields
  if public_user_custom_fields_setting.empty?
    SiteSetting.set("public_user_custom_fields", "starwars_iso")
  elsif public_user_custom_fields_setting !~ /starwars_iso/
    SiteSetting.set(
      "public_user_custom_fields",
      [SiteSetting.public_user_custom_fields, "starwars_iso"].join("|")
    )
  end

  User.register_custom_field_type('starwars_iso', :text)

  register_editable_user_custom_field :starwars_iso if defined? register_editable_user_custom_field
  
  if SiteSetting.starwars_enabled then
    add_to_serializer(:post, :user_signature, false) {
      object.user.custom_fields['starwars_iso']
    }

    # I guess this should be the default @ discourse. PR maybe?
    add_to_serializer(:user, :custom_fields, false) {
      if object.custom_fields == nil then
        {}
      else
        object.custom_fields
      end
    }
  end
end

register_asset "javascripts/discourse/templates/connectors/user-custom-preferences/user-starwars-preferences.hbs"
register_asset "javascripts/discourse/templates/connectors/user-profile-primary/show-user-card.hbs"
register_asset "stylesheets/starwars.scss"

DiscourseEvent.on(:custom_wizard_ready) do
  if defined?(CustomWizard) == 'constant' && CustomWizard.class == Module
    CustomWizard::Field.add_assets('starwars', 'discourse-starwars', ['components', 'templates'])

    CustomWizard::Builder.add_field_validator('starwars') do |field, updater, step_template|
      if step_template['actions'].present?
        step_template['actions'].each do |a|
          if a['type'] === 'update_profile'
            a['profile_updates'].each do |pu|
              if pu['key'] === field['id'] && pu['value_custom'] === 'starwars_iso'
                updater.fields[field['id']] = updater.fields[field['id']]['starwars_iso']
              end
            end
          end
        end
      end
    end
  end
end
