module Spree
  class TaxonsController < Spree::StoreController
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products'

    respond_to :html

    def show      
      @taxon = Taxon.find_by_permalink!(params[:id])
      return unless @taxon

      @categories = params[:category].present? ? params[:category].values : [] 
      @brands = params[:brand].present? ? params[:brand].values : []

      if params[:id].include?("brand/")
        @brands << params[:id].split("brand/")[1]
      elsif params[:id].include?("categories/")
        @categories << params[:id].split("categories/")[1]
      end

      @categories.map!(&:downcase)
      @brands.map!(&:downcase)

      p @categories
      p @brands
      p "IM HERE!"
      
      if @categories.present? || @brands.present?
        if @categories.present? && @brands.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
        elsif @categories.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
        elsif @brands.present?
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
        end

        category_products = @category_taxons.map(&:products).flatten
        brand_products = @brand_taxons.map(&:products).flatten
        products = category_products + brand_products

        @products = products.find_all { |e| products.count(e) > 1 }.uniq
      else
        @taxons = Taxon.where("(LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)) OR (LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?))", @categories, @brands)
        @taxons.map(&:products).flatten
      end
      
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    private

    def accurate_title
      if @taxon
        @taxon.seo_title
      else
        super
      end
    end

  end
end