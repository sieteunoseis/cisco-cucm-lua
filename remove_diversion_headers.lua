M = {}
trace.enable()
function M.outbound_INVITE(msg)
          local DiversArray = msg:getHeaderValues(“Diversion”)
          local DiversCount = #DiversArray
          If DiversCount > 1 then
                   trace.format("More than one header")
                   for I = 2, (DiversCount) do
                            trace.format("Deleting following header '%s'", DiversArray[I])
                            msg:removeHeaderValue(“Diversion”, DiversArray[I])
                    end
           end
end

return M
