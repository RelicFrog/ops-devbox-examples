// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes.zig — Core prime number algorithms for primes-cli.
//
// The highlight: COMPTIME_LIMIT first primes are computed at *compile time*
// via a comptime Sieve of Eratosthenes and embedded in the binary as a
// constant array. nth_prime() and is_prime() use this table for fast O(1)
// lookup when n <= COMPTIME_LIMIT, falling back to runtime algorithms
// for larger values.

const std = @import("std");

// ---------------------------------------------------------------------------
// Compile-time sieve
// ---------------------------------------------------------------------------

/// Number of primes precomputed at compile time and embedded in the binary.
pub const COMPTIME_LIMIT: usize = 1000;

/// Upper bound for the sieve: the 1000th prime is 7919.
const SIEVE_BOUND: usize = 8000;

/// Compute the first `count` primes at compile time.
fn comptimePrimes(comptime count: usize) [count]u64 {
    @setEvalBranchQuota(1_000_000);
    var composite: [SIEVE_BOUND + 1]bool = [_]bool{false} ** (SIEVE_BOUND + 1);
    composite[0] = true;
    composite[1] = true;

    var i: usize = 2;
    while (i * i <= SIEVE_BOUND) : (i += 1) {
        if (!composite[i]) {
            var j = i * i;
            while (j <= SIEVE_BOUND) : (j += i) {
                composite[j] = true;
            }
        }
    }

    var result: [count]u64 = undefined;
    var idx: usize = 0;
    var n: usize = 2;
    while (idx < count) : (n += 1) {
        if (!composite[n]) {
            result[idx] = @intCast(n);
            idx += 1;
        }
    }
    return result;
}

/// Compile-time constant: first 1000 primes embedded in the binary.
pub const PRIMES_TABLE: [COMPTIME_LIMIT]u64 = comptimePrimes(COMPTIME_LIMIT);

// ---------------------------------------------------------------------------
// Error types
// ---------------------------------------------------------------------------

pub const PrimeError = error{
    LimitTooSmall,
    InvalidRange,
    InvalidNthIndex,
    OutOfMemory,
};

// ---------------------------------------------------------------------------
// is_prime
// ---------------------------------------------------------------------------

/// Returns true if n is a prime number.
/// Uses the comptime table for n <= PRIMES_TABLE[COMPTIME_LIMIT-1],
/// falls back to trial division for larger values.
pub fn isPrime(n: u64) bool {
    if (n < 2) return false;

    // O(log N) binary search in the comptime table
    if (n <= PRIMES_TABLE[COMPTIME_LIMIT - 1]) {
        var lo: usize = 0;
        var hi: usize = COMPTIME_LIMIT;
        while (lo < hi) {
            const mid = lo + (hi - lo) / 2;
            if (PRIMES_TABLE[mid] < n) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        return lo < COMPTIME_LIMIT and PRIMES_TABLE[lo] == n;
    }

    // Runtime trial division for large values
    if (n % 2 == 0) return false;
    var i: u64 = 3;
    while (i * i <= n) : (i += 2) {
        if (n % i == 0) return false;
    }
    return true;
}

// ---------------------------------------------------------------------------
// sieve_of_eratosthenes
// ---------------------------------------------------------------------------

/// Returns all primes up to and including limit.
/// Caller owns the returned slice (allocated with allocator).
pub fn sieveOfEratosthenes(allocator: std.mem.Allocator, limit: u64) PrimeError![]u64 {
    if (limit < 2) return PrimeError.LimitTooSmall;

    const size = @as(usize, @intCast(limit)) + 1;
    const composite = try allocator.alloc(bool, size);
    defer allocator.free(composite);
    @memset(composite, false);
    composite[0] = true;
    composite[1] = true;

    var i: usize = 2;
    while (i * i <= @as(usize, @intCast(limit))) : (i += 1) {
        if (!composite[i]) {
            var j = i * i;
            while (j <= @as(usize, @intCast(limit))) : (j += i) {
                composite[j] = true;
            }
        }
    }

    // Count primes first to allocate exact size
    var count: usize = 0;
    for (composite) |c| {
        if (!c) count += 1;
    }

    const result = try allocator.alloc(u64, count);
    var idx: usize = 0;
    for (composite, 0..) |c, n| {
        if (!c) {
            result[idx] = @intCast(n);
            idx += 1;
        }
    }
    return result;
}

// ---------------------------------------------------------------------------
// primes_in_range
// ---------------------------------------------------------------------------

/// Returns all primes in the closed interval [start, end].
/// Caller owns the returned slice.
pub fn primesInRange(allocator: std.mem.Allocator, start: u64, end: u64) PrimeError![]u64 {
    if (start > end) return PrimeError.InvalidRange;
    if (end < 2) return allocator.alloc(u64, 0) catch return PrimeError.LimitTooSmall;

    const all = try sieveOfEratosthenes(allocator, end);
    defer allocator.free(all);

    var count: usize = 0;
    for (all) |p| {
        if (p >= start) count += 1;
    }

    const result = try allocator.alloc(u64, count);
    var idx: usize = 0;
    for (all) |p| {
        if (p >= start) {
            result[idx] = p;
            idx += 1;
        }
    }
    return result;
}

// ---------------------------------------------------------------------------
// nth_prime
// ---------------------------------------------------------------------------

/// Returns the n-th prime (1-indexed: nthPrime(1) == 2).
/// Uses the comptime table for n <= COMPTIME_LIMIT (O(1)),
/// falls back to incremental search for larger n.
pub fn nthPrime(n: u64) PrimeError!u64 {
    if (n == 0) return PrimeError.InvalidNthIndex;

    // O(1) comptime table lookup
    if (n <= COMPTIME_LIMIT) return PRIMES_TABLE[@intCast(n - 1)];

    // Runtime fallback: start from the last known comptime prime
    var count: u64 = COMPTIME_LIMIT;
    var candidate: u64 = PRIMES_TABLE[COMPTIME_LIMIT - 1] + 2;
    while (count < n) : (candidate += 2) {
        if (isPrime(candidate)) count += 1;
    }
    return candidate - 2;
}

// ---------------------------------------------------------------------------
// Unit tests
// ---------------------------------------------------------------------------

test "isPrime: below 2 is false" {
    try std.testing.expect(!isPrime(0));
    try std.testing.expect(!isPrime(1));
}

test "isPrime: 2 is prime" {
    try std.testing.expect(isPrime(2));
}

test "isPrime: 3 is prime" {
    try std.testing.expect(isPrime(3));
}

test "isPrime: even composites" {
    try std.testing.expect(!isPrime(4));
    try std.testing.expect(!isPrime(100));
    try std.testing.expect(!isPrime(1_000_000));
}

test "isPrime: known primes" {
    const known = [_]u64{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97 };
    for (known) |p| try std.testing.expect(isPrime(p));
}

test "isPrime: known composites" {
    const known = [_]u64{ 4, 6, 8, 9, 15, 25, 49, 91, 100 };
    for (known) |c| try std.testing.expect(!isPrime(c));
}

test "isPrime: large prime" {
    try std.testing.expect(isPrime(999_983));
}

test "isPrime: large composite" {
    try std.testing.expect(!isPrime(999_999));
}

test "comptime table: first prime is 2" {
    try std.testing.expectEqual(@as(u64, 2), PRIMES_TABLE[0]);
}

test "comptime table: 100th prime is 541" {
    try std.testing.expectEqual(@as(u64, 541), PRIMES_TABLE[99]);
}

test "comptime table: 1000th prime is 7919" {
    try std.testing.expectEqual(@as(u64, 7919), PRIMES_TABLE[999]);
}

test "sieve: limit < 2 returns error" {
    const alloc = std.testing.allocator;
    try std.testing.expectError(PrimeError.LimitTooSmall, sieveOfEratosthenes(alloc, 1));
    try std.testing.expectError(PrimeError.LimitTooSmall, sieveOfEratosthenes(alloc, 0));
}

test "sieve: limit=2 returns [2]" {
    const alloc = std.testing.allocator;
    const result = try sieveOfEratosthenes(alloc, 2);
    defer alloc.free(result);
    try std.testing.expectEqualSlices(u64, &[_]u64{2}, result);
}

test "sieve: limit=10 returns [2,3,5,7]" {
    const alloc = std.testing.allocator;
    const result = try sieveOfEratosthenes(alloc, 10);
    defer alloc.free(result);
    try std.testing.expectEqualSlices(u64, &[_]u64{ 2, 3, 5, 7 }, result);
}

test "sieve: limit=30 returns 10 primes" {
    const alloc = std.testing.allocator;
    const result = try sieveOfEratosthenes(alloc, 30);
    defer alloc.free(result);
    try std.testing.expectEqualSlices(
        u64,
        &[_]u64{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 },
        result,
    );
}

test "sieve: 25 primes up to 99" {
    const alloc = std.testing.allocator;
    const result = try sieveOfEratosthenes(alloc, 99);
    defer alloc.free(result);
    try std.testing.expectEqual(@as(usize, 25), result.len);
}

test "sieve: 25 primes up to 100" {
    const alloc = std.testing.allocator;
    const result = try sieveOfEratosthenes(alloc, 100);
    defer alloc.free(result);
    try std.testing.expectEqual(@as(usize, 25), result.len);
}

test "primesInRange: start > end returns error" {
    const alloc = std.testing.allocator;
    try std.testing.expectError(PrimeError.InvalidRange, primesInRange(alloc, 10, 5));
}

test "primesInRange: end < 2 returns empty" {
    const alloc = std.testing.allocator;
    const result = try primesInRange(alloc, 0, 1);
    defer alloc.free(result);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "primesInRange: [7,7] returns [7]" {
    const alloc = std.testing.allocator;
    const result = try primesInRange(alloc, 7, 7);
    defer alloc.free(result);
    try std.testing.expectEqualSlices(u64, &[_]u64{7}, result);
}

test "primesInRange: [10,20] returns [11,13,17,19]" {
    const alloc = std.testing.allocator;
    const result = try primesInRange(alloc, 10, 20);
    defer alloc.free(result);
    try std.testing.expectEqualSlices(u64, &[_]u64{ 11, 13, 17, 19 }, result);
}

test "nthPrime: 0 returns error" {
    try std.testing.expectError(PrimeError.InvalidNthIndex, nthPrime(0));
}

test "nthPrime: 1st is 2" {
    try std.testing.expectEqual(@as(u64, 2), try nthPrime(1));
}

test "nthPrime: 10th is 29" {
    try std.testing.expectEqual(@as(u64, 29), try nthPrime(10));
}

test "nthPrime: 100th is 541" {
    try std.testing.expectEqual(@as(u64, 541), try nthPrime(100));
}

test "nthPrime: sequence matches sieve" {
    const alloc = std.testing.allocator;
    const sieve = try sieveOfEratosthenes(alloc, 30);
    defer alloc.free(sieve);
    for (sieve, 0..) |expected, i| {
        const got = try nthPrime(@intCast(i + 1));
        try std.testing.expectEqual(expected, got);
    }
}
