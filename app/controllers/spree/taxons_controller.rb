#coding: utf-8
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
      @sizes = params[:size].present? ? params[:size].values : []

      if params[:id].include?("brand/")
        @brands << params[:id]
      elsif params[:id].include?("categories/")
        @categories << params[:id]
      end

      @categories.map!(&:downcase)
      @brands.map!(&:downcase)
      @sizes.map!(&:downcase)
      
      if @categories.present? || @brands.present? || @sizes.present?
        if @categories.present? && @brands.present? && @sizes.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @categories, @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @brands, @brands)
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @sizes, @sizes)
        elsif @categories.present? && @brands.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @categories, @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @brands, @brands)
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
        elsif @categories.present? && @sizes.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @categories, @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @sizes, @sizes)
        elsif @brands.present? && @sizes.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%'")
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @brands, @brands)
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @sizes, @sizes)
        elsif @categories.present?
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @categories, @categories)
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
        elsif @brands.present?
          @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND (LOWER(name) IN (?) OR LOWER(permalink) IN (?))", @brands, @brands)
          @category_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
          @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
        end

        category_products = @category_taxons.map(&:products).flatten
        brand_products = @brand_taxons.map(&:products).flatten
        size_products = @size_taxons.map(&:products).flatten
        products = category_products + brand_products + size_products
        products = products.find_all { |e| products.count(e) > 2 }.uniq

        if params["search"] && params["search"]["price_range_any"]
          prices = params["search"]["price_range_any"]
          price_products = []
          ranges = []
          ranges << [0, 10] if prices.include?("Under £10.00")
          ranges << [10, 15] if prices.include?("£10.00 - £15.00")
          ranges << [15, 18] if prices.include?("£15.00 - £18.00")
          ranges << [18, 20] if prices.include?("£18.00 - £20.00")
          ranges << [20] if prices.include?("£20.00 or over")

          products.each do |product|
            ranges.each do |range|
              if product.price >= range[0] && product.price <= range[1]
                price_products << product
                break
              end
            end
          end
        end

        @products = price_products || products
      else
        @taxons = Taxon.where("(LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)) OR (LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)) OR (LOWER(permalink) LIKE 'size%' AND LOWER(name) IN (?))", @categories, @brands, @sizes)
        @taxons.map(&:products).flatten
      end
      
      @taxonomies = Spree::Taxonomy.where("name IN (?)", ["Departments", "Brands", "Size"]).includes(root: :children)
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