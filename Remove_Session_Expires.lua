M = {}
  function M.outbound_INVITE(msg)
    msg:removeHeader("Session-Expires")
  end
return M
