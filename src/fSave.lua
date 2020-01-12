local z = ...

local function save(v, fc)
	if v == nil then
		fc("Nothing")
		return
	end
	if not v.name or not v.file then
		fc("File body missing")
		return
	end
	local p = tonumber(v.pos)
	if p == 0 then p = nil end
	if not p then
		file.remove("-~"..v.name)
	end
	local rm, _, _ = file.fsinfo()
	if (rm - (p and 1 or 500) - 5000) < #v.file then
		fc("Not enough space on disk")
		return
	end
	p = nil
	rm = nil
	collectgarbage()
	tmr.wdclr()
	require("fSaveI")(v, fc)
end

return function(c,v,u)
	package.loaded[z] = nil
	z = nil
	collectgarbage()
	if u > 1 then
		require("rs")(c, 401)
	else
		save(v, function(er)
			require("rs")(c, er and 403 or 200, er and ("Not saved: "..er) or nil)
		end)
	end
end
