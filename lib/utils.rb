# /lib/utils.rb
module Utils
  module_function

  def non_blank(str = nil)
    str unless str.blank?
  end

  def blank_params_to_nil(params)
    result = {}
    params.each do |key, val|
      if val.is_a?(Hash) && !val.blank?
        result[key] = blank_params_to_nil(val)
      else
        result[key] = non_blank(val)
      end
    end
    result
  end
end
