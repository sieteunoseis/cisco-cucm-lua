M={}
-- from https://robinwuyts.wordpress.com/category/lua-scripting/
–change to trace.enable() to have trace output in SDI
trace.disable()
function M.inbound_INVITE(msg) –capture inbound INVITE messages
–set the string to replace the anonymous, unavailable or restricted strings in the INVITE message
replacementNumber = “sip\:”
trace.format(“Replacement Number: %s”, replacementNumber)
–Set the header values to inspect for anonymous caller
local fields = { “From” , “Remote-Party-ID” , “P-Preferred-Identity”, “P-Asserted-Identity” }
local numberOfFields = #fields
trace.format(“Fields/Count: %s, %s, %s, %s, %s”, fields[1], fields[2], fields[3], fields[4], numberOfFields)

–loop though the header fields to inspect and replace any instance of ‘anonymous’ with the specified replacement number
local x = 1
while x <= numberOfFields do

–get the field from the header
local header = msg:getHeader(fields[x])
if header == nil
then
trace.format(“Field %s not found”, fields[x])
else
trace.format(“Field %s: %s”, fields[x], header)

–does the from contain anonymous
if string.find(string.lower(header), “sip\:anonymous”)
then
trace.format(“Found string anonymous in %s”, fields[x])
trace.format(“Header: %s %s”, fields[x], string.lower(header))

–replace the word anonymous with the user defined replacement number
local newHeader = string.gsub(string.lower(header), “sip\:anonymous”, replacementNumber)
trace.format(“New %s Field: %s”, fields[x], newHeader)

–modify the From field
msg:modifyHeader(fields[x], newHeader)
else if string.find(string.lower(header), “sip\:unavailable”)
then
trace.format(“Found string unavailable in %s”, fields[x])
trace.format(“Header: %s %s”, fields[x], string.lower(header))

–replace the word unavailable with the user defined replacement numbe
local newHeader = string.gsub(string.lower(header), “sip\:unavailable”, replacementNumber)
trace.format(“New %s Field: %s”, fields[x], newHeader)

–modify the From field
msg:modifyHeader(fields[x], newHeader)

else if string.find(string.lower(header), “sip\:restricted”)
then
trace.format(“Found string unavailable in %s”, fields[x])
trace.format(“Header: %s %s”, fields[x], string.lower(header))

–replace the word unavailable with the user defined replacement number
local newHeader = string.gsub(string.lower(header), “sip\:restricted”, replacementNumber)
trace.format(“New %s Field: %s”, fields[x], newHeader)

–modify the From field
msg:modifyHeader(fields[x], newHeader)

else
trace.format(“Field %s number valid. No change made.”, fields[x])
end
end
end
end
x = x+1
end
end
return M