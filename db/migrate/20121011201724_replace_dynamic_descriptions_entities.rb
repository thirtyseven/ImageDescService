class ReplaceDynamicDescriptionsEntities < ActiveRecord::Migration
  
  def self.up
    execute "update dynamic_descriptions set body = replace (body, '&lt;body&gt;', '')"
    execute "update dynamic_descriptions set body = replace (body, '&lt;\/body&gt;', '')"
    execute "update dynamic_descriptions set body = replace (body, '&nbsp;', '&#160;')"
    execute "update dynamic_descriptions set body = replace (body, '&ldquo;', '&#8220;')"
    execute "update dynamic_descriptions set body = replace (body, '&rdquo;', '&#8221;')"
    execute "update dynamic_descriptions set body = replace (body, '&le;', '&#8804;')"
    execute "update dynamic_descriptions set body = replace (body, '&ge;', '&#8805;')"
    execute "update dynamic_descriptions set body = replace (body, '&isin;', '&#8712;')"
    execute "update dynamic_descriptions set body = replace (body, '<body>', '')"
    execute "update dynamic_descriptions set body = replace (body, '</body>', '')"
  end

  def self.down
  end

end
