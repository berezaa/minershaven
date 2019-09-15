local lockbox = script.Parent.Parent

e = require(lockbox).bit

if not e then
	error("no bitwise support found", 2)
end

-- Workaround to support Lua 5.2 bit32 API with the LuaJIT bit one
if e.rol and not e.lrotate then
	e.lrotate = e.rol
end
if e.ror and not e.rrotate then
	e.rrotate = e.ror
end

return e
