M = {}
local mask = scriptParameters.getValue("Diversion-Mask")

-- handle the mask of the diversion header for non-911 calls

function mask_diversion(msg)
    if mask then
        msg:applyNumberMask("Diversion", mask)
    end
end
-- return the user part of the specified uri

function getUserPartFromUri(uri)
    return string.match(uri, "sip:(.+)@")
end

-- handle the diversion header change for the case of 911 calls

function handle_911_diversion(msg)
    msg:removeHeader("Diversion")
end

function M.outbound_INVITE(msg)
    -- Determine whether this is a 911 call based on the user part in the reqUri

    local method, requri, version = msg:getRequestLine()
    if requri then
        -- found reqUri
        local userpart = getUserPartFromUri(requri)
        if userpart then
            -- found user part from reqUri
            if userpart == "911" then
                -- handling as 911 call
                handle_911_diversion(msg)
                return
            end
        end
    end

    -- handling as non-911 call
    mask_diversion(msg)
end
return M