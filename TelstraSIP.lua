M = {}
trace.enable()
local top_level_domain = scriptParameters.getValue("top-level-domain")
trace.format("Domain = %s",top_level_domain)
if not top_level_domain
then
	top_level_domain = "mydomain.com"
end
function M.outbound_INVITE(msg)
	local isReInvite = msg:isReInviteRequest() 
	local from = msg:getHeader("From")
    if from then
		local start = string.find(from, "@")
		if start then 
			local end_str = string.find(from,">", start+1)
			local target = string.sub(from,start+1,end_str-1)
			local fromchange = string.gsub(from, target, top_level_domain)
			if fromchange then
				msg:modifyHeader("From",fromchange)
			end 
		end
	end	
    local to = msg:getHeader("To")
    if to then
		local start = string.find(to, "@")
		if start then
			local end_str = string.find(to,">", start+1)
			local target = string.sub(to,start+1,end_str-1)
			local tochange = string.gsub(to, target, top_level_domain)
			if tochange then
				msg:modifyHeader("To",tochange)
			end 
		end
	end	
	if isReInvite then
		local sdp = msg:getSdp()
		if sdp then
			local inactive_line = sdp:getLine("a=","inactive")
    	    if inactive_line then
				sdp = sdp:modifyLine("a=", "inactive", "a=sendrecv") 
				msg:setSdp(sdp)
			end
		end
	end
end	
function M.outbound_ACK(msg)
    local from = msg:getHeader("From")
    if from then
		local start = string.find(from, "@")
		local end_str = string.find(from,">", start+1)
		local target = string.sub(from,start+1,end_str-1)
		local fromchange = string.gsub(from, target, top_level_domain)
		if fromchange then
			msg:modifyHeader("From",fromchange)
		end 
	end	
    local to = msg:getHeader("To")
    if to then
		local start = string.find(to, "@")
		local end_str = string.find(to,">", start+1)
		local target = string.sub(to,start+1,end_str-1)
		local tochange = string.gsub(to, target, top_level_domain)
		if tochange then
			msg:modifyHeader("To",tochange)
		end 
	end	
	local sdp = msg:getSdp()
	if sdp 
	then
		local inactive_line = sdp:getLine("a=","sendonly")
		if inactive_line then
			sdp = sdp:modifyLine("a=", "sendonly", "a=sendrecv")
			msg:setSdp(sdp)
		end
	end
end
function M.outbound_CANCEL(msg)
    local from = msg:getHeader("From")
    if from then
		local start = string.find(from, "@")
		if start then 
			local end_str = string.find(from,">", start+1)
			local target = string.sub(from,start+1,end_str-1)
			local fromchange = string.gsub(from, target, top_level_domain)
			if fromchange then
				msg:modifyHeader("From",fromchange)
			end 
		end
	end	
    local to = msg:getHeader("To")
    if to then
		local start = string.find(to, "@")
		if start then
			local end_str = string.find(to,">", start+1)
			local target = string.sub(to,start+1,end_str-1)
			local tochange = string.gsub(to, target, top_level_domain)
			if tochange then
				msg:modifyHeader("To",tochange)
			end 
		end
	end	
	msg:removeHeader("Max-Forwards")
	msg:addHeader("User-Agent", "CUBE")
end
function M.outbound_ANY(msg)
    local from = msg:getHeader("From")
    if from then
		local start = string.find(from, "@")
		if start then
			local end_str = string.find(from,">", start+1)
			local target = string.sub(from,start+1,end_str-1)
			local fromchange = string.gsub(from, target, top_level_domain)
			if fromchange then
				msg:modifyHeader("From",fromchange)
			end 
		end
	end	
    local to = msg:getHeader("To")
    if to then
		local start = string.find(to, "@")
		if start then
			local end_str = string.find(to,">", start+1)
			local target = string.sub(to,start+1,end_str-1)
			local tochange = string.gsub(to, target, top_level_domain)
			if tochange then
				msg:modifyHeader("To",tochange)
			end 
		end
	end	
end
return M