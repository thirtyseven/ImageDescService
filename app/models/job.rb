class Job < ActiveRecord::Base
  def json_enter_params
    enter_params ? enter_params.de_json : {}
  end
  def json_exit_params
    exit_params ? exit_params.de_json : {}
  end
end
