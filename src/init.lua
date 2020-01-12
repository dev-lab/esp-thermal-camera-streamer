ls = ""
cfg = {}
pr = {}
prq = {}
fq = {}
fqw = 0
fp = ""
fpw = 0
tmr.alarm(0,2000,0,function()
	uart.setup(0,115200,8,0,1,0)
	uart.on("data")
	uart.write(0, "\165\53\1\219")
	require("connect")(function()
		tmr.alarm(0,100,0,function()
			collectgarbage()
			require("http")
			require("dnsLiar")
		end)
	end)
end)
