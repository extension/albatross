Airbrake.configure do |config|
		 config.api_key		 	= 'd4acdbf69ba4c32e07188a9521b96e76'
		 config.host				= 'apperrors.extension.org'
		 config.port				= 80
		 config.secure			= config.port == 443
	 end