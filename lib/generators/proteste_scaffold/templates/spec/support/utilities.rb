RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end

RSpec::Matchers.define :have_elements_in_json_response do |n|
  match do |response|
    JSON.parse(response)['iTotalDisplayRecords'].to_i == n
  end
end


def datatable_params(params = {})
  { format: :json, sColumns: "", sSearch: "1" }.merge(params)
end

def datatable_ransack_params(field = 'id', comparator = 'eq',value = 1)
  datatable_params({sSearch: nil, q: {c: {'0' => {'p' => comparator, 'v' => {'0' => {value: value}} , 'a' => {'0' => {name: field}}}}}})
end

def datatable_pdf_params(params = {})
  datatable_params.merge({columns: 'id', column_names: 'id', page_title: 'report', format: "pdf"}).merge(params)
end

def datatable_xlsx_params(params = {})
  datatable_params.merge({columns: 'id', column_names: 'id', page_title: 'report', format: "xlsx"}).merge(params)
end

RSpec::Matchers.define :render_pdf do
  match do |actual|
    actual.header['Content-Type'] == 'application/pdf'
  end
end

RSpec::Matchers.define :render_xlsx do
  match do |actual|
    actual.header['Content-Type'] == 'application/vnd.openxmlformates-officedocument.spreadsheetml.sheet'
  end
end