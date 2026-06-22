// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// cmd/main.go — Binary entry point for primes-cli (Go implementation).
//
// Subcommands (identical to the Rust primes-cli):
//   check <N>                    — test whether N is prime (exit 0=prime, 1=not)
//   list  --to <N>               — list all primes up to N (sieve)
//   range --from <A> --to <B>    — list all primes in [A, B]
//   nth   <N>                    — print the N-th prime (1-indexed)

package main

import (
	"flag"
	"fmt"
	"os"
	"strconv"

	"github.com/RelicFrog/ops-devbox-examples/ws-go/src"
)

const version = "1.0.0"

func main() {
	flag.Usage = usage
	flag.Parse()

	if flag.NArg() == 0 {
		usage()
		os.Exit(0)
	}

	cmd := flag.Arg(0)
	args := flag.Args()[1:]

	var err error

	switch cmd {
	case "check":
		err = runCheck(args)
	case "list":
		err = runList(args)
	case "range":
		err = runRange(args)
	case "nth":
		err = runNth(args)
	case "version", "--version", "-version":
		fmt.Printf("primes-cli %s (Go)\n", version)
	case "help", "--help", "-help", "-h":
		usage()
	default:
		fmt.Fprintf(os.Stderr, "error: unknown command %q\n\n", cmd)
		usage()
		os.Exit(1)
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %s\n", err)
		os.Exit(1)
	}
}

// ---------------------------------------------------------------------------
// Subcommand: check
// ---------------------------------------------------------------------------

func runCheck(args []string) error {
	fs := flag.NewFlagSet("check", flag.ContinueOnError)
	fs.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: primes-cli check <N>\n")
		fmt.Fprintf(os.Stderr, "  Test whether N is a prime number.\n")
		fmt.Fprintf(os.Stderr, "  Exits 0 if prime, 1 otherwise.\n")
	}

	if err := fs.Parse(args); err != nil {
		return err
	}

	if fs.NArg() != 1 {
		fs.Usage()
		return fmt.Errorf("check requires exactly one argument")
	}

	n, err := parseUint64(fs.Arg(0))
	if err != nil {
		return err
	}

	if primes.IsPrime(n) {
		fmt.Printf("%d is prime\n", n)
		os.Exit(0)
	} else {
		fmt.Printf("%d is not prime\n", n)
		os.Exit(1)
	}

	return nil
}

// ---------------------------------------------------------------------------
// Subcommand: list
// ---------------------------------------------------------------------------

func runList(args []string) error {
	fs := flag.NewFlagSet("list", flag.ContinueOnError)

	var to uint64

	fs.Func("to", "upper bound (inclusive, >= 2)", func(s string) error {
		v, err := parseUint64(s)
		if err != nil {
			return err
		}

		to = v

		return nil
	})
	fs.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: primes-cli list --to <N>\n")
		fmt.Fprintf(os.Stderr, "  List all primes up to N (inclusive).\n")
	}

	if err := fs.Parse(args); err != nil {
		return err
	}

	if to == 0 {
		return fmt.Errorf("--to is required")
	}

	result, err := primes.SieveOfEratosthenes(to)
	if err != nil {
		return err
	}

	printList(result)

	return nil
}

// ---------------------------------------------------------------------------
// Subcommand: range
// ---------------------------------------------------------------------------

func runRange(args []string) error {
	fs := flag.NewFlagSet("range", flag.ContinueOnError)

	var from, to uint64

	fs.Func("from", "lower bound (inclusive)", func(s string) error {
		v, err := parseUint64(s)
		if err != nil {
			return err
		}

		from = v

		return nil
	})
	fs.Func("to", "upper bound (inclusive)", func(s string) error {
		v, err := parseUint64(s)
		if err != nil {
			return err
		}

		to = v

		return nil
	})
	fs.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: primes-cli range --from <A> --to <B>\n")
		fmt.Fprintf(os.Stderr, "  List all primes in the closed interval [A, B].\n")
	}

	if err := fs.Parse(args); err != nil {
		return err
	}

	if to == 0 {
		return fmt.Errorf("--to is required")
	}

	result, err := primes.PrimesInRange(from, to)
	if err != nil {
		return err
	}

	printList(result)

	return nil
}

// ---------------------------------------------------------------------------
// Subcommand: nth
// ---------------------------------------------------------------------------

func runNth(args []string) error {
	fs := flag.NewFlagSet("nth", flag.ContinueOnError)
	fs.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: primes-cli nth <N>\n")
		fmt.Fprintf(os.Stderr, "  Print the N-th prime (1-indexed: nth 1 == 2).\n")
	}

	if err := fs.Parse(args); err != nil {
		return err
	}

	if fs.NArg() != 1 {
		fs.Usage()
		return fmt.Errorf("nth requires exactly one argument")
	}

	n, err := parseUint64(fs.Arg(0))
	if err != nil {
		return err
	}

	p, err := primes.NthPrime(n)
	if err != nil {
		return err
	}

	fmt.Println(p)

	return nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func parseUint64(s string) (uint64, error) {
	v, err := strconv.ParseUint(s, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("invalid number %q: %w", s, err)
	}

	return v, nil
}

func printList(ps []uint64) {
	if len(ps) == 0 {
		fmt.Println("(no primes in range)")
		return
	}

	for _, p := range ps {
		fmt.Println(p)
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, `primes-cli %s (Go) — prime number generator CLI

Usage:
  primes-cli <command> [arguments]

Commands:
  check <N>              Test whether N is prime (exit 0=prime, 1=not prime)
  list  --to <N>         List all primes up to N (inclusive)
  range --from <A> --to <B>
                         List all primes in the closed interval [A, B]
  nth   <N>              Print the N-th prime (1-indexed, nth 1 == 2)
  version                Print version information
  help                   Show this help message

Examples:
  primes-cli check 97
  primes-cli list --to 50
  primes-cli range --from 10 --to 50
  primes-cli nth 100

Copyright 2026 TEAM RelicFrog — Apache-2.0
`, version)
}
