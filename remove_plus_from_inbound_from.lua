M={}

function M.inbound_INVITE(msg)
    local from = msg:getHeader("From")  --Get FROM Header
    local clean, occurrences = from:gsub('sip:%+', 'sip:') --Match plus and remove
    msg:modifyHeader("From", clean)  --Replace FROM Header
end

return M
