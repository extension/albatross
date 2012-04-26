# omniauth github setup
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Settings.github_key, Settings.github_secret, scope: ''
end

