# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module AuthLib
  
  protected
  
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  def authorize?(coder)
    if not coder
      return false
    else
      return true
    end
  end
    
    
  def signin_required
    if session[:coder_id]      
      coder = Coder.find_by_id(session[:coder_id])
      if (authorize?(coder))
        @currentcoder = coder
      end
      return true
    end

    # store current location so that we can 
    # come back after the user logged in
    store_location
    access_denied
    return false 
  end
  
  def signin_optional
    if session[:coder_id]      
      coder = Coder.find_by_id(session[:coder_id])
      if (authorize?(coder))
        @currentcoder = coder
      end
    end
    return true
  end


  def access_denied
    redirect_to(:controller=>:auth, :action => :start)
  end  
  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def clear_location
    session[:return_to] = nil
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end

end
