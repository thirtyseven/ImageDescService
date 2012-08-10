class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document

  private

  # Renders the content for the footer
  def build_footer
    div :id => "footer" do
      para "Legal Disclaimer: The Poet tool is intended to assist in the creation of accessible content. Use of the Poet tool is limited to activities for creating content that comply with applicable copyright law and contractual agreements."
      para "Copyright &copy; #{Date.today.year.to_s} #{link_to('Benetech', 'http://www.benetech.org')}.".html_safe
      
    end
  end

end

