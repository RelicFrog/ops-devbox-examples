-- Copyright 2026 TEAM RelicFrog
-- SPDX-License-Identifier: Apache-2.0
--
-- src/primes_test.lua — Unit tests for the primes module (LuaJIT).
-- Uses a minimal inline test harness (no external dependencies).

local primes = require("primes")

-- ---------------------------------------------------------------------------
-- Minimal test harness
-- ---------------------------------------------------------------------------

local pass = 0
local fail = 0

local function ok(desc, cond)
	if cond then
		pass = pass + 1
		io.write(string.format("  ok  %d — %s\n", pass + fail, desc))
	else
		fail = fail + 1
		io.write(string.format("  FAIL %d — %s\n", pass + fail, desc))
	end
end

local function raises(desc, fn)
	local ok_flag, _ = pcall(fn)
	ok(desc, not ok_flag)
end

local function eq_list(a, b)
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

-- ---------------------------------------------------------------------------
-- is_prime
-- ---------------------------------------------------------------------------

ok("is_prime(0) == false", not primes.is_prime(0))
ok("is_prime(1) == false", not primes.is_prime(1))
ok("is_prime(2) == true", primes.is_prime(2))
ok("is_prime(3) == true", primes.is_prime(3))
ok("is_prime(4) == false", not primes.is_prime(4))
ok("is_prime(100) == false", not primes.is_prime(100))
ok("is_prime(97) == true", primes.is_prime(97))
ok("is_prime(999983) == true", primes.is_prime(999983))
ok("is_prime(999999) == false", not primes.is_prime(999999))

for _, p in ipairs({ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97 }) do
	ok("is_prime(" .. p .. ")", primes.is_prime(p))
end

for _, c in ipairs({ 4, 6, 8, 9, 15, 25, 49, 91, 100 }) do
	ok("not is_prime(" .. c .. ")", not primes.is_prime(c))
end

-- ---------------------------------------------------------------------------
-- sieve_of_eratosthenes
-- ---------------------------------------------------------------------------

raises("sieve limit=1 raises", function()
	primes.sieve_of_eratosthenes(1)
end)
raises("sieve limit=0 raises", function()
	primes.sieve_of_eratosthenes(0)
end)
raises("sieve limit=-1 raises", function()
	primes.sieve_of_eratosthenes(-1)
end)

ok("sieve(2) == {2}", eq_list(primes.sieve_of_eratosthenes(2), { 2 }))
ok("sieve(10) == {2,3,5,7}", eq_list(primes.sieve_of_eratosthenes(10), { 2, 3, 5, 7 }))
ok("sieve(30) has 10 primes", #primes.sieve_of_eratosthenes(30) == 10)
ok("sieve(99) has 25 primes", #primes.sieve_of_eratosthenes(99) == 25)
ok("sieve(100) has 25 primes", #primes.sieve_of_eratosthenes(100) == 25)

-- ---------------------------------------------------------------------------
-- primes_in_range
-- ---------------------------------------------------------------------------

raises("range start>end raises", function()
	primes.primes_in_range(10, 5)
end)

ok("range(0,1) == {}", eq_list(primes.primes_in_range(0, 1), {}))
ok("range(7,7) == {7}", eq_list(primes.primes_in_range(7, 7), { 7 }))
ok("range(9,9) == {}", eq_list(primes.primes_in_range(9, 9), {}))
ok("range(10,20) correct", eq_list(primes.primes_in_range(10, 20), { 11, 13, 17, 19 }))

-- ---------------------------------------------------------------------------
-- nth_prime
-- ---------------------------------------------------------------------------

raises("nth_prime(0) raises", function()
	primes.nth_prime(0)
end)
raises("nth_prime(-1) raises", function()
	primes.nth_prime(-1)
end)

ok("nth_prime(1) == 2", primes.nth_prime(1) == 2)
ok("nth_prime(2) == 3", primes.nth_prime(2) == 3)
ok("nth_prime(10) == 29", primes.nth_prime(10) == 29)
ok("nth_prime(100) == 541", primes.nth_prime(100) == 541)

local sieve = primes.sieve_of_eratosthenes(30)
for i, expected in ipairs(sieve) do
	ok("nth_prime(" .. i .. ") == " .. expected, primes.nth_prime(i) == expected)
end

-- ---------------------------------------------------------------------------
-- Summary
-- ---------------------------------------------------------------------------

print(string.format("\n%d tests run: %d passed, %d failed", pass + fail, pass, fail))
if fail > 0 then
	os.exit(1)
end
