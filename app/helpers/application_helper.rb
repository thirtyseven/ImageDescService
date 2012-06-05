module ApplicationHelper
  def generate_html(options = {})
    escape_carriage_returns(single_quote_html((render(:partial => options[:partial], :locals => options[:locals]).force_encoding("UTF-8")))).force_encoding("UTF-8")
  end

  def single_quote_html html
    html.gsub '"', "'"
  end

  def escape_carriage_returns html
    html.gsub "\n", '\\n'
  end
  
end
