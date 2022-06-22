M = {}
trace.enable()
— From https://afterthenumber.com/2015/12/07/lua-script-solves-call-forward-masking/
function M.outbound_INVITE(msg)
— Input for script 
local ctirpdn = scriptParameters.getValue(“ctirpdn”) 
local mainnumber = scriptParameters.getValue(“mainnumber”) 
local rdnis = scriptParameters.getValue(“rdnis”)
— Get Diversion header 
local diversion = msg:getHeader(“Diversion”) 
— Check if Diversion Header exists and if the CTI RP DN is matched 
if diversion and diversion:find(ctirpdn) then 
	trace.format(“Successful match on diversion – applying masking”)
    trace.format(“CTI RP DN is : %s”, ctirpdn) trace.format(“Main Number is : %s”, mainnumber)
— Apply masking to affected headers – From, PAI, RPID, Contact 
msg:applyNumberMask(“From”, mainnumber) 
msg:applyNumberMask(“P-Asserted-Identity”, mainnumber) 
msg:applyNumberMask(“Remote-Party-ID”, mainnumber) 
msg:applyNumberMask(“Contact”, mainnumber) 
— Apply masking to Diversion to mask internal CTI RP DN 
msg:applyNumberMask(“Diversion”, rdnis)
end 
end
return M
