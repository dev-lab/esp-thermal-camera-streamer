ls = ""
cf = {}
pr = {}
prq = {}
fq = {}
fqw = 0
fp = ""
fpw = 0
tmr.create():alarm(2000, 0, function()
	if not cjson then _G.cjson = sjson end
	node.setcpufreq(node.CPU160MHZ)
	uart.setup(0,115200,8,0,1,0)
	uart.on("data")
	uart.write(0, "\165\53\1\219")
	require("connect")(function()
		tmr.create():alarm(100, 0, function()
			require("http")
			require("dnsLiar")
		end)
	end)
end)
