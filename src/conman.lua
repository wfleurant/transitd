
--- @module conman
local conman = {}

local config = require("config")
local db = require("db")
local cjdnsTunnel = require("cjdnstools.tunnel")
local threadman = require("threadman")

local conManTs = 0

local subscriberManager = function()
	
	local sinceTimestamp = conManTs
	conManTs = os.time()
	
	local subscribers, error = db.getTimingOutSubscribers(sinceTimestamp)
	if subscribers == nil then
		print(error)
		return
	end
	
	for k,subscriber in pairs(subscribers) do
		local at = ""
		if subscriber.meshIPv4 ~= nil then
			at = at..subscriber.method.."::"..subscriber.meshIPv4.." "
		end
		if subscriber.meshIPv6 ~= nil then
			at = at..subscriber.method.."::"..subscriber.meshIPv6.." "
		end
		local addr = ""
		if subscriber.meshIPv4 ~= nil then
			addr = addr..subscriber.internetIPv4.." "
		end
		if subscriber.meshIPv6 ~= nil then
			addr = addr..subscriber.internetIPv6.." "
		end
		
		print("Subscriber '"..subscriber.name.." at "..at.."-> "..addr.." timed out.")
		
		if subscriber.method == "cjdns" then
			-- we will need to remove the key from running cjdroute
			local key, error = db.getCjdnsSubscriberKey(subscriber.sid)
			if error then
				print("Failed to deauthroize cjdns tunnel key: "..error)
			else
				local success, error = cjdnsTunnel.deauthorizeKey(key)
				if error then
					threadman.notify({type = "subscriber.deauth.fail", sid = subscriber.sid, cjdnskey = key})
					print("Failed to deauthroize cjdns tunnel key: "..error)
				else
					threadman.notify({type = "subscriber.deauth", sid = subscriber.sid, cjdnskey = key})
					print("Deauthorized cjdns key "..key)
					db.deactivateClientBySession(subscriber.sid)
				end
			end
		end
	end
end

local gatewayManager = function()
	-- TODO: renew connection to gateway when about to expire
end

local connectionManager = function()
	subscriberManager()
	gatewayManager()
end

function conman.startConnectionManager()
	local socket = require("socket")
	local listener = threadman.registerListener("conman")
	while true do
		socket.sleep(2)
		connectionManager()
		local msg = {};
		while msg ~= nil do
			msg = listener:listen(true)
			if msg ~= nil then
				if msg["type"] == "exit" then
					threadman.unregisterListener(listener)
					return
				end
			end
		end
	end
	
end

return conman
