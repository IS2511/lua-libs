

function checkArg(n, have, ...)
  have = type(have)
  for _, want in pairs({...}) do
    if have == want then
      return
    end
  end
  local msg = "bad argument #" .. n .. " (" .. table.concat({...}, " or ") .. " expected, got " .. have .. ")"
  error(debug.traceback(msg, 3), 2)
end

return checkArg
