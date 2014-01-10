# encoding: utf-8
require 'spec_helper'
require 'roo'

describe ProtesteScaffold::Export do
  
  before(:each) do
    # Product.delete_all
    3.times do |i|
      Specification.create(name: "specification #{i}")
      Color.create(name: "color #{i}")
    end

    10.times do |i|
      product_category = ProductCategory.create(name: "category #{i}")
      product = Product.create(
        name: "product #{i}", 
        product_category_id: product_category.id, 
        description: "description #{i}",
        price: (99*i),
        quantity: i,
        active: true
        )
      Color.all.each do |color|
        product.colors << color
      end
      Specification.all.each do |specification|
        product.specifications << specification
      end
      
    end
  end

  describe 'Testing export of xlsx' do
    it 'should export a product with all columns' do
      xlsx          = ProtesteScaffold::Export::XLSX.new('Product', "name,product_category,colors,specifications,description,price,quantity,active", [1,4,5,30], './tmp')
      exported_file = xlsx.export
      exported_file.stub(:original_filename).and_return(exported_file.path)
      spreadsheet = ProtesteScaffold::Import.open_spreadsheet(exported_file)

      xlsx.rows_exported.should have(3).elements
      File.exists?(exported_file.path).should be_true
      spreadsheet.row(1).should eql(["name", "product_category", "colors", "specifications", "description", "price", "quantity", "active"])
      spreadsheet.row(2)[0].should eql("product 0")
      spreadsheet.row(2)[2].should eql("color 0, color 1, and color 2")
      
      File.delete(exported_file.path)
    end
  end



  describe 'Testing export of pdf' do
    it 'should export a product with all columns' do
      pdf           = ProtesteScaffold::Export::PDF.new('Product', "name,product_category,colors,specifications,description,price,quantity,active", [1,4,5,30], './tmp')
      exported_file = pdf.export
      pdf.rows_exported.should have(3).elements
      pdf.rows_exported.first.name.should eql('product 0')
    end
  end
end