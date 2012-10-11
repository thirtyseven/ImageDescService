class ReplaceDynamicDescriptionsHtmlTags < ActiveRecord::Migration
  
  def self.change
    execute "update dynamic_descriptions set body = replace (body, '&lt;body&gt;', '')"
    execute "update dynamic_descriptions set body = replace (body, '&lt;\/body&gt;', '')"
    execute "update dynamic_descriptions set body = replace (body, '&nbsp;', '&#160;')"
    execute "update dynamic_descriptions set body = replace (body, '<body>', '')"
    execute "update dynamic_descriptions set body = replace (body, '</body>', '')"
  end

end
