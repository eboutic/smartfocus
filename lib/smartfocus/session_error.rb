module Smartfocus

  # Session  Error
  #
  # This error is raised when the token has expired
  # or the number of connections has been reached
  class SessionError < Exception
  end

end