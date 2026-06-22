// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// lib.rs — Library entry point for primes-cli.
//
// Re-exports the public API so that integration tests and external
// consumers can import from the crate root rather than from sub-modules.

pub mod primes;

pub use primes::{
    is_prime,
    nth_prime,
    primes_in_range,
    sieve_of_eratosthenes,
    PrimeError,
};
