module Spree
  class ProductsController < Spree::StoreController
    before_filter :load_product, :only => :show
    before_filter :load_taxon, :only => :index

    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/taxons'

    respond_to :html

    def index
      if params[:category] || params[:brand] || params[:size]
        @categories = params[:category].present? ? params[:category].values : [] 
        @brands = params[:brand].present? ? params[:brand].values : []
        @sizes = params[:size].present? ? params[:size].values : []  

        @categories.map!(&:downcase)
        @brands.map!(&:downcase)
        @sizes.map!(&:downcase)  

        if @categories.present? || @brands.present? || @sizes.present?
          if @categories.present? && @brands.present? && @sizes.present?
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND LOWER(name) IN (?)", @sizes)
          elsif @categories.present? && @brands.present?
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
          elsif @categories.present? && @sizes.present?
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND LOWER(name) IN (?)", @sizes)
          elsif @brands.present? && @sizes.present?
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%'")
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%' AND LOWER(name) IN (?)", @sizes)
          elsif @categories.present?
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)", @categories)
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
          elsif @brands.present?
            @brand_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)", @brands)
            @category_taxons = Taxon.where("LOWER(permalink) LIKE 'brand%'")
            @size_taxons = Taxon.where("LOWER(permalink) LIKE 'size%'")
          end  

          category_products = @category_taxons.map(&:products).flatten
          brand_products = @brand_taxons.map(&:products).flatten
          size_products = @size_taxons.map(&:products).flatten
          products = category_products + brand_products + size_products  

          @products = products.find_all { |e| products.count(e) > 2 }.uniq
        else
          @taxons = Taxon.where("(LOWER(permalink) LIKE 'categor%' AND LOWER(name) IN (?)) OR (LOWER(permalink) LIKE 'brand%' AND LOWER(name) IN (?)) OR (LOWER(permalink) LIKE 'size%' AND LOWER(name) IN (?))", @categories, @brands, @sizes)
          @taxons.map(&:products).flatten
        end
      else
        @searcher = build_searcher(params.merge(include_images: true))
        @products = @searcher.retrieve_products
      end
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def show
      @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])
      @product_properties = @product.product_properties.includes(:property)
      @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
    end

    private
      def accurate_title
        @product ? @product.name : super
      end

      def load_product
        if try_spree_current_user.try(:has_spree_role?, "admin")
          @products = Product.with_deleted
        else
          @products = Product.active(current_currency)
        end
        @product = @products.friendly.find(params[:id])
      end

      def load_taxon
        @taxon = Spree::Taxon.find(params[:taxon]) if params[:taxon].present?
      end
  end
end