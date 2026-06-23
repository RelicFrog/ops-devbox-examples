// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// tests/integration.zig — Integration tests for primes-cli (Zig).

const std = @import("std");
const primes = @import("primes.zig");

test "round-trip: nthPrime consistent with sieve (first 50)" {
    const alloc = std.testing.allocator;
    const sieve = try primes.sieveOfEratosthenes(alloc, 230);
    defer alloc.free(sieve);

    for (sieve, 0..) |expected, i| {
        const got = try primes.nthPrime(@intCast(i + 1));
        try std.testing.expectEqual(expected, got);
    }
}

test "primesInRange first 100 matches sieve" {
    const alloc = std.testing.allocator;
    const sieve = try primes.sieveOfEratosthenes(alloc, 541);
    defer alloc.free(sieve);

    const range = try primes.primesInRange(alloc, 2, 541);
    defer alloc.free(range);

    try std.testing.expectEqual(@as(usize, 100), range.len);
    try std.testing.expectEqualSlices(u64, sieve, range);
}

test "isPrime consistent with sieve for 0..200" {
    const alloc = std.testing.allocator;
    const sieve = try primes.sieveOfEratosthenes(alloc, 200);
    defer alloc.free(sieve);

    var sieve_set = std.AutoHashMap(u64, void).init(alloc);
    defer sieve_set.deinit();
    for (sieve) |p| try sieve_set.put(p, {});

    var n: u64 = 0;
    while (n <= 200) : (n += 1) {
        const got = primes.isPrime(n);
        const want = sieve_set.contains(n);
        try std.testing.expectEqual(want, got);
    }
}

test "error propagation: sieve limit=0" {
    const alloc = std.testing.allocator;
    try std.testing.expectError(primes.PrimeError.LimitTooSmall, primes.sieveOfEratosthenes(alloc, 0));
}

test "error propagation: range start > end" {
    const alloc = std.testing.allocator;
    try std.testing.expectError(primes.PrimeError.InvalidRange, primes.primesInRange(alloc, 50, 10));
}

test "error propagation: nth 0" {
    try std.testing.expectError(primes.PrimeError.InvalidNthIndex, primes.nthPrime(0));
}

test "comptime table sanity: all 1000 entries are prime" {
    for (primes.PRIMES_TABLE) |p| {
        try std.testing.expect(primes.isPrime(p));
    }
}

test "large primes detected" {
    for ([_]u64{ 7919, 104729, 999_983 }) |p| {
        try std.testing.expect(primes.isPrime(p));
    }
}

test "large composites rejected" {
    for ([_]u64{ 7920, 104728, 999_999 }) |c| {
        try std.testing.expect(!primes.isPrime(c));
    }
}
