class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def sorted_categories
  	Spree::Taxonomy.find(1).root.children
  end

  def sorted_brands
  	Spree::Taxonomy.find(2).root.children
  end
end
