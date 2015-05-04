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
	    		Spree::Product.all.select { |p| p.price < 10 }
	    		product_ids << Spree::Product.all.select { |p| p.price < 10 }.map(&:id) if encoded_scope.include?("Under+%C2%A310.00+GBP")
	    		product_ids << Spree::Product.all.select { |p| p.price > 10 && p.price < 15 }.map(&:id) if encoded_scope.include?("%C2%A310.00+GBP+-+%C2%A315.00+GBP")
	    		product_ids << Spree::Product.all.select { |p| p.price > 15 && p.price < 18 }.map(&:id) if encoded_scope.include?("%C2%A315.00+GBP+-+%C2%A318.00+GBP")
	    		product_ids << Spree::Product.all.select { |p| p.price > 18 && p.price < 20 }.map(&:id) if encoded_scope.include?("%C2%A318.00+GBP+-+%C2%A320.00+GBP")
	    		product_ids << Spree::Product.all.select { |p| p.price > 20 }.map(&:id) if encoded_scope.include?("%C2%A320.00+GBP+or+over")
	    		base_scope = base_scope.merge(Spree::Product.where("spree_products.id IN (?)", product_ids.flatten))
	    	else
	      	base_scope = base_scope.merge(Spree::Product.ransack({scope_name => scope_attribute}).result)
	      end
	    end
	  end if search
	  base_scope
	end
end