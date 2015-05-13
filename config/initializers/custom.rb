Spree::Product.class_eval do
	default_scope { order("spree_products.created_at DESC") }
end

Spree::Core::Search::Base.class_eval do

	def add_search_scopes(base_scope)
	  search.each do |name, scope_attribute|
	    scope_name = name.to_sym
	    if base_scope.respond_to?(:search_scopes) && base_scope.search_scopes.include?(scope_name.to_sym) && scope_name != :price_range_any
	      base_scope = base_scope.send(scope_name, *scope_attribute)
	    else
	    	if scope_name == :price_range_any
	    		# Search sale price if exists not original price
	    		product_ids = []
	    		encoded_scope = scope_attribute.map { |s| CGI::escape(s)}

	    		if encoded_scope.include?("Under+%C2%A310.00+GBP")
	    			sale_price_ids = Spree::SalePrice.where("value < ?", 10).map(&:price_id)
					product_ids << Spree::Price.where("id IN (?)", sale_price_ids).map { |p| p.variant.product_id}
	    			#product_ids << Spree::Price.where("amount < ? AND spree_prices.id NOT IN (?)", 10, sale_price_ids).map { |p| p.variant.product_id}	    		
	    		end

	    		if encoded_scope.include?("%C2%A310.00+GBP+-+%C2%A315.00+GBP")
	    			sale_price_ids = Spree::SalePrice.where("value > ? AND value < ?", 10, 15).map(&:price_id)
	    			product_ids << Spree::Price.where("id IN (?)", sale_price_ids).map { |p| p.variant.product_id}
	    			#product_ids << Spree::Price.where("amount > ? AND amount < ? AND spree_prices.id NOT IN (?)", 10, 15, sale_price_ids).map { |p| p.variant.product_id}
	    		end

	    		if encoded_scope.include?("%C2%A315.00+GBP+-+%C2%A318.00+GBP")
	    			sale_price_ids = Spree::SalePrice.where("value > ? AND value < ?", 15, 18).map(&:price_id)
					product_ids << Spree::Price.where("id IN (?)", sale_price_ids).map { |p| p.variant.product_id}
	    			#product_ids << Spree::Price.where("amount > ? AND amount < ? AND spree_prices.id NOT IN (?)", 15, 18, sale_price_ids).map { |p| p.variant.product_id}
	    		end

	    		if encoded_scope.include?("%C2%A318.00+GBP+-+%C2%A320.00+GBP")
	    			sale_price_ids = Spree::SalePrice.where("value > ? AND value < ?", 18, 20).map(&:price_id)
					product_ids << Spree::Price.where("id IN (?)", sale_price_ids).map { |p| p.variant.product_id}
	    			#product_ids << Spree::Price.where("amount > ? AND amount < ? AND spree_prices.id NOT IN (?)", 18, 20, sale_price_ids).map { |p| p.variant.product_id}
	    		end

	    		if encoded_scope.include?("%C2%A320.00+GBP+or+over")
	    			sale_price_ids = Spree::SalePrice.where("value > ?", 20).map(&:price_id)
					product_ids << Spree::Price.where("id IN (?)", sale_price_ids).map { |p| p.variant.product_id}
	    			#product_ids << Spree::Price.where("amount > ? AND spree_prices.id NOT IN (?)", 20, sale_price_ids).map { |p| p.variant.product_id}	    		
	    		end

	    		base_scope = base_scope.merge(Spree::Product.where("spree_products.id IN (?)", product_ids.flatten.uniq))
	    	else
	      	base_scope = base_scope.merge(Spree::Product.ransack({scope_name => scope_attribute}).result)
	      end
	    end
	  end if search
	  base_scope
	end
end