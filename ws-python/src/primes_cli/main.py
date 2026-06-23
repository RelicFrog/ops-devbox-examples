# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
"""CLI entry point for primes-cli (Python implementation).

Subcommands (identical to ws-rust, ws-go, ws-node, ws-zig, ws-lua):
    check <N>                    — test whether N is prime (exit 0=prime, 1=not)
    list  --to <N>               — list all primes up to N (sieve)
    range --from <A> --to <B>    — list all primes in [A, B]
    nth   <N>                    — print the N-th prime (1-indexed)
"""

from __future__ import annotations

import argparse
import sys

from primes_cli.primes import (
    is_prime,
    nth_prime,
    primes_in_range,
    sieve_of_eratosthenes,
)

VERSION = "1.0.0"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _positive_int(value: str) -> int:
    """argparse type: non-negative integer."""
    try:
        n = int(value)
        if n < 0:
            raise ValueError
        return n
    except ValueError:
        msg = f"invalid non-negative integer: {value!r}"
        raise argparse.ArgumentTypeError(msg) from None


# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------


def _cmd_check(args: argparse.Namespace) -> None:
    n: int = args.n
    if is_prime(n):
        print(f"{n} is prime")
        sys.exit(0)
    else:
        print(f"{n} is not prime")
        sys.exit(1)


def _cmd_list(args: argparse.Namespace) -> None:
    try:
        result = sieve_of_eratosthenes(args.to)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
    _print_list(result)


def _cmd_range(args: argparse.Namespace) -> None:
    try:
        result = primes_in_range(args.frm, args.to)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
    _print_list(result)


def _cmd_nth(args: argparse.Namespace) -> None:
    try:
        p = nth_prime(args.n)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
    print(p)


def _print_list(primes: list[int]) -> None:
    if not primes:
        print("(no primes in range)")
        return
    for p in primes:
        print(p)


# ---------------------------------------------------------------------------
# Argument parser
# ---------------------------------------------------------------------------


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="primes-cli",
        description=f"primes-cli {VERSION} (Python) — prime number generator CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  primes-cli check 97\n"
            "  primes-cli list --to 50\n"
            "  primes-cli range --from 10 --to 50\n"
            "  primes-cli nth 100\n\n"
            "Copyright 2026 TEAM RelicFrog — Apache-2.0"
        ),
    )
    parser.add_argument("--version", action="version", version=f"primes-cli {VERSION} (Python)")

    sub = parser.add_subparsers(dest="command", metavar="<command>")
    sub.required = True

    # check
    p_check = sub.add_parser("check", help="test whether N is prime")
    p_check.add_argument("n", type=_positive_int, metavar="N")
    p_check.set_defaults(func=_cmd_check)

    # list
    p_list = sub.add_parser("list", help="list all primes up to N (inclusive)")
    p_list.add_argument("--to", type=_positive_int, required=True, metavar="N")
    p_list.set_defaults(func=_cmd_list)

    # range
    p_range = sub.add_parser("range", help="list primes in [A, B]")
    p_range.add_argument("--from", dest="frm", type=_positive_int, default=0, metavar="A")
    p_range.add_argument("--to", type=_positive_int, required=True, metavar="B")
    p_range.set_defaults(func=_cmd_range)

    # nth
    p_nth = sub.add_parser("nth", help="print the N-th prime (1-indexed)")
    p_nth.add_argument("n", type=_positive_int, metavar="N")
    p_nth.set_defaults(func=_cmd_nth)

    return parser


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main() -> None:
    """CLI entry point."""
    parser = _build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
