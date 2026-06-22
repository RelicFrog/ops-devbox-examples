// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// primes.rs — Core prime number algorithms for primes-cli.
//
// Provides:
//   - `is_prime(n)` — deterministic primality test (trial division)
//   - `sieve_of_eratosthenes(limit)` — all primes up to `limit`
//   - `primes_in_range(start, end)` — primes in a closed interval
//   - `nth_prime(n)` — the n-th prime (1-indexed)

use thiserror::Error;

// ---------------------------------------------------------------------------
// Error type
// ---------------------------------------------------------------------------

#[derive(Debug, Error, PartialEq)]
pub enum PrimeError {
    #[error("limit must be >= 2, got {0}")]
    LimitTooSmall(u64),

    #[error("range start ({start}) must be <= end ({end})")]
    InvalidRange { start: u64, end: u64 },

    #[error("n must be >= 1, got {0}")]
    InvalidNthIndex(u64),
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns `true` if `n` is a prime number.
///
/// Uses trial division up to sqrt(n). Handles the edge cases
/// n < 2, n == 2, and even numbers explicitly for clarity.
pub fn is_prime(n: u64) -> bool {
    if n < 2 {
        return false;
    }
    if n == 2 {
        return true;
    }
    if n.is_multiple_of(2) {
        return false;
    }
    let mut i = 3u64;
    while i.saturating_mul(i) <= n {
        if n.is_multiple_of(i) {
            return false;
        }
        i += 2;
    }
    true
}

/// Returns all prime numbers up to and including `limit` using the
/// Sieve of Eratosthenes.
///
/// # Errors
/// Returns [`PrimeError::LimitTooSmall`] if `limit < 2`.
pub fn sieve_of_eratosthenes(limit: u64) -> Result<Vec<u64>, PrimeError> {
    if limit < 2 {
        return Err(PrimeError::LimitTooSmall(limit));
    }

    let size = (limit + 1) as usize;
    let mut composite = vec![false; size];
    composite[0] = true;
    composite[1] = true;

    let mut i = 2usize;
    while i.saturating_mul(i) <= limit as usize {
        if !composite[i] {
            let mut j = i * i;
            while j <= limit as usize {
                composite[j] = true;
                j += i;
            }
        }
        i += 1;
    }

    Ok((2..=limit).filter(|&n| !composite[n as usize]).collect())
}

/// Returns all prime numbers in the closed interval `[start, end]`.
///
/// # Errors
/// Returns [`PrimeError::InvalidRange`] if `start > end`.
pub fn primes_in_range(start: u64, end: u64) -> Result<Vec<u64>, PrimeError> {
    if start > end {
        return Err(PrimeError::InvalidRange { start, end });
    }
    if end < 2 {
        return Ok(vec![]);
    }
    let all = sieve_of_eratosthenes(end)?;
    Ok(all.into_iter().filter(|&p| p >= start).collect())
}

/// Returns the n-th prime number (1-indexed, so `nth_prime(1) == 2`).
///
/// # Errors
/// Returns [`PrimeError::InvalidNthIndex`] if `n == 0`.
pub fn nth_prime(n: u64) -> Result<u64, PrimeError> {
    if n == 0 {
        return Err(PrimeError::InvalidNthIndex(0));
    }
    let mut count = 0u64;
    let mut candidate = 2u64;
    loop {
        if is_prime(candidate) {
            count += 1;
            if count == n {
                return Ok(candidate);
            }
        }
        candidate += 1;
    }
}

// ---------------------------------------------------------------------------
// Unit tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    // --- is_prime -----------------------------------------------------------

    #[test]
    fn is_prime_below_two_is_false() {
        assert!(!is_prime(0));
        assert!(!is_prime(1));
    }

    #[test]
    fn is_prime_two_is_prime() {
        assert!(is_prime(2));
    }

    #[test]
    fn is_prime_three_is_prime() {
        assert!(is_prime(3));
    }

    #[test]
    fn is_prime_even_composites_are_not_prime() {
        assert!(!is_prime(4));
        assert!(!is_prime(100));
        assert!(!is_prime(1_000_000));
    }

    #[test]
    fn is_prime_known_primes() {
        let known: &[u64] = &[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97];
        for &p in known {
            assert!(is_prime(p), "{p} should be prime");
        }
    }

    #[test]
    fn is_prime_known_composites() {
        let known: &[u64] = &[4, 6, 8, 9, 15, 25, 49, 91, 100];
        for &c in known {
            assert!(!is_prime(c), "{c} should not be prime");
        }
    }

    #[test]
    fn is_prime_large_prime() {
        assert!(is_prime(999_983));
    }

    #[test]
    fn is_prime_large_composite() {
        assert!(!is_prime(999_999)); // 3 × 333333
    }

    // --- sieve_of_eratosthenes ----------------------------------------------

    #[test]
    fn sieve_limit_one_returns_error() {
        assert_eq!(sieve_of_eratosthenes(1), Err(PrimeError::LimitTooSmall(1)));
    }

    #[test]
    fn sieve_limit_zero_returns_error() {
        assert_eq!(sieve_of_eratosthenes(0), Err(PrimeError::LimitTooSmall(0)));
    }

    #[test]
    fn sieve_limit_two_returns_two() {
        assert_eq!(sieve_of_eratosthenes(2).unwrap(), vec![2]);
    }

    #[test]
    fn sieve_limit_ten() {
        assert_eq!(sieve_of_eratosthenes(10).unwrap(), vec![2, 3, 5, 7]);
    }

    #[test]
    fn sieve_limit_thirty() {
        assert_eq!(
            sieve_of_eratosthenes(30).unwrap(),
            vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
        );
    }

    #[test]
    fn sieve_count_primes_below_100() {
        // There are 25 primes below 100.
        assert_eq!(sieve_of_eratosthenes(99).unwrap().len(), 24);
    }

    #[test]
    fn sieve_count_primes_up_to_100() {
        assert_eq!(sieve_of_eratosthenes(100).unwrap().len(), 25);
    }

    // --- primes_in_range ----------------------------------------------------

    #[test]
    fn primes_in_range_invalid_range() {
        assert_eq!(
            primes_in_range(10, 5),
            Err(PrimeError::InvalidRange { start: 10, end: 5 })
        );
    }

    #[test]
    fn primes_in_range_below_two() {
        assert_eq!(primes_in_range(0, 1).unwrap(), vec![]);
    }

    #[test]
    fn primes_in_range_single_prime() {
        assert_eq!(primes_in_range(7, 7).unwrap(), vec![7]);
    }

    #[test]
    fn primes_in_range_ten_to_twenty() {
        assert_eq!(primes_in_range(10, 20).unwrap(), vec![11, 13, 17, 19]);
    }

    #[test]
    fn primes_in_range_start_equals_end_composite() {
        assert_eq!(primes_in_range(9, 9).unwrap(), vec![]);
    }

    // --- nth_prime ----------------------------------------------------------

    #[test]
    fn nth_prime_zero_returns_error() {
        assert_eq!(nth_prime(0), Err(PrimeError::InvalidNthIndex(0)));
    }

    #[test]
    fn nth_prime_first_is_two() {
        assert_eq!(nth_prime(1).unwrap(), 2);
    }

    #[test]
    fn nth_prime_second_is_three() {
        assert_eq!(nth_prime(2).unwrap(), 3);
    }

    #[test]
    fn nth_prime_tenth_is_twenty_nine() {
        assert_eq!(nth_prime(10).unwrap(), 29);
    }

    #[test]
    fn nth_prime_hundredth_is_541() {
        assert_eq!(nth_prime(100).unwrap(), 541);
    }

    #[test]
    fn nth_prime_sequence_matches_sieve() {
        let sieve = sieve_of_eratosthenes(30).unwrap();
        for (i, &expected) in sieve.iter().enumerate() {
            assert_eq!(nth_prime((i + 1) as u64).unwrap(), expected);
        }
    }
}
