M = {}
-- from https://robinwuyts.wordpress.com/category/lua-scripting/
function M.outbound_INVITE(msg)
local sdp = msg:getSdp()
if sdp
then
local video = {}
for i=10,2,-1 do
video[i] = sdp:getMediaDescription(i)
if video[i]
then
–remove the video media description
sdp = sdp:removeMediaDescription(i)
–set the modified sdp
msg:setSdp(sdp)
end
end
end
end
return M