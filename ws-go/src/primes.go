// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes.go — Core prime number algorithms for primes-cli.
//
// Provides:
//   - IsPrime(n)                 — deterministic primality test (trial division)
//   - SieveOfEratosthenes(limit) — all primes up to limit
//   - PrimesInRange(start, end)  — primes in a closed interval
//   - NthPrime(n)                — the n-th prime (1-indexed)

package primes

import (
	"errors"
	"fmt"
	"math"
)

// ---------------------------------------------------------------------------
// Sentinel errors
// ---------------------------------------------------------------------------

// ErrLimitTooSmall is returned when a sieve limit is less than 2.
var ErrLimitTooSmall = errors.New("limit must be >= 2")

// ErrInvalidRange is returned when start > end in PrimesInRange.
type ErrInvalidRange struct {
	Start, End uint64
}

func (e *ErrInvalidRange) Error() string {
	return fmt.Sprintf("range start (%d) must be <= end (%d)", e.Start, e.End)
}

// ErrInvalidNthIndex is returned when n == 0 in NthPrime.
var ErrInvalidNthIndex = errors.New("n must be >= 1")

// ---------------------------------------------------------------------------
// IsPrime
// ---------------------------------------------------------------------------

// IsPrime returns true if n is a prime number.
// Uses trial division up to sqrt(n). Handles n < 2, n == 2, and even
// numbers as fast paths.
func IsPrime(n uint64) bool {
	if n < 2 {
		return false
	}
	if n == 2 {
		return true
	}
	if n%2 == 0 {
		return false
	}

	limit := uint64(math.Sqrt(float64(n)))
	for i := uint64(3); i <= limit; i += 2 {
		if n%i == 0 {
			return false
		}
	}

	return true
}

// ---------------------------------------------------------------------------
// SieveOfEratosthenes
// ---------------------------------------------------------------------------

// SieveOfEratosthenes returns all prime numbers up to and including limit.
// Returns ErrLimitTooSmall if limit < 2.
func SieveOfEratosthenes(limit uint64) ([]uint64, error) {
	if limit < 2 {
		return nil, fmt.Errorf("%w, got %d", ErrLimitTooSmall, limit)
	}

	composite := make([]bool, limit+1)
	composite[0] = true
	composite[1] = true

	for i := uint64(2); i*i <= limit; i++ {
		if !composite[i] {
			for j := i * i; j <= limit; j += i {
				composite[j] = true
			}
		}
	}

	primes := make([]uint64, 0, limit/8+8)
	for i := uint64(2); i <= limit; i++ {
		if !composite[i] {
			primes = append(primes, i)
		}
	}

	return primes, nil
}

// ---------------------------------------------------------------------------
// PrimesInRange
// ---------------------------------------------------------------------------

// PrimesInRange returns all prime numbers in the closed interval [start, end].
// Returns *ErrInvalidRange if start > end.
func PrimesInRange(start, end uint64) ([]uint64, error) {
	if start > end {
		return nil, &ErrInvalidRange{Start: start, End: end}
	}
	if end < 2 {
		return []uint64{}, nil
	}

	all, err := SieveOfEratosthenes(end)
	if err != nil {
		return nil, err
	}

	result := make([]uint64, 0, len(all))
	for _, p := range all {
		if p >= start {
			result = append(result, p)
		}
	}

	return result, nil
}

// ---------------------------------------------------------------------------
// NthPrime
// ---------------------------------------------------------------------------

// NthPrime returns the n-th prime number (1-indexed: NthPrime(1) == 2).
// Returns ErrInvalidNthIndex if n == 0.
func NthPrime(n uint64) (uint64, error) {
	if n == 0 {
		return 0, ErrInvalidNthIndex
	}

	var count uint64
	for candidate := uint64(2); ; candidate++ {
		if IsPrime(candidate) {
			count++
			if count == n {
				return candidate, nil
			}
		}
	}
}
