local z = ...

local function ldEmi(fi)
	if emi then
		fi()
		return
	end
	uart.on("data", 1, function(d)
		if not em0 or em0 > 3 then
			em0 = 1
			emi = nil
		else
			em0 = em0 + 1
		end
		if em0 < 3 then
			if d:byte(1) ~= 90 then em0 = 0 end
		else
			if em0 == 3 then emi = d:byte(1) end
		end
	end, 0)
	uart.write(0, "\165\85\1\251")
	local t = tmr.create()
	t:register(100,1,function()
		if not emi then
			uart.write(0, (em0 and "" or "\0").."\165\85\1\251")
		else
			t:unregister()
			uart.on("data")
			fi()
		end
	end)
	t:start()
end


local function setTh(cnt)
	uart.on("data")
	local th = {
		"\165\21\2\188", --115200
		"\165\37\4\206", --8Hz
		"\165\53\1\219", --manual
		nil, "\165\101\1\11" --save
	}
	ldEmi(function ()
		local i = 1
		local s = tmr.create()
		s:register(100,1,function()
			if th[i] then uart.write(0, th[i]) end
			if i < #th then
				i = i + 1
			else
				s:unregister()
				emi = nil
				cnt()
			end
		end)
		s:start()
	end)
end

local function initTh(cnt)
	ldEmi(cnt)
end

return function(f, cnt)
	package.loaded[z] = nil
	z = nil
	local v1 = {S = setTh,
		I = initTh
	}
	v1[f](cnt)
end
