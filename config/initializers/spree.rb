# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  config.use_s3 = true
  config.s3_bucket = "basement-images"
  config.s3_access_key = "AKIAJGPCM7TFZUFGSHBA"
  config.s3_secret = "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"
end

Spree.user_class = "Spree::User"

Paperclip.interpolates(:s3_eu_url) do |attachment, style|
  "#{attachment.s3_protocol}://#{Spree::Config[:s3_host_alias]}/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/},"")}"
end