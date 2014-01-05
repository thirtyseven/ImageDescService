# require 'iconv'
# 
# class String
#   IC_UTF8 = Iconv.new('UTF-8//IGNORE', 'UTF-8')
#   def force_utf8
#     #note added extra space plus chop to fix certain cases.
#     IC_UTF8.iconv("#{self} ")[0..-2]
#   end
#   
#   def de_json
#     ActiveSupport::JSON.decode self # try to deserialize the JSON
#   end
# end