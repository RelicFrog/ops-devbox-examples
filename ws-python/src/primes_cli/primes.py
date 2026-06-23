# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
"""Core prime number algorithms for primes-cli.

Provides:
    - is_prime(n)                  — deterministic primality test (trial division)
    - sieve_of_eratosthenes(limit) — all primes up to limit
    - primes_in_range(start, end)  — primes in a closed interval
    - nth_prime(n)                 — the n-th prime (1-indexed)

All functions operate on plain Python integers (arbitrary precision).
No external dependencies — stdlib only.
"""

from __future__ import annotations

import math

# ---------------------------------------------------------------------------
# is_prime
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Return True if *n* is a prime number.

    Uses trial division up to sqrt(n).  Handles n < 2, n == 2 and
    even numbers as fast paths.
    """
    if not isinstance(n, int) or n < 0:
        msg = f"is_prime: expected non-negative integer, got {n!r}"
        raise TypeError(msg)
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    limit = math.isqrt(n)
    for i in range(3, limit + 1, 2):
        if n % i == 0:
            return False
    return True


# ---------------------------------------------------------------------------
# sieve_of_eratosthenes
# ---------------------------------------------------------------------------


def sieve_of_eratosthenes(limit: int) -> list[int]:
    """Return all prime numbers up to and including *limit*.

    Raises:
        ValueError: if *limit* < 2.
    """
    if not isinstance(limit, int) or limit < 0:
        msg = f"sieve_of_eratosthenes: expected non-negative integer, got {limit!r}"
        raise TypeError(msg)
    if limit < 2:
        msg = f"sieve_of_eratosthenes: limit must be >= 2, got {limit}"
        raise ValueError(msg)

    composite = bytearray(limit + 1)  # 0 = prime candidate, 1 = composite
    composite[0] = 1
    composite[1] = 1

    i = 2
    while i * i <= limit:
        if not composite[i]:
            for j in range(i * i, limit + 1, i):
                composite[j] = 1
        i += 1

    return [i for i in range(2, limit + 1) if not composite[i]]


# ---------------------------------------------------------------------------
# primes_in_range
# ---------------------------------------------------------------------------


def primes_in_range(start: int, end: int) -> list[int]:
    """Return all primes in the closed interval [start, end].

    Raises:
        ValueError: if *start* > *end*.
    """
    if start > end:
        msg = f"primes_in_range: start ({start}) must be <= end ({end})"
        raise ValueError(msg)
    if end < 2:
        return []
    return [p for p in sieve_of_eratosthenes(end) if p >= start]


# ---------------------------------------------------------------------------
# nth_prime
# ---------------------------------------------------------------------------


def nth_prime(n: int) -> int:
    """Return the n-th prime (1-indexed: nth_prime(1) == 2).

    Raises:
        ValueError: if *n* < 1.
    """
    if not isinstance(n, int) or n < 1:
        msg = f"nth_prime: n must be a positive integer >= 1, got {n!r}"
        raise ValueError(msg)

    count = 0
    candidate = 2
    while True:
        if is_prime(candidate):
            count += 1
            if count == n:
                return candidate
        candidate += 1
