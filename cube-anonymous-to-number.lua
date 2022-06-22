--[[
  Title:  CUBE Anonymous to Number SIP Normalization Script for CUCM
  By:     Anthony Holloway (avholloway@gmail.com)
  Date:   December 2019

  If we are performing call blocking based on calling number, and we receive
  an INVITE from anonymous, it will be blocked because, CUCM will not be able
  to use our blank nor ! XLATEs we use to permit non-blacklisted callers.

  Therefore, we are going to find and replace these anonymous caller IDs with
  a known numeric caller ID, for the purposes of matching our ! XLATE to permit
  the call through our call blocking construct.  We only do this in inbound
  INVITEs, since that is how all calls originate to us, and we'll block it right
  then and there.

  We then need to make sure that subsequent responses back to the ITSP show the
  original caller ID information, so we'll revert our change in messages back.

  E.g.,
  On the way in to us...
  sip:anonymous@1.1.1.1 becomes sip:1111111111@1.1.1.1

  On the way back to ITSP...
  sip:1111111111@1.1.1.1 becomes sip:anonymous@1.1.1.1

--]]

-- Start of Script: Global Settings --------------------------------------------

-- Initialize our SIP Normalization M table
M = {}

-- Turn on tracing (writes "//SIPLua/Script/trace_output:" to SDL)
-- Must also be enabled on SIP Trunk to actually write to logs
trace.enable()

-- Message Handlers: Inbound Requests ------------------------------------------

function M.inbound_INVITE(msg)
  -- The fix for blocking calls by calling number and SIP anonymous caller IDs
  anon_to_number()
end

-- Message Handlers: Inbound Responses -----------------------------------------

-- None

-- Message Handlers: Outbound Requests -----------------------------------------

function M.outbound_ANY(msg)
  -- The reversion to our fix for blocking SIP anonymous caller caller_ids
  number_to_anon()
end

-- Message Handlers: Outbound Responses ----------------------------------------

function M.outbound_ANY_ANY(msg)
  -- The reversion to our fix for blocking SIP anonymous caller caller_ids
  number_to_anon()
end

-- User Defined Functions ------------------------------------------------------

-- Finds SIP Calls with Anonymous caller IDs and converts them to an arbitrary
-- number so that CUCM can match our ! XLATE in our call blocking construct
local function anon_to_number(msg)
  -- Only perform this action on initial INVITEs, no reINVITEs allowed
  if not msg:isInitialInviterequest() then return end

  trace.format("CALL_BLOCKING: ANON2NUM: Inspecting From: "..from_header)

  -- The From header needs to be present and cannot contain a digit in LHS
  -- This allows us to quit our app as fast as possible, since this will be
  -- executed for every call, but the percentage of matches will be very low
  local from_header = msg:getHeader("From")
  if not from_header or from_header:find("%d@") then
    trace.format("CALL_BLOCKING: ANON2NUM: Exiting due to numeric value in LHS")
    return
  end

  -- The following caller ID values will trigger a replacement
  -- We match the LHS of the SIP URI, and not the Calling Name in quotes
  local caller_ids = {"anonymous", "restricted", "unavailable"}

  -- Does our From header match one of our caller ID values?
  if not find_one(":"..from_header.."@", caller_ids) then
    trace.format("CALL_BLOCKING: ANON2NUM: Exiting due to no match with our caller IDs")
    return
  end

  -- We'll use the dialog context to flag calls we've modified, store
  -- information about the call, and to restore original values when needed
  local context = msg:getContext()
  if not context then
    trace.format("CALL_BLOCKING: ANON2NUM: Exiting due to missing context for dialog")
    return
  end

  -- Our flag in the context of this dialog so we can check further messages
  -- within this dialog and know it's our special type of call versus some
  -- other random call.
  context.anonymous = true

  -- We'll store the replacement to the LHS in the context too
  context.replacement = "1111111111"

  -- The following Headers will be checked and replaced
  local headers = {"From", "Remote-Party-ID", "Contact",
    "P-Preferred-Identity", "P-Asserted-Identity"}

  -- A place to store the original value of each of the headers we modfiy
  context.headers = {}

  -- Check each header in our list one-by-one, to perform the fix on it
  for _, header in pairs(headers) do

    -- Try to grab this header, if its not present, just move to the next header
    local value = msg:getHeader(header)
    if not value then
      trace.format("CALL_BLOCKING: ANON2NUM: Not Found: "..header..":")
    else
      
      -- If this header contains one of our caller ID keywords
      if not find_one(":"..value.."@", caller_ids) then
        trace.format("CALL_BLOCKING: ANON2NUM: No Change: "..header..": "..value)
      else
        trace.format("CALL_BLOCKING: ANON2NUM: Pre-Change: "..header..": "..value)

        -- Store the original value for later
        context.headers[header] = value

        -- Perform the swap to the new value
        value = value:gsub(":.+@", ":"..replacement.."@")
        msg:modifyHeader(header, value)
        trace.format("CALL_BLOCKING: ANON2NUM: Post-Change: "..header..": "..value)
      end
      
    end
    
  end

end

-- Finds SIP messages where we have previously monkeyed with the Anonymous
-- caller ID and put it back to how it was, so the ITSP is nonethewiser
local function number_to_anon(msg)
  -- We'll use the dialog context to read a flag for calls we've modified
  local context = msg:getContext()
  if not context or not context.anonymous then
    trace.format("CALL_BLOCKING: NUM2ANON: Exiting due to this not being one of our messages")
    return
  end

  -- We'll iterate over the headers we modified, reverting them back
  for header, value in context.headers do

    -- If the current header is From, check if this message is a reINVITE
    -- If so, we need to modify the To header, since they're usually flipped
    if header == "From" and msg:isReInviteRequest() then header = "To" end

    msg:modifyHeader(header, value)
    trace.format("CALL_BLOCKING: NUM2ANON: "..header..": Reverting to: "..value)
  end

end

-- Takes a string and a table of patterns and returns true or false if one
-- of the patterns matches the string
local function find_one(s, t)
  for _, p in pairs(t) do
    if s:lower():find(p) then return true end
  end
  return false
end

return M
