local z = ...

return function(q)
	package.loaded[z] = nil
	z = nil
	local u = cfg[1] and (cfg[2] and 9 or 2) or 1
	local s1, st = q:find("\r\n\r\n")
	local h = s1 and q:sub(1, s1 - 1) or q
	local g = {}
	if st and (st + 1) < #q then
		g["file"] = q:sub(st + 1)
	end
	q = nil
	collectgarbage()
	if u > 1 then
		local ab = h:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
		if ab then
			if ab == cfg[1] then u = 1 elseif ab == cfg[2] then u = 2 end
		end
	end
	if u > 2 then
		return nil, nil, u, nil
	end
	local _, _, m, p, vs = h:find("([A-Z]+) (.+)?(.+) HTTP")
	if not m then
		_, _, m, p = h:find("([A-Z]+) (.+) HTTP")
	end
	h = nil
	if not m then return nil, nil, 10, nil end
	if not p or p == "/" then
		p = "index.htm"
	else
		p = p:sub(2, -1)
	end
	if vs then
		for k, v in vs:gmatch("(%w+)=([^&]+)") do
			g[k] = v:gsub("+", " ")
		end
		vs = nil
	end
	local _, _, _, e = p:find("(.*)%.(%w*)%c*$")
	m = nil
	h = nil
	collectgarbage()
        return p, e, u, g
end
