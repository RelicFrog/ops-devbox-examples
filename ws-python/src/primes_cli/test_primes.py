# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
"""Unit tests for primes_cli.primes — runs via pytest from Nix."""

from __future__ import annotations

import pytest

from primes_cli.primes import (
    is_prime,
    nth_prime,
    primes_in_range,
    sieve_of_eratosthenes,
)

# ---------------------------------------------------------------------------
# is_prime
# ---------------------------------------------------------------------------


class TestIsPrime:
    def test_below_two_is_false(self) -> None:
        assert is_prime(0) is False
        assert is_prime(1) is False

    def test_two_is_prime(self) -> None:
        assert is_prime(2) is True

    def test_three_is_prime(self) -> None:
        assert is_prime(3) is True

    def test_even_composites(self) -> None:
        assert is_prime(4) is False
        assert is_prime(100) is False
        assert is_prime(1_000_000) is False

    @pytest.mark.parametrize("p", [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97])
    def test_known_primes(self, p: int) -> None:
        assert is_prime(p) is True

    @pytest.mark.parametrize("c", [4, 6, 8, 9, 15, 25, 49, 91, 100])
    def test_known_composites(self, c: int) -> None:
        assert is_prime(c) is False

    def test_large_prime(self) -> None:
        assert is_prime(999_983) is True

    def test_large_composite(self) -> None:
        assert is_prime(999_999) is False  # 3 x 333333

    def test_invalid_type_raises(self) -> None:
        with pytest.raises(TypeError):
            is_prime(-1)  # type: ignore[call-overload]


# ---------------------------------------------------------------------------
# sieve_of_eratosthenes
# ---------------------------------------------------------------------------


class TestSieve:
    def test_limit_below_two_raises(self) -> None:
        with pytest.raises(ValueError):
            sieve_of_eratosthenes(1)
        with pytest.raises(ValueError):
            sieve_of_eratosthenes(0)

    def test_limit_two_returns_two(self) -> None:
        assert sieve_of_eratosthenes(2) == [2]

    def test_limit_ten(self) -> None:
        assert sieve_of_eratosthenes(10) == [2, 3, 5, 7]

    def test_limit_thirty(self) -> None:
        assert sieve_of_eratosthenes(30) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

    def test_25_primes_below_100(self) -> None:
        # There are 25 primes <= 99 (i.e., below 100): 2..97
        assert len(sieve_of_eratosthenes(99)) == 25

    def test_25_primes_up_to_100(self) -> None:
        assert len(sieve_of_eratosthenes(100)) == 25


# ---------------------------------------------------------------------------
# primes_in_range
# ---------------------------------------------------------------------------


class TestPrimesInRange:
    def test_start_greater_than_end_raises(self) -> None:
        with pytest.raises(ValueError):
            primes_in_range(10, 5)

    def test_end_below_two_returns_empty(self) -> None:
        assert primes_in_range(0, 1) == []

    def test_single_prime(self) -> None:
        assert primes_in_range(7, 7) == [7]

    def test_ten_to_twenty(self) -> None:
        assert primes_in_range(10, 20) == [11, 13, 17, 19]

    def test_composite_singleton(self) -> None:
        assert primes_in_range(9, 9) == []


# ---------------------------------------------------------------------------
# nth_prime
# ---------------------------------------------------------------------------


class TestNthPrime:
    def test_zero_raises(self) -> None:
        with pytest.raises(ValueError):
            nth_prime(0)

    def test_first_is_two(self) -> None:
        assert nth_prime(1) == 2

    def test_second_is_three(self) -> None:
        assert nth_prime(2) == 3

    def test_tenth_is_twenty_nine(self) -> None:
        assert nth_prime(10) == 29

    def test_hundredth_is_541(self) -> None:
        assert nth_prime(100) == 541

    def test_sequence_matches_sieve(self) -> None:
        sieve = sieve_of_eratosthenes(30)
        for i, expected in enumerate(sieve, start=1):
            assert nth_prime(i) == expected
