class DatepickerInput < SimpleForm::Inputs::StringInput 
  def input
    value = object.send(attribute_name) if object.respond_to? attribute_name
    input_html_options[:value] ||= value.strftime('%d/%m/%Y') if value.present?
    input_html_options[:type]  = 'text'
    input_html_classes << "datepicker string"

    super + @builder.hidden_field(attribute_name, { :class => attribute_name.to_s + "-alt"}) 
  end
end