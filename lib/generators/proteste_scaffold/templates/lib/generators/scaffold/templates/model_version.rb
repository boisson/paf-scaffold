class <%=class_name%>Version < Version
  self.table_name = :<%=singular_table_name%>_versions
  belongs_to :user, foreign_key: :whodunnit
end