class ::DiscourseStarWars::LocalesController < ::ApplicationController
    def flags
        raw_locales = YAML.safe_load(File.read(File.join(Rails.root, 'plugins', 'discourse-starwars', 'config', 'locales.yml')))

        localescollection = []

        raw_locales.map do |code, pic| 
            localescollection << DiscourseStarWars::Locale.new(code, pic)
        end

        render json: localescollection
    end
end
