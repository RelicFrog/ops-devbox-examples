-- Copyright 2026 TEAM RelicFrog
-- SPDX-License-Identifier: Apache-2.0
--
-- main.lua — CLI entry point for primes-cli (LuaJIT implementation).
--
-- Subcommands (identical to ws-rust, ws-go, ws-node, ws-zig):
--   check <N>                    — test whether N is prime (exit 0=prime, 1=not)
--   list  --to <N>               — list all primes up to N
--   range --from <A> --to <B>    — list all primes in [A, B]
--   nth   <N>                    — print the N-th prime (1-indexed)

local primes = require("primes")

local VERSION = "1.0.0"

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function parse_int(s)
	local n = tonumber(s)
	if not n or n ~= math.floor(n) or n < 0 then
		io.stderr:write(string.format('error: invalid number "%s"\n', s))
		os.exit(1)
	end
	return math.floor(n)
end

local function parse_flags(args, offset)
	local flags = {}
	local i = offset or 1
	while i <= #args do
		local a = args[i]
		if a:sub(1, 2) == "--" then
			local key = a:sub(3)
			if args[i + 1] and args[i + 1]:sub(1, 2) ~= "--" then
				flags[key] = args[i + 1]
				i = i + 2
			else
				flags[key] = true
				i = i + 1
			end
		else
			i = i + 1
		end
	end
	return flags
end

local function print_list(ps)
	if #ps == 0 then
		print("(no primes in range)")
		return
	end
	for _, p in ipairs(ps) do
		print(p)
	end
end

local function print_usage()
	io.stderr:write(string.format(
		[[primes-cli %s (LuaJIT) — prime number generator CLI

Usage:
  primes-cli <command> [arguments]

Commands:
  check <N>              Test whether N is prime (exit 0=prime, 1=not prime)
  list  --to <N>         List all primes up to N (inclusive)
  range --from <A> --to <B>
                         List all primes in the closed interval [A, B]
  nth   <N>              Print the N-th prime (1-indexed, nth 1 == 2)
  version                Print version information
  help                   Show this help message

Examples:
  primes-cli check 97
  primes-cli list --to 50
  primes-cli range --from 10 --to 50
  primes-cli nth 100

Copyright 2026 TEAM RelicFrog — Apache-2.0
]],
		VERSION
	))
end

-- ---------------------------------------------------------------------------
-- Subcommands
-- ---------------------------------------------------------------------------

local function cmd_check(args)
	if #args < 1 then
		io.stderr:write("Usage: primes-cli check <N>\n")
		os.exit(1)
	end
	local n = parse_int(args[1])
	if primes.is_prime(n) then
		print(n .. " is prime")
		os.exit(0)
	else
		print(n .. " is not prime")
		os.exit(1)
	end
end

local function cmd_list(args)
	local flags = parse_flags(args)
	if not flags["to"] then
		io.stderr:write("Usage: primes-cli list --to <N>\n")
		os.exit(1)
	end
	local limit = parse_int(flags["to"])
	local ok, result = pcall(primes.sieve_of_eratosthenes, limit)
	if not ok then
		io.stderr:write("error: " .. result .. "\n")
		os.exit(1)
	end
	print_list(result)
end

local function cmd_range(args)
	local flags = parse_flags(args)
	if not flags["to"] then
		io.stderr:write("Usage: primes-cli range --from <A> --to <B>\n")
		os.exit(1)
	end
	local from = flags["from"] and parse_int(flags["from"]) or 0
	local to = parse_int(flags["to"])
	local ok, result = pcall(primes.primes_in_range, from, to)
	if not ok then
		io.stderr:write("error: " .. result .. "\n")
		os.exit(1)
	end
	print_list(result)
end

local function cmd_nth(args)
	if #args < 1 then
		io.stderr:write("Usage: primes-cli nth <N>\n")
		os.exit(1)
	end
	local n = parse_int(args[1])
	if n < 1 then
		io.stderr:write("error: n must be >= 1\n")
		os.exit(1)
	end
	local ok, result = pcall(primes.nth_prime, n)
	if not ok then
		io.stderr:write("error: " .. result .. "\n")
		os.exit(1)
	end
	print(result)
end

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

local cmd = arg[1]

if not cmd or cmd == "help" or cmd == "--help" or cmd == "-h" then
	print_usage()
	os.exit(0)
elseif cmd == "version" or cmd == "--version" then
	print("primes-cli " .. VERSION .. " (LuaJIT)")
elseif cmd == "check" then
	cmd_check({ unpack(arg, 2) })
elseif cmd == "list" then
	cmd_list({ unpack(arg, 2) })
elseif cmd == "range" then
	cmd_range({ unpack(arg, 2) })
elseif cmd == "nth" then
	cmd_nth({ unpack(arg, 2) })
else
	io.stderr:write(string.format('error: unknown command "%s"\n\n', cmd))
	print_usage()
	os.exit(1)
end
