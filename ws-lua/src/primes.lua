-- Copyright 2026 TEAM RelicFrog
-- SPDX-License-Identifier: Apache-2.0
--
-- primes.lua — Core prime number algorithms for primes-cli.
--
-- Provides:
--   primes.is_prime(n)                   — primality test (trial division)
--   primes.sieve_of_eratosthenes(limit)  — all primes up to limit
--   primes.primes_in_range(start, end)   — primes in closed interval
--   primes.nth_prime(n)                  — the n-th prime (1-indexed)

local M = {}

-- ---------------------------------------------------------------------------
-- is_prime
-- ---------------------------------------------------------------------------

--- Returns true if n is a prime number.
--- @param n number
--- @return boolean
function M.is_prime(n)
	if type(n) ~= "number" or n ~= math.floor(n) then
		error("is_prime: expected integer, got " .. tostring(n), 2)
	end
	if n < 2 then
		return false
	end
	if n == 2 then
		return true
	end
	if n % 2 == 0 then
		return false
	end
	local limit = math.floor(math.sqrt(n))
	for i = 3, limit, 2 do
		if n % i == 0 then
			return false
		end
	end
	return true
end

-- ---------------------------------------------------------------------------
-- sieve_of_eratosthenes
-- ---------------------------------------------------------------------------

--- Returns a list of all primes up to and including limit.
--- @param limit number
--- @return table list of primes
function M.sieve_of_eratosthenes(limit)
	if type(limit) ~= "number" or limit ~= math.floor(limit) then
		error("sieve_of_eratosthenes: expected integer, got " .. tostring(limit), 2)
	end
	if limit < 2 then
		error("sieve_of_eratosthenes: limit must be >= 2, got " .. tostring(limit), 2)
	end

	local composite = {}
	for i = 0, limit do
		composite[i] = false
	end
	composite[0] = true
	composite[1] = true

	local i = 2
	while i * i <= limit do
		if not composite[i] then
			local j = i * i
			while j <= limit do
				composite[j] = true
				j = j + i
			end
		end
		i = i + 1
	end

	local result = {}
	for n = 2, limit do
		if not composite[n] then
			result[#result + 1] = n
		end
	end
	return result
end

-- ---------------------------------------------------------------------------
-- primes_in_range
-- ---------------------------------------------------------------------------

--- Returns all primes in the closed interval [start, finish].
--- @param start number
--- @param finish number
--- @return table
function M.primes_in_range(start, finish)
	if start > finish then
		error(string.format("primes_in_range: start (%d) must be <= end (%d)", start, finish), 2)
	end
	if finish < 2 then
		return {}
	end

	local all = M.sieve_of_eratosthenes(finish)
	local result = {}
	for _, p in ipairs(all) do
		if p >= start then
			result[#result + 1] = p
		end
	end
	return result
end

-- ---------------------------------------------------------------------------
-- nth_prime
-- ---------------------------------------------------------------------------

--- Returns the n-th prime (1-indexed: nth_prime(1) == 2).
--- @param n number
--- @return number
function M.nth_prime(n)
	if type(n) ~= "number" or n ~= math.floor(n) or n < 1 then
		error("nth_prime: n must be a positive integer >= 1, got " .. tostring(n), 2)
	end

	local count = 0
	local candidate = 2
	while true do
		if M.is_prime(candidate) then
			count = count + 1
			if count == n then
				return candidate
			end
		end
		candidate = candidate + 1
	end
end

return M
