# encoding: utf-8
require 'spec_helper'
require 'roo'

describe ProtesteScaffold::Import do

  describe 'Testing example file' do
    it 'should get a example file' do
      file    = ProtesteScaffold::Import.example_file('Post')
      file.stub(:original_filename).and_return(file.path)
      spreadsheet = ProtesteScaffold::Import.open_spreadsheet(file)
      spreadsheet.row(1).should eql(['active','content','title'])
      File.delete(file.path)
    end

    it 'should raise with a fake class' do
      expect { ProtesteScaffold::Import.example_file('News') }.to raise_error
    end
  end

  describe 'Testing import' do
    it 'should raise with wrong params' do
      post_import = ProtesteScaffold::Import.new('Post', open_file('test_file.csv'))
      expect { ProtesteScaffold::Import.new('News', open_file('test_file.csv')) }
      expect { post.import }.to raise_error
    end

    it 'should import a xlsx Post' do
      Post.all.should have(0).elements
      post_import = ProtesteScaffold::Import.new('Post', open_file('test_file.xlsx'))
      post_import.import.should be_true
      post_import.total_entries.should eql(2)
      post_import.rows_success.should have(2).elements
      Post.all.should have(2).elements
      Post.first.title.should eql('Post 01')
      Post.first.active.should be_true
      Post.last.title.should eql('Post 02')
    end

    it 'should import a xlsx Product with association of ProductCategory' do
      ProductCategory.create(name: 'Eletrônicos')
      ProductCategory.create(name: 'Informática')
      ProductCategory.create(name: 'Cama, mesa e banho')
      Color.create(name: 'Preto')
      Color.create(name: 'Azul')
      Specification.create(name: '3g')
      Specification.create(name: 'core i7')
      product_import = ProtesteScaffold::Import.new('Product', open_file('products_with_associations.xlsx'))
      product_import.import.should be_true
      Product.all.should have(3).elements
      first = Product.first
      last  = Product.last
      first.name.should eql('Smartphone')
      first.product_category.name.should eql('Eletrônicos')
      first.colors.should have(2).elements

      last.name.should eql('Cama')
      last.product_category.name.should eql('Cama, mesa e banho')
    end

    it 'should import a xlsx Product file' do
      product_import = ProtesteScaffold::Import.new('Product', open_file('test_products.xlsx'))
      product_import.import.should be_true
      Product.all.should have(3).elements
      first = Product.first
      last  = Product.last
      first.name.should eql('Geladeira')
      first.active.should be_true
      first.price.should eql(1500.34)
      first.quantity.should eql(253)
      

      last.name.should eql('Celular')
      last.active.should be_false
      last.price.should eql(888.99)
      last.quantity.should eql(150)
    end
  end

  describe 'Testing open sheet' do

    it 'should open xlsx file' do
      spreadsheet = ProtesteScaffold::Import.open_spreadsheet(open_file('test_file.xlsx'))
      spreadsheet.should be_kind_of(Roo::Excelx)
      spreadsheet.row(1).should eql(["title","content","active"])
      spreadsheet.row(2).should eql(["Post 01","content here",1.0])
      spreadsheet.row(3).should eql(["Post 02","content here",0.0])
    end
  end


  def open_file(filename)
    current_dir = File.expand_path(File.dirname(File.dirname(__FILE__)))
    file = File.open(File.join(current_dir,'import_files',filename))
    file.stub(:original_filename).and_return(file.path)
    file
  end
  
end
