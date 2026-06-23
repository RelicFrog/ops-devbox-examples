# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
"""Integration tests for primes_cli."""

from __future__ import annotations

import pytest

from primes_cli.primes import (
    is_prime,
    nth_prime,
    primes_in_range,
    sieve_of_eratosthenes,
)


class TestNthPrimeConsistentWithSieve:
    def test_first_50_primes(self) -> None:
        sieve = sieve_of_eratosthenes(230)  # 230 > 50th prime (229)
        for i, expected in enumerate(sieve, start=1):
            assert nth_prime(i) == expected, f"nth_prime({i}) should be {expected}"


class TestPrimesInRangeFirstHundred:
    def test_matches_sieve(self) -> None:
        sieve = sieve_of_eratosthenes(541)  # 541 == 100th prime
        rang = primes_in_range(2, 541)
        assert len(rang) == 100
        assert rang == sieve


class TestIsPrimeConsistentWithSieve:
    def test_up_to_200(self) -> None:
        sieve_set = set(sieve_of_eratosthenes(200))
        for n in range(201):
            assert is_prime(n) == (n in sieve_set), f"is_prime({n}) disagrees with sieve"


class TestErrorPropagation:
    def test_sieve_limit_zero(self) -> None:
        with pytest.raises(ValueError):
            sieve_of_eratosthenes(0)

    def test_range_inverted(self) -> None:
        with pytest.raises(ValueError):
            primes_in_range(50, 10)

    def test_nth_prime_zero(self) -> None:
        with pytest.raises(ValueError):
            nth_prime(0)


class TestLargePrimes:
    @pytest.mark.parametrize("p", [7919, 104729, 999_983])
    def test_known_large_primes(self, p: int) -> None:
        assert is_prime(p) is True

    @pytest.mark.parametrize("c", [7920, 104728, 999_999])
    def test_known_large_composites(self, c: int) -> None:
        assert is_prime(c) is False
