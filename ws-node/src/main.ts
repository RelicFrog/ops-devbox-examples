// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// main.ts — CLI entry point for primes-cli (Node.js / TypeScript).
//
// Subcommands (identical to ws-rust and ws-go):
//   check <N>                    — test whether N is prime (exit 0=prime, 1=not)
//   list  --to <N>               — list all primes up to N (sieve)
//   range --from <A> --to <B>    — list all primes in [A, B]
//   nth   <N>                    — print the N-th prime (1-indexed)

import process from "node:process";
import {
  InvalidNthIndexError,
  InvalidRangeError,
  isPrime,
  LimitTooSmallError,
  nthPrime,
  primesInRange,
  sieveOfEratosthenes,
} from "./primes.js";

const VERSION = "1.0.0";

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

function main(): void {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === "help" || args[0] === "--help" || args[0] === "-h") {
    printUsage();
    process.exit(0);
  }

  const [cmd, ...rest] = args as [string, ...string[]];

  try {
    switch (cmd) {
      case "check":
        runCheck(rest);
        break;
      case "list":
        runList(rest);
        break;
      case "range":
        runRange(rest);
        break;
      case "nth":
        runNth(rest);
        break;
      case "version":
      case "--version":
        console.log(`primes-cli ${VERSION} (Node.js)`);
        break;
      default:
        console.error(`error: unknown command "${cmd}"\n`);
        printUsage();
        process.exit(1);
    }
  } catch (err) {
    if (
      err instanceof LimitTooSmallError ||
      err instanceof InvalidRangeError ||
      err instanceof InvalidNthIndexError
    ) {
      console.error(`error: ${(err as Error).message}`);
      process.exit(1);
    }
    throw err;
  }
}

// ---------------------------------------------------------------------------
// Subcommand: check
// ---------------------------------------------------------------------------

function runCheck(args: string[]): void {
  if (args.length !== 1 || !args[0]) {
    console.error("Usage: primes-cli check <N>");
    process.exit(1);
  }

  const n = parseBigInt(args[0]);
  if (isPrime(n)) {
    console.log(`${n} is prime`);
    process.exit(0);
  } else {
    console.log(`${n} is not prime`);
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Subcommand: list
// ---------------------------------------------------------------------------

function runList(args: string[]): void {
  const flags = parseFlags(args);
  const toStr = flags.to;

  if (!toStr) {
    console.error("Usage: primes-cli list --to <N>");
    process.exit(1);
  }

  const primes = sieveOfEratosthenes(parseBigInt(toStr));
  printList(primes);
}

// ---------------------------------------------------------------------------
// Subcommand: range
// ---------------------------------------------------------------------------

function runRange(args: string[]): void {
  const flags = parseFlags(args);
  const fromStr = flags.from;
  const toStr = flags.to;

  if (!toStr) {
    console.error("Usage: primes-cli range --from <A> --to <B>");
    process.exit(1);
  }

  const from = fromStr ? parseBigInt(fromStr) : 0n;
  const primes = primesInRange(from, parseBigInt(toStr));
  printList(primes);
}

// ---------------------------------------------------------------------------
// Subcommand: nth
// ---------------------------------------------------------------------------

function runNth(args: string[]): void {
  if (args.length !== 1 || !args[0]) {
    console.error("Usage: primes-cli nth <N>");
    process.exit(1);
  }

  const p = nthPrime(parseBigInt(args[0]));
  console.log(String(p));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function parseBigInt(s: string): bigint {
  try {
    const n = BigInt(s);
    if (n < 0n) throw new Error("negative");
    return n;
  } catch {
    console.error(`error: invalid number "${s}"`);
    process.exit(1);
  }
}

function parseFlags(args: string[]): Record<string, string> {
  const flags: Record<string, string> = {};
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg?.startsWith("--")) {
      const key = arg.slice(2);
      const value = args[i + 1];
      if (value && !value.startsWith("--")) {
        flags[key] = value;
        i++;
      }
    }
  }
  return flags;
}

function printList(primes: bigint[]): void {
  if (primes.length === 0) {
    console.log("(no primes in range)");
    return;
  }
  for (const p of primes) {
    console.log(String(p));
  }
}

function printUsage(): void {
  console.error(`primes-cli ${VERSION} (Node.js) — prime number generator CLI

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

Copyright 2026 TEAM RelicFrog — Apache-2.0`);
}

main();
