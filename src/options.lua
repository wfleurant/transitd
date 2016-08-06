--- @module options
local options = {}

require "alt_getopt"

local clfile = _G.arg[0]

local long_opts, optarg, optind

if clfile == "cli.lua" then
	
	long_opts = {
	   help = "h",
	   config = "f",
	   set = "n",
	}
	
	optarg, optind = alt_getopt.get_opts (_G.arg, "hf:lc:p:sn:", long_opts)
	
	if optarg.h or not (optarg.l or optarg.c or optarg.s or optarg.n) then
		print("Program arguments: \
 -f, --config <path/to/config>   Load configuration file \
 -l                              List available gateways \
 -c <ip>                         Connect to a gateway \
 -p <port>                       Use a specific gateway port \
 -n, --set <section.x=value>     Set a configuration value \
 -s                              Start a scan for gateways \
		")
		os.exit()
	end
	
else
	
	long_opts = {
	   help = "h",
	   config = "f",
	}

	optarg, optind = alt_getopt.get_opts (_G.arg, "hf:", long_opts)

	if optarg.h then
		print("Program arguments: \
 -f, --config <path/to/config>   Load configuration file \
		")
		os.exit()
	end
	
end

function options.getArguments()
	return optarg
end

return options
