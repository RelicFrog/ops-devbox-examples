// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// integration.test.ts — Integration tests for the primes module.
// Mirrors the integration tests from ws-rust and ws-go.

import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  InvalidNthIndexError,
  InvalidRangeError,
  isPrime,
  LimitTooSmallError,
  nthPrime,
  primesInRange,
  sieveOfEratosthenes,
} from "../src/primes.js";

// ---------------------------------------------------------------------------
// Round-trip: nthPrime consistent with sieveOfEratosthenes
// ---------------------------------------------------------------------------

describe("nthPrime consistent with sieve (first 50)", () => {
  it("nthPrime(i) === sieve[i-1] for first 50 primes", () => {
    const sieve = sieveOfEratosthenes(230n); // 230 > 50th prime (229)
    for (let i = 0; i < sieve.length; i++) {
      const expected = sieve[i];
      const got = nthPrime(BigInt(i + 1));
      assert.equal(got, expected, `nthPrime(${i + 1}) should be ${expected}`);
    }
  });
});

// ---------------------------------------------------------------------------
// primesInRange covers full first 100 primes
// ---------------------------------------------------------------------------

describe("primesInRange first 100 primes matches sieve", () => {
  it("PrimesInRange(2, 541) === sieve(541), length 100", () => {
    const sieve = sieveOfEratosthenes(541n); // 541 == 100th prime
    const range = primesInRange(2n, 541n);
    assert.equal(range.length, 100);
    assert.deepEqual(range, sieve);
  });
});

// ---------------------------------------------------------------------------
// isPrime consistent with sieve for 0..200
// ---------------------------------------------------------------------------

describe("isPrime consistent with sieve for 0..200", () => {
  it("isPrime(n) matches sieve membership for every n in [0, 200]", () => {
    const sieve = sieveOfEratosthenes(200n);
    const sieveSet = new Set(sieve);

    for (let n = 0n; n <= 200n; n++) {
      const got = isPrime(n);
      const want = sieveSet.has(n);
      assert.equal(got, want, `isPrime(${n}) disagrees with sieve`);
    }
  });
});

// ---------------------------------------------------------------------------
// Error propagation
// ---------------------------------------------------------------------------

describe("error propagation", () => {
  it("sieveOfEratosthenes(0) throws LimitTooSmallError", () => {
    assert.throws(() => sieveOfEratosthenes(0n), LimitTooSmallError);
  });

  it("primesInRange(50, 10) throws InvalidRangeError", () => {
    assert.throws(() => primesInRange(50n, 10n), InvalidRangeError);
  });

  it("nthPrime(0) throws InvalidNthIndexError", () => {
    assert.throws(() => nthPrime(0n), InvalidNthIndexError);
  });
});

// ---------------------------------------------------------------------------
// Known large primes / composites
// ---------------------------------------------------------------------------

describe("large primes and composites", () => {
  it("known large primes are detected", () => {
    for (const p of [7919n, 104729n, 999_983n]) {
      assert.equal(isPrime(p), true, `${p} should be prime`);
    }
  });

  it("known large composites are rejected", () => {
    for (const c of [7920n, 104728n, 999_999n]) {
      assert.equal(isPrime(c), false, `${c} should not be prime`);
    }
  });
});
