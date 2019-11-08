
-- Make unpack and table.unpack be the same function, regardless of version
if table.unpack then
  unpack = table.unpack
else
  table.unpack = unpack
end

-- table.pack taken from penlight
if not table.pack then
  function table.pack (...)
    return { n = select('#',...); ... }
  end
end
