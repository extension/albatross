class AuthConstraint
  def matches?(request)
    return false unless request.session[:coder_id]
    coder = Coder.find(request.session[:coder_id])
  end
end
