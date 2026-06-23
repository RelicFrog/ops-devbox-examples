// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes.test.ts — Unit tests for the primes module.
// Uses the built-in node:test runner (no external dependencies).

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
} from "./primes.js";

// ---------------------------------------------------------------------------
// isPrime
// ---------------------------------------------------------------------------

describe("isPrime", () => {
  it("returns false for values below 2", () => {
    assert.equal(isPrime(0n), false);
    assert.equal(isPrime(1n), false);
  });

  it("returns true for 2", () => {
    assert.equal(isPrime(2n), true);
  });

  it("returns true for 3", () => {
    assert.equal(isPrime(3n), true);
  });

  it("returns false for even composites", () => {
    assert.equal(isPrime(4n), false);
    assert.equal(isPrime(100n), false);
    assert.equal(isPrime(1_000_000n), false);
  });

  it("returns true for known primes", () => {
    const known = [2n, 3n, 5n, 7n, 11n, 13n, 17n, 19n, 23n, 29n, 31n, 97n];
    for (const p of known) {
      assert.equal(isPrime(p), true, `${p} should be prime`);
    }
  });

  it("returns false for known composites", () => {
    const known = [4n, 6n, 8n, 9n, 15n, 25n, 49n, 91n, 100n];
    for (const c of known) {
      assert.equal(isPrime(c), false, `${c} should not be prime`);
    }
  });

  it("returns true for a large prime", () => {
    assert.equal(isPrime(999_983n), true);
  });

  it("returns false for a large composite", () => {
    assert.equal(isPrime(999_999n), false); // 3 × 333333
  });
});

// ---------------------------------------------------------------------------
// sieveOfEratosthenes
// ---------------------------------------------------------------------------

describe("sieveOfEratosthenes", () => {
  it("throws LimitTooSmallError for limit < 2", () => {
    assert.throws(() => sieveOfEratosthenes(0n), LimitTooSmallError);
    assert.throws(() => sieveOfEratosthenes(1n), LimitTooSmallError);
  });

  it("returns [2] for limit=2", () => {
    assert.deepEqual(sieveOfEratosthenes(2n), [2n]);
  });

  it("returns primes up to 10", () => {
    assert.deepEqual(sieveOfEratosthenes(10n), [2n, 3n, 5n, 7n]);
  });

  it("returns primes up to 30", () => {
    assert.deepEqual(sieveOfEratosthenes(30n), [2n, 3n, 5n, 7n, 11n, 13n, 17n, 19n, 23n, 29n]);
  });

  it("returns 25 primes for limit=99 (primes below 100)", () => {
    // There are 25 primes <= 99: 2..97
    assert.equal(sieveOfEratosthenes(99n).length, 25);
  });

  it("returns 25 primes for limit=100", () => {
    assert.equal(sieveOfEratosthenes(100n).length, 25);
  });
});

// ---------------------------------------------------------------------------
// primesInRange
// ---------------------------------------------------------------------------

describe("primesInRange", () => {
  it("throws InvalidRangeError when start > end", () => {
    assert.throws(() => primesInRange(10n, 5n), InvalidRangeError);
  });

  it("returns [] when end < 2", () => {
    assert.deepEqual(primesInRange(0n, 1n), []);
  });

  it("returns [7] for range [7, 7]", () => {
    assert.deepEqual(primesInRange(7n, 7n), [7n]);
  });

  it("returns primes in [10, 20]", () => {
    assert.deepEqual(primesInRange(10n, 20n), [11n, 13n, 17n, 19n]);
  });

  it("returns [] for a composite singleton range", () => {
    assert.deepEqual(primesInRange(9n, 9n), []);
  });
});

// ---------------------------------------------------------------------------
// nthPrime
// ---------------------------------------------------------------------------

describe("nthPrime", () => {
  it("throws InvalidNthIndexError for n=0", () => {
    assert.throws(() => nthPrime(0n), InvalidNthIndexError);
  });

  it("returns 2 for n=1", () => {
    assert.equal(nthPrime(1n), 2n);
  });

  it("returns 3 for n=2", () => {
    assert.equal(nthPrime(2n), 3n);
  });

  it("returns 29 for n=10", () => {
    assert.equal(nthPrime(10n), 29n);
  });

  it("returns 541 for n=100", () => {
    assert.equal(nthPrime(100n), 541n);
  });

  it("sequence matches sieve for first 10 primes", () => {
    const sieve = sieveOfEratosthenes(30n);
    for (let i = 0; i < sieve.length; i++) {
      assert.equal(nthPrime(BigInt(i + 1)), sieve[i]);
    }
  });
});
