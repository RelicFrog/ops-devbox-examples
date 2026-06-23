// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes.ts — Core prime number algorithms for primes-cli.
//
// Provides:
//   - isPrime(n)                  — deterministic primality test (trial division)
//   - sieveOfEratosthenes(limit)  — all primes up to limit
//   - primesInRange(start, end)   — primes in a closed interval
//   - nthPrime(n)                 — the n-th prime (1-indexed)

// ---------------------------------------------------------------------------
// Error types
// ---------------------------------------------------------------------------

export class LimitTooSmallError extends Error {
  constructor(limit: bigint) {
    super(`limit must be >= 2, got ${limit}`);
    this.name = "LimitTooSmallError";
  }
}

export class InvalidRangeError extends Error {
  constructor(
    public readonly start: bigint,
    public readonly end: bigint,
  ) {
    super(`range start (${start}) must be <= end (${end})`);
    this.name = "InvalidRangeError";
  }
}

export class InvalidNthIndexError extends Error {
  constructor() {
    super("n must be >= 1");
    this.name = "InvalidNthIndexError";
  }
}

// ---------------------------------------------------------------------------
// isPrime
// ---------------------------------------------------------------------------

/**
 * Returns true if n is a prime number.
 * Uses trial division up to sqrt(n).
 */
export function isPrime(n: bigint): boolean {
  if (n < 2n) return false;
  if (n === 2n) return true;
  if (n % 2n === 0n) return false;

  const limit = BigInt(Math.floor(Math.sqrt(Number(n))));
  for (let i = 3n; i <= limit; i += 2n) {
    if (n % i === 0n) return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// sieveOfEratosthenes
// ---------------------------------------------------------------------------

/**
 * Returns all prime numbers up to and including limit.
 * Throws LimitTooSmallError if limit < 2.
 */
export function sieveOfEratosthenes(limit: bigint): bigint[] {
  if (limit < 2n) {
    throw new LimitTooSmallError(limit);
  }

  const size = Number(limit) + 1;
  const composite = new Uint8Array(size);
  composite[0] = 1;
  composite[1] = 1;

  for (let i = 2; i * i <= Number(limit); i++) {
    if (!composite[i]) {
      for (let j = i * i; j <= Number(limit); j += i) {
        composite[j] = 1;
      }
    }
  }

  const primes: bigint[] = [];
  for (let i = 2; i <= Number(limit); i++) {
    if (!composite[i]) primes.push(BigInt(i));
  }
  return primes;
}

// ---------------------------------------------------------------------------
// primesInRange
// ---------------------------------------------------------------------------

/**
 * Returns all prime numbers in the closed interval [start, end].
 * Throws InvalidRangeError if start > end.
 */
export function primesInRange(start: bigint, end: bigint): bigint[] {
  if (start > end) {
    throw new InvalidRangeError(start, end);
  }
  if (end < 2n) return [];

  return sieveOfEratosthenes(end).filter((p) => p >= start);
}

// ---------------------------------------------------------------------------
// nthPrime
// ---------------------------------------------------------------------------

/**
 * Returns the n-th prime (1-indexed: nthPrime(1n) === 2n).
 * Throws InvalidNthIndexError if n === 0.
 */
export function nthPrime(n: bigint): bigint {
  if (n === 0n) throw new InvalidNthIndexError();

  let count = 0n;
  for (let candidate = 2n; ; candidate++) {
    if (isPrime(candidate)) {
      count++;
      if (count === n) return candidate;
    }
  }
}
