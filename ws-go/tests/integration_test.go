// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// integration_test.go — Integration tests for the primes package.
//
// These tests exercise the public API end-to-end, mirroring the
// integration tests in the Rust ws-rust workspace.

package primes_test

import (
	"errors"
	"testing"

	primes "github.com/RelicFrog/ops-devbox-examples/ws-go/src"
)

// ---------------------------------------------------------------------------
// Round-trip: NthPrime is consistent with SieveOfEratosthenes
// ---------------------------------------------------------------------------

func TestNthPrimeConsistentWithSieveFirst50(t *testing.T) {
	t.Parallel()

	sieve, err := primes.SieveOfEratosthenes(230) // 230 > 50th prime (229)
	if err != nil {
		t.Fatal(err)
	}

	for i, expected := range sieve {
		idx := uint64(i + 1)

		p, err := primes.NthPrime(idx)
		if err != nil {
			t.Fatalf("NthPrime(%d): unexpected error: %v", idx, err)
		}

		if p != expected {
			t.Errorf("NthPrime(%d) = %d, want %d", idx, p, expected)
		}
	}
}

// ---------------------------------------------------------------------------
// PrimesInRange covers full first 100 primes
// ---------------------------------------------------------------------------

func TestPrimesInRangeFirstHundredMatchesSieve(t *testing.T) {
	t.Parallel()

	sieve, err := primes.SieveOfEratosthenes(541) // 541 == 100th prime
	if err != nil {
		t.Fatal(err)
	}

	rang, err := primes.PrimesInRange(2, 541)
	if err != nil {
		t.Fatal(err)
	}

	if len(rang) != 100 {
		t.Fatalf("PrimesInRange(2,541): got %d primes, want 100", len(rang))
	}

	for i := range sieve {
		if sieve[i] != rang[i] {
			t.Errorf("index %d: sieve=%d range=%d", i, sieve[i], rang[i])
		}
	}
}

// ---------------------------------------------------------------------------
// IsPrime consistent with sieve for 0..200
// ---------------------------------------------------------------------------

func TestIsPrimeConsistentWithSieveUpTo200(t *testing.T) {
	t.Parallel()

	sieve, err := primes.SieveOfEratosthenes(200)
	if err != nil {
		t.Fatal(err)
	}

	sieveSet := make(map[uint64]bool, len(sieve))
	for _, p := range sieve {
		sieveSet[p] = true
	}

	for n := uint64(0); n <= 200; n++ {
		got := primes.IsPrime(n)
		want := sieveSet[n]

		if got != want {
			t.Errorf("IsPrime(%d) = %v, sieve says %v", n, got, want)
		}
	}
}

// ---------------------------------------------------------------------------
// Error propagation
// ---------------------------------------------------------------------------

func TestSieveLimitZeroPropagatesError(t *testing.T) {
	t.Parallel()

	_, err := primes.SieveOfEratosthenes(0)
	if !errors.Is(err, primes.ErrLimitTooSmall) {
		t.Errorf("expected ErrLimitTooSmall, got %v", err)
	}
}

func TestPrimesInRangeInvertedPropagatesError(t *testing.T) {
	t.Parallel()

	_, err := primes.PrimesInRange(50, 10)

	var rangeErr *primes.ErrInvalidRange
	if !errors.As(err, &rangeErr) {
		t.Errorf("expected *ErrInvalidRange, got %T: %v", err, err)
	}
}

func TestNthPrimeZeroPropagatesError(t *testing.T) {
	t.Parallel()

	_, err := primes.NthPrime(0)
	if !errors.Is(err, primes.ErrInvalidNthIndex) {
		t.Errorf("expected ErrInvalidNthIndex, got %v", err)
	}
}

// ---------------------------------------------------------------------------
// Known large primes / composites
// ---------------------------------------------------------------------------

func TestKnownLargePrimesAreDetected(t *testing.T) {
	t.Parallel()

	for _, p := range []uint64{7919, 104729, 999_983} {
		if !primes.IsPrime(p) {
			t.Errorf("IsPrime(%d) = false, want true", p)
		}
	}
}

func TestKnownLargeCompositesAreRejected(t *testing.T) {
	t.Parallel()

	for _, c := range []uint64{7920, 104728, 999_999} {
		if primes.IsPrime(c) {
			t.Errorf("IsPrime(%d) = true, want false", c)
		}
	}
}
