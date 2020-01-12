local z = ...

local function fixT(pr, cnt)
	uart.write(0, pr.."\165\85\1\251")
	tmr.alarm(4,100,0,function()
		tmr.wdclr()
		if not emi then
			fixT(em0 and "" or "\0", cnt)
		else
			uart.on("data")
			cnt()
		end
	end)
end

local function ldEmi(cnt)
	if emi then cnt() end
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
	fixT("", cnt)
end


local function setTh(cnt)
        uart.on("data")
	ldEmi(function ()
		uart.write(0, "\165\21\2\188") --115200
		tmr.alarm(4,100,0,function()
			tmr.wdclr()
			uart.write(0, "\165\37\4\206") --8Hz
			tmr.alarm(4,100,0,function()
				tmr.wdclr()
				uart.write(0, "\165\53\1\219") --manual
				tmr.alarm(4,200,0,function()
					tmr.wdclr()
					uart.write(0, "\165\101\1\11") --save
					emi = nil
					cnt()
				end)
			end)
		end)
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
