Guides
======

1. Importing

The import system of paf-scaffold gem works with xlsx files. Every grid have 
button to import and when click, open a modal window with a example of model 
to import.
The most important to generate the example file are the columns with 
**attr_accessible** definitions. In other words, every column that is in the list
of attr_accessible appears by default on generate file.


1.1 Forcing new columns in example file

If you need add new columns in the example file, just add the key **forced_columns**
with array of columns. See the example:

  # <%=render partial: 'import/modal_form', locals: {
  #   class_to_import: 'User',
  #   forced_columns: ['Group']
  # } %>


1.2 Excluding columns in example file

If you need exclude some column in the example file, add the key **excluded_columns**
with array of columns. This situation occur in most of time when you have some
helper attribute to do the save operation. You should consider change your code
adding new methods and changing your controller because the method save in the
model should work without any rule. But if you really need exclude columns, see
the example:

  # <%=render partial: 'import/modal_form', locals: {
  #   class_to_import: 'Application',
  #   excluded_columns: ['applications_companies_on_save']
  # } %>


1.3 Importing foreign keys


1.3.1 Import belongs to column

When you need import some model with belongs_to association (ex.: User 
belongs_to Company) it's more easy than you think. First thing you need know it's
the header column can be the name of association or the column with id. If you need
choice about one of two cases, use the name of association. In User example, in
the attr_accessible should have :company key in the list or force using 
forced_columns.
When belongs_to association is imported, the code look for the method 
find_by_name in association model. In the example:

  # Company.find_by_name(value_of_column_in_xlsx_file)

In other words, the **company** should have the column **name**.
But don't worry if your model don't have the *name* column. You just need implement
a class method called find_by_name receiving one argument and return some register.
See one example:

  # class ApplicationsFunctionsMenu < ActiveRecord::Base
  #   acts_as_xlsx
  #   has_paper_trail class_name: 'ApplicationsFunctionsMenuVersion'
  #   attr_accessible :application_id, :function_id, :menu_id, :order_number,
  #   :application, :function, :menu
  #   belongs_to :application
  #   belongs_to :function
  #   belongs_to :menu
  #   has_many :languages,    :class_name => :ApplicationsFunctionsMenusLanguage, :dependent => :destroy
  #   has_many :permissions,  :dependent => :destroy
  #   validates :application, presence: true
  #   validates :function, presence: true
  #   validates :menu, presence: true
  #   validates :order_number, presence: true
  #   validates :application_id, uniqueness: { :scope => [ :function_id, :menu_id ], :case_sensitive => false }
  #   # used in import
  #   def self.find_by_name(name)
  #     app_name, menu_name, function_name = name.split(' / ')
  #     application = nil
  #     menu        = nil
  #     function    = nil
  #     unless app_name.blank?
  #       application = Application.where(['name like ?',app_name.to_s.strip]).first
  #     end
  # 
  #     unless menu_name.blank?
  #       menu = Menu.where(['name like ?',menu_name.to_s.strip]).first
  #     end
  # 
  #     unless function_name.blank?
  #       function = Function.where(['name like ?',function_name.to_s.strip]).first
  #     end
  # 
  #    return if application.nil? || menu.nil? || function.nil?
  # 
  #     ApplicationsFunctionsMenu.where(application_id: application.id).
  #       where(menu_id: menu.id).
  #       where(function_id: function.id).first
  #   end
  # end``
