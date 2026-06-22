// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// main.rs — CLI entry point for primes-cli.
//
// Provides three sub-commands:
//   check <N>          — test whether N is a prime number
//   list  --to <N>     — list all primes up to N (sieve)
//   range --from <A> --to <B>
//                      — list all primes in the closed interval [A, B]
//   nth   <N>          — print the N-th prime (1-indexed)

use clap::{Parser, Subcommand};
use primes_cli::{is_prime, nth_prime, primes_in_range, sieve_of_eratosthenes};
use std::process;

// ---------------------------------------------------------------------------
// CLI definition
// ---------------------------------------------------------------------------

/// primes-cli — prime number generator.
///
/// A simple command-line tool for exploring prime numbers.
/// Part of the ops-devbox-examples workshop (ws-rust workspace).
///
/// Copyright 2026 TEAM RelicFrog — Apache-2.0
#[derive(Parser, Debug)]
#[command(
    name = "primes-cli",
    version,
    author = "Patrick Paechnatz <patrick@relicfrog.rocks>",
    about = "Prime number generator CLI — Devbox ws-rust workshop example",
    long_about = None,
)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand, Debug)]
enum Command {
    /// Check whether a single number is prime.
    ///
    /// Exits with code 0 if the number is prime, 1 otherwise.
    Check {
        /// The number to test for primality.
        n: u64,
    },

    /// List all prime numbers up to a given limit (inclusive).
    ///
    /// Uses the Sieve of Eratosthenes. The limit must be >= 2.
    List {
        /// Upper bound (inclusive).
        #[arg(long, short = 't')]
        to: u64,
    },

    /// List all prime numbers in a closed interval [from, to].
    Range {
        /// Lower bound (inclusive).
        #[arg(long, short = 'f')]
        from: u64,

        /// Upper bound (inclusive).
        #[arg(long, short = 't')]
        to: u64,
    },

    /// Print the N-th prime number (1-indexed, so nth 1 == 2).
    Nth {
        /// Position index (>= 1).
        n: u64,
    },
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

fn main() {
    let cli = Cli::parse();

    match run(cli.command) {
        Ok(()) => {}
        Err(e) => {
            eprintln!("error: {e}");
            process::exit(1);
        }
    }
}

fn run(command: Command) -> Result<(), Box<dyn std::error::Error>> {
    match command {
        Command::Check { n } => {
            if is_prime(n) {
                println!("{n} is prime");
                process::exit(0);
            } else {
                println!("{n} is not prime");
                process::exit(1);
            }
        }

        Command::List { to } => {
            let primes = sieve_of_eratosthenes(to)?;
            print_list(&primes);
        }

        Command::Range { from, to } => {
            let primes = primes_in_range(from, to)?;
            print_list(&primes);
        }

        Command::Nth { n } => {
            let p = nth_prime(n)?;
            println!("{p}");
        }
    }
    Ok(())
}

fn print_list(primes: &[u64]) {
    if primes.is_empty() {
        println!("(no primes in range)");
        return;
    }
    for p in primes {
        println!("{p}");
    }
}

// ---------------------------------------------------------------------------
// Integration-level smoke tests for the CLI logic (no subprocess required)
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn run_list_to_ten_yields_four_primes() {
        // sieve up to 10: 2, 3, 5, 7
        let primes = sieve_of_eratosthenes(10).unwrap();
        assert_eq!(primes.len(), 4);
    }

    #[test]
    fn run_range_returns_correct_subset() {
        let primes = primes_in_range(10, 30).unwrap();
        assert_eq!(primes, vec![11, 13, 17, 19, 23, 29]);
    }

    #[test]
    fn run_nth_1000th_prime() {
        let p = nth_prime(1000).unwrap();
        assert_eq!(p, 7919);
    }
}
