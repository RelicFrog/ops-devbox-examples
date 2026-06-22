// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// tests/integration_test.rs — Integration tests for primes-cli.
//
// These tests exercise the public library API end-to-end, simulating
// the input paths a real CLI invocation would trigger.

use primes_cli::{is_prime, nth_prime, primes_in_range, sieve_of_eratosthenes, PrimeError};

// ---------------------------------------------------------------------------
// Round-trip: nth_prime is consistent with sieve_of_eratosthenes
// ---------------------------------------------------------------------------

#[test]
fn nth_prime_consistent_with_sieve_first_50() {
    let sieve = sieve_of_eratosthenes(230).unwrap(); // 230 > 50th prime (229)
    for (i, &expected) in sieve.iter().enumerate() {
        let idx = (i + 1) as u64;
        assert_eq!(
            nth_prime(idx).unwrap(),
            expected,
            "nth_prime({idx}) should be {expected}"
        );
    }
}

// ---------------------------------------------------------------------------
// primes_in_range covers full first 100 primes
// ---------------------------------------------------------------------------

#[test]
fn primes_in_range_first_hundred_matches_sieve() {
    let sieve = sieve_of_eratosthenes(541).unwrap(); // 541 == 100th prime
    let range = primes_in_range(2, 541).unwrap();
    assert_eq!(sieve, range);
    assert_eq!(range.len(), 100);
}

// ---------------------------------------------------------------------------
// is_prime is consistent with the sieve for all n in 0..=200
// ---------------------------------------------------------------------------

#[test]
fn is_prime_consistent_with_sieve_up_to_200() {
    let sieve_set: std::collections::HashSet<u64> =
        sieve_of_eratosthenes(200).unwrap().into_iter().collect();

    for n in 0u64..=200 {
        assert_eq!(
            is_prime(n),
            sieve_set.contains(&n),
            "is_prime({n}) disagrees with sieve"
        );
    }
}

// ---------------------------------------------------------------------------
// Error propagation
// ---------------------------------------------------------------------------

#[test]
fn sieve_limit_zero_propagates_error() {
    let err = sieve_of_eratosthenes(0).unwrap_err();
    assert!(matches!(err, PrimeError::LimitTooSmall(0)));
}

#[test]
fn primes_in_range_inverted_propagates_error() {
    let err = primes_in_range(50, 10).unwrap_err();
    assert!(matches!(err, PrimeError::InvalidRange { start: 50, end: 10 }));
}

#[test]
fn nth_prime_zero_propagates_error() {
    let err = nth_prime(0).unwrap_err();
    assert!(matches!(err, PrimeError::InvalidNthIndex(0)));
}

// ---------------------------------------------------------------------------
// Known large primes
// ---------------------------------------------------------------------------

#[test]
fn known_large_primes_are_detected() {
    let large_primes: &[u64] = &[7919, 104729, 999_983];
    for &p in large_primes {
        assert!(is_prime(p), "{p} should be prime");
    }
}

#[test]
fn known_large_composites_are_rejected() {
    let composites: &[u64] = &[7920, 104728, 999_999];
    for &c in composites {
        assert!(!is_prime(c), "{c} should not be prime");
    }
}
