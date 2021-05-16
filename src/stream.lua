local function delC(d, c)
	if not pcall(function()
		local v, a = c:getpeer()
		prq[a..":"..v] = nil
		if d > 0 then
			c:on("sent",function() end)
			c:close()
		end end)
	then pcall(function()
		for k, v in pairs(prq) do
			local rm = true
			for i, y in ipairs(pr) do
				local w, a = y:getpeer()
				if k == a..":"..w then
					rm = false
					break
				end
			end
			if rm then prq[k] = nil end
		end end)
	end
	collectgarbage()
end

local function delCd(d, c)
	if d > 0 then
		table.remove(pr, d)
	else
		for i, v in ipairs(pr) do
			if v == c then table.remove(pr, i) end
		end
	end
	if c then delC(d, c) end
	if #pr == 0 then
		for k, v in pairs(prq) do prq[k] = nil end
		uart.on("data")
		uart.write(0, "\165\53\1\219")
		emi = nil
		em0 = nil
		collectgarbage()
		pr = {}
		prq = {}
		fq = {}
		fqw = 0
		fp = ""
		fpw = 0
	end
end

local function onSent(q, c)
	if not pcall(function()
		tmr.wdclr()
		local v, a = c:getpeer()
		a = a..":"..v
		v = prq[a]
		if v == fqw then
			if v > 0 then v = -v end
		elseif q == 0 or v <= 0 then
			if v < 0 then v = -v end
			v = (v == 4 and 1 or (v + 1))
			c:send(fq[v])
		end
		prq[a] = v
	end) then
		delCd(q, c)
	end
	collectgarbage()
end

local function onUart(d)
	if fpw == 0 or fpw == 7 then
		if #d == 222 then
			local s1, st = d:find("\90\90")
			if not s1 then
				fpw = 0
				uart.on("data", 222, onUart, 0)
				return
			elseif s1 > 1 then
				fp = d:sub(s1)
				uart.on("data", 222 - #fp, onUart, 0)
				return
			else
				fp = d
			end
		else
			fp = fp..d
		end
		fpw = 0
	end
	uart.on("data", fpw == 5 and 212 or 222, onUart, 0)
	fpw = fpw + 1
	if fpw == 1 then
		return
	elseif fpw == 4 then
		fp = d
	else
		local l = (fpw == 7)
		fp = fp..d
		if fpw == 3 or l then
			fqw = (fqw == 4 and 1 or (fqw + 1))
			local fp1 = encoder.toBase64(fp)
			fq[fqw] = string.format('%X', #fp1 + (l and 9 or 0)).."\r\n"..fp1..(l and string.format('%8X\n', tmr.now()) or "").."\r\n"
			fp = ""
			fp1 = nil
			if l then for i, c in ipairs(pr) do onSent(i, c) end end
		end
	end
	collectgarbage()
end

return function(c,p,u)
	p = nil
	if u > 1 then
		require("rs")(c, 401)
		return
	end
	local prc = #pr
	pr[prc + 1] = c
	if #pr > 3 then
		delCd(1, pr[1])
	end
	c:on("sent", function(ci) onSent(0, ci) end)
	require("rs")(c, 200, nil, 'text/plain')
	local v, a = c:getpeer()
	prq[a..":"..v] = 0
	if prc == 0 then
		local t = tmr.create()
		t:register(100,0,function()
			require("thermo")("I", function()
				uart.on("data", 222, onUart, 0)
				uart.write(0, "\165\53\2\220")
			end)
		end)
		t:start()
	end
	collectgarbage()
end
