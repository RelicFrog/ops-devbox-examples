-- Copyright 2026 TEAM RelicFrog
-- SPDX-License-Identifier: Apache-2.0
--
-- tests/integration_test.lua — Integration tests for primes module.

local primes = require("primes")

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

local function eq_list(a, b)
  if #a ~= #b then return false end
  for i = 1, #a do
    if a[i] ~= b[i] then return false end
  end
  return true
end

-- Round-trip: nth_prime consistent with sieve (first 50)
local sieve230 = primes.sieve_of_eratosthenes(230)
local all_match = true
for i, expected in ipairs(sieve230) do
  if primes.nth_prime(i) ~= expected then all_match = false; break end
end
ok("nth_prime consistent with sieve (first " .. #sieve230 .. " primes)", all_match)

-- primesInRange first 100 matches sieve
local sieve541  = primes.sieve_of_eratosthenes(541)
local range541  = primes.primes_in_range(2, 541)
ok("primesInRange(2,541) length == 100", #range541 == 100)
ok("primesInRange(2,541) matches sieve", eq_list(range541, sieve541))

-- isPrime consistent with sieve for 0..200
local sieve200 = primes.sieve_of_eratosthenes(200)
local sieve_set = {}
for _, p in ipairs(sieve200) do sieve_set[p] = true end
local consistent = true
for n = 0, 200 do
  if primes.is_prime(n) ~= (sieve_set[n] == true) then
    consistent = false; break
  end
end
ok("is_prime consistent with sieve for 0..200", consistent)

-- Error propagation
local ok1, _ = pcall(primes.sieve_of_eratosthenes, 0)
ok("sieve(0) raises",               not ok1)
local ok2, _ = pcall(primes.primes_in_range, 50, 10)
ok("primes_in_range(50,10) raises", not ok2)
local ok3, _ = pcall(primes.nth_prime, 0)
ok("nth_prime(0) raises",           not ok3)

-- Known large primes / composites
for _, p in ipairs({7919, 104729, 999983}) do
  ok("is_prime(" .. p .. ") == true",  primes.is_prime(p))
end
for _, c in ipairs({7920, 104728, 999999}) do
  ok("is_prime(" .. c .. ") == false", not primes.is_prime(c))
end

print(string.format("\n%d integration tests run: %d passed, %d failed", pass + fail, pass, fail))
if fail > 0 then os.exit(1) end
