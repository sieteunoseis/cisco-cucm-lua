M={}

function M.outbound_INVITE(msg)

  local from = msg:getHeader("From")  --Get FROM Header
  local to = msg:getHeader("To")  --Get TO Header
  local dummy,userStart = string.find(from, "sip:")  --Find start of sip: string
  local areaExchange = string.sub(from, userStart+3, userStart+5) --Extract caller area exchange
  local newExchange = string.gsub(to,"999",areaExchange) --Update TO Header with extracted area exchange

  msg:modifyHeader("To", newExchange)  --Replace TO Header
  local method, ruri, ver = msg:getRequestLine()
  local uri = string.gsub (ruri, "999",areaExchange)  --Update Request URI

  msg:setRequestUri(uri)

end

return M
