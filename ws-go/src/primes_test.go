// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes_test.go — Unit tests for the primes package.

package primes

import (
	"errors"
	"testing"
)

// ---------------------------------------------------------------------------
// IsPrime
// ---------------------------------------------------------------------------

func TestIsPrime_BelowTwoIsFalse(t *testing.T) {
	t.Parallel()

	for _, n := range []uint64{0, 1} {
		if IsPrime(n) {
			t.Errorf("IsPrime(%d) = true, want false", n)
		}
	}
}

func TestIsPrime_TwoIsPrime(t *testing.T) {
	t.Parallel()

	if !IsPrime(2) {
		t.Error("IsPrime(2) = false, want true")
	}
}

func TestIsPrime_ThreeIsPrime(t *testing.T) {
	t.Parallel()

	if !IsPrime(3) {
		t.Error("IsPrime(3) = false, want true")
	}
}

func TestIsPrime_EvenCompositesAreNotPrime(t *testing.T) {
	t.Parallel()

	for _, n := range []uint64{4, 100, 1_000_000} {
		if IsPrime(n) {
			t.Errorf("IsPrime(%d) = true, want false", n)
		}
	}
}

func TestIsPrime_KnownPrimes(t *testing.T) {
	t.Parallel()

	known := []uint64{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97}
	for _, p := range known {
		if !IsPrime(p) {
			t.Errorf("IsPrime(%d) = false, want true", p)
		}
	}
}

func TestIsPrime_KnownComposites(t *testing.T) {
	t.Parallel()

	known := []uint64{4, 6, 8, 9, 15, 25, 49, 91, 100}
	for _, c := range known {
		if IsPrime(c) {
			t.Errorf("IsPrime(%d) = true, want false", c)
		}
	}
}

func TestIsPrime_LargePrime(t *testing.T) {
	t.Parallel()

	if !IsPrime(999_983) {
		t.Error("IsPrime(999983) = false, want true")
	}
}

func TestIsPrime_LargeComposite(t *testing.T) {
	t.Parallel()

	if IsPrime(999_999) { // 3 × 333333
		t.Error("IsPrime(999999) = true, want false")
	}
}

// ---------------------------------------------------------------------------
// SieveOfEratosthenes
// ---------------------------------------------------------------------------

func TestSieve_LimitBelowTwoReturnsError(t *testing.T) {
	t.Parallel()

	for _, limit := range []uint64{0, 1} {
		_, err := SieveOfEratosthenes(limit)
		if err == nil {
			t.Errorf("SieveOfEratosthenes(%d): expected error, got nil", limit)
		}

		if !errors.Is(err, ErrLimitTooSmall) {
			t.Errorf("SieveOfEratosthenes(%d): expected ErrLimitTooSmall, got %v", limit, err)
		}
	}
}

func TestSieve_LimitTwoReturnsTwo(t *testing.T) {
	t.Parallel()

	got, err := SieveOfEratosthenes(2)
	if err != nil {
		t.Fatal(err)
	}

	want := []uint64{2}
	assertSliceEqual(t, got, want)
}

func TestSieve_LimitTen(t *testing.T) {
	t.Parallel()

	got, err := SieveOfEratosthenes(10)
	if err != nil {
		t.Fatal(err)
	}

	assertSliceEqual(t, got, []uint64{2, 3, 5, 7})
}

func TestSieve_LimitThirty(t *testing.T) {
	t.Parallel()

	got, err := SieveOfEratosthenes(30)
	if err != nil {
		t.Fatal(err)
	}

	assertSliceEqual(t, got, []uint64{2, 3, 5, 7, 11, 13, 17, 19, 23, 29})
}

func TestSieve_CountPrimesBelowHundred(t *testing.T) {
	t.Parallel()

	// There are 25 primes <= 99 (i.e. below 100): 2..97.
	got, err := SieveOfEratosthenes(99)
	if err != nil {
		t.Fatal(err)
	}

	if len(got) != 25 {
		t.Errorf("SieveOfEratosthenes(99): got %d primes, want 25", len(got))
	}
}

func TestSieve_CountPrimesUpToHundred(t *testing.T) {
	t.Parallel()

	got, err := SieveOfEratosthenes(100)
	if err != nil {
		t.Fatal(err)
	}

	if len(got) != 25 {
		t.Errorf("SieveOfEratosthenes(100): got %d primes, want 25", len(got))
	}
}

// ---------------------------------------------------------------------------
// PrimesInRange
// ---------------------------------------------------------------------------

func TestPrimesInRange_InvalidRangeReturnsError(t *testing.T) {
	t.Parallel()

	_, err := PrimesInRange(10, 5)
	if err == nil {
		t.Fatal("PrimesInRange(10, 5): expected error, got nil")
	}

	var rangeErr *ErrInvalidRange
	if !errors.As(err, &rangeErr) {
		t.Errorf("expected *ErrInvalidRange, got %T", err)
	}
}

func TestPrimesInRange_BelowTwo(t *testing.T) {
	t.Parallel()

	got, err := PrimesInRange(0, 1)
	if err != nil {
		t.Fatal(err)
	}

	if len(got) != 0 {
		t.Errorf("PrimesInRange(0,1): got %v, want []", got)
	}
}

func TestPrimesInRange_SinglePrime(t *testing.T) {
	t.Parallel()

	got, err := PrimesInRange(7, 7)
	if err != nil {
		t.Fatal(err)
	}

	assertSliceEqual(t, got, []uint64{7})
}

func TestPrimesInRange_TenToTwenty(t *testing.T) {
	t.Parallel()

	got, err := PrimesInRange(10, 20)
	if err != nil {
		t.Fatal(err)
	}

	assertSliceEqual(t, got, []uint64{11, 13, 17, 19})
}

func TestPrimesInRange_StartEqualsEndComposite(t *testing.T) {
	t.Parallel()

	got, err := PrimesInRange(9, 9)
	if err != nil {
		t.Fatal(err)
	}

	if len(got) != 0 {
		t.Errorf("PrimesInRange(9,9): got %v, want []", got)
	}
}

// ---------------------------------------------------------------------------
// NthPrime
// ---------------------------------------------------------------------------

func TestNthPrime_ZeroReturnsError(t *testing.T) {
	t.Parallel()

	_, err := NthPrime(0)
	if !errors.Is(err, ErrInvalidNthIndex) {
		t.Errorf("NthPrime(0): expected ErrInvalidNthIndex, got %v", err)
	}
}

func TestNthPrime_FirstIsTwo(t *testing.T) {
	t.Parallel()

	p, err := NthPrime(1)
	if err != nil {
		t.Fatal(err)
	}

	if p != 2 {
		t.Errorf("NthPrime(1) = %d, want 2", p)
	}
}

func TestNthPrime_SecondIsThree(t *testing.T) {
	t.Parallel()

	p, err := NthPrime(2)
	if err != nil {
		t.Fatal(err)
	}

	if p != 3 {
		t.Errorf("NthPrime(2) = %d, want 3", p)
	}
}

func TestNthPrime_TenthIsTwentyNine(t *testing.T) {
	t.Parallel()

	p, err := NthPrime(10)
	if err != nil {
		t.Fatal(err)
	}

	if p != 29 {
		t.Errorf("NthPrime(10) = %d, want 29", p)
	}
}

func TestNthPrime_HundredthIs541(t *testing.T) {
	t.Parallel()

	p, err := NthPrime(100)
	if err != nil {
		t.Fatal(err)
	}

	if p != 541 {
		t.Errorf("NthPrime(100) = %d, want 541", p)
	}
}

func TestNthPrime_SequenceMatchesSieve(t *testing.T) {
	t.Parallel()

	sieve, err := SieveOfEratosthenes(30)
	if err != nil {
		t.Fatal(err)
	}

	for i, expected := range sieve {
		p, err := NthPrime(uint64(i + 1))
		if err != nil {
			t.Fatalf("NthPrime(%d): unexpected error: %v", i+1, err)
		}

		if p != expected {
			t.Errorf("NthPrime(%d) = %d, want %d", i+1, p, expected)
		}
	}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func assertSliceEqual(t *testing.T, got, want []uint64) {
	t.Helper()

	if len(got) != len(want) {
		t.Fatalf("len(got)=%d, len(want)=%d\n  got:  %v\n  want: %v", len(got), len(want), got, want)
	}

	for i := range got {
		if got[i] != want[i] {
			t.Errorf("index %d: got %d, want %d", i, got[i], want[i])
		}
	}
}
