class ApplicationController < ActionController::API
  def process_action(*args)
    super
  rescue ActionController::ParameterMissing => e
    render status: 400, json: { errors: [e.message] }
  end

end
