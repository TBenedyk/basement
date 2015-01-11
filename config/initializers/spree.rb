Spree.config do |config|
  attachment_config = {
    s3_credentials: {
      access_key_id: "AKIAIKGSEBQG2MWGJTBA",
      secret_access_key: "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",
      bucket: "basement-images",
    },
 
    storage:        :s3,
    s3_headers:     { "Cache-Control" => "max-age=31557600" },
    s3_protocol:    "https",
    bucket:         "basement-images",
 
    styles: {
      mini:     "48x48>",
      small:    "100x100>",
      product:  "240x240>",
      large:    "600x600>"
    },
 
    #path:          ":rails_root/public/spree/products/:id/:style/:basename.:extension",
    path:          "/app/public/spree/products/:id/:style/:basename.:extension",
    default_url:   "/spree/products/:id/:style/:basename.:extension",
    default_style: "product",

  }
 
  attachment_config.each do |key, value|
    Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
  end

  config.products_per_page = 12
  config.enable_mail_delivery = true
  config.override_actionmailer_config = false
  config.mails_from = "tobybenedyk@gmail.com"

end unless Rails.env.test?

# Spree.user_class = "Spree::User"
# 
# Paperclip.interpolates(:s3_eu_url) do |attachment, style|
  # "#{attachment.s3_protocol}://#{Spree::Config[:s3_host_alias]}/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/},"")}"
# end