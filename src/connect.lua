local z = ...

local i = 0

local function setAP(ap, hf)
	local nc = {ip = "192.168.4.1", netmask = "255.255.255.0", gateway = "192.168.4.1"}
	wifi.ap.config(ap)
	wifi.ap.setip(nc)
	ap = nil
	nc = nil
	hf()
end

local function chk(m, ap, hf)
	i = i + 1
	local s = wifi.sta.status()
	if i >= 30 then s = 42 end
	local st = {[2]="Wrong password",[3]="No wireless network found",[4]="Connect fail",[42]="Connect timeout"}
	ls = st[s]
	st = nil
	if s == 5 or ls then
		tmr.stop(1)
		if s ~= 5 and m == wifi.STATION then
			wifi.setmode(wifi.STATIONAP)
			setAP(ap, hf)
		else
			hf()
		end
	end
end

return function(hf)
	package.loaded[z] = nil
	z = nil
	local f = require("cfgFile")()
	local m = f.sta and wifi.STATION or wifi.STATIONAP
	local ap = {}
	ap.ssid = f.ssid or "esp-devlab-setup";
	ap.pwd = f.pwd or "We1c0me!";
	f = nil
	wifi.setmode(m)
	wifi.sta.autoconnect(1)
	if m == wifi.STATION then
		tmr.alarm(1, 1000, 1, function()
			chk(m, ap, hf)
		end)
	else
		setAP(ap, hf)
	end
end