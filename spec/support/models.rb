require 'active_record'
class Post < ActiveRecord::Base
  attr_accessible :active, :content, :title
end

class ProductCategory < ActiveRecord::Base
  attr_accessible :name
end

class Color < ActiveRecord::Base
  attr_accessible :name
end

class Specification < ActiveRecord::Base
  attr_accessible :name
end

class ColorsProduct < ActiveRecord::Base
  belongs_to :color
  belongs_to :product
end

class ProductsSpecification < ActiveRecord::Base
  belongs_to :specification
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :products_specifications
  has_many :colors_products

  has_many :colors, through: :colors_products
  has_many :specifications, through: :products_specifications
  belongs_to :product_category
  attr_accessible :active, :description, :name, :price, :quantity, :product_category_id, :colors, :color_ids, :specifications, :specification_ids, :product_category
end


