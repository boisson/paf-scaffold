ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :title
    t.text :content
    t.boolean :active
    t.timestamps
  end

  create_table :product_categories, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :colors, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :specifications, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :colors_products, :force => true do |t|
    t.references :color
    t.references :product
    t.timestamps
  end

  create_table :products_specifications, :force => true do |t|
    t.references :specification
    t.references :product
    t.timestamps
  end

  create_table :products, :force => true do |t|
    t.string :name
    t.references :product_category
    t.text :description
    t.float :price
    t.integer :quantity
    t.boolean :active
    t.timestamps
  end
end