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
  
  def render_ga ga_id
    raw "<script type=\"text/javascript\">
  
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', '#{ga_id}']);
    _gaq.push(['_trackPageview']);
  
    (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); })();
  
    </script>
    "
  end
  
end
