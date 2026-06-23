// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// main.zig — CLI entry point for primes-cli (Zig implementation).
//
// Subcommands (identical to ws-rust, ws-go, ws-node):
//   check <N>                    — test whether N is prime (exit 0=prime, 1=not)
//   list  --to <N>               — list all primes up to N (sieve)
//   range --from <A> --to <B>    — list all primes in [A, B]
//   nth   <N>                    — print the N-th prime (1-indexed)

const std = @import("std");
const primes = @import("primes.zig");

const VERSION = "1.0.0";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    if (args.len < 2) {
        try printUsage(stderr);
        std.process.exit(0);
    }

    const cmd = args[1];

    if (std.mem.eql(u8, cmd, "help") or
        std.mem.eql(u8, cmd, "--help") or
        std.mem.eql(u8, cmd, "-h"))
    {
        try printUsage(stdout);
        return;
    }

    if (std.mem.eql(u8, cmd, "version") or std.mem.eql(u8, cmd, "--version")) {
        try stdout.print("primes-cli {s} (Zig)\n", .{VERSION});
        return;
    }

    if (std.mem.eql(u8, cmd, "check")) {
        try runCheck(args[2..], stdout, stderr);
    } else if (std.mem.eql(u8, cmd, "list")) {
        try runList(allocator, args[2..], stdout, stderr);
    } else if (std.mem.eql(u8, cmd, "range")) {
        try runRange(allocator, args[2..], stdout, stderr);
    } else if (std.mem.eql(u8, cmd, "nth")) {
        try runNth(args[2..], stdout, stderr);
    } else {
        try stderr.print("error: unknown command \"{s}\"\n\n", .{cmd});
        try printUsage(stderr);
        std.process.exit(1);
    }
}

// ---------------------------------------------------------------------------
// Subcommand: check
// ---------------------------------------------------------------------------

fn runCheck(args: []const []const u8, stdout: anytype, stderr: anytype) !void {
    if (args.len != 1) {
        try stderr.print("Usage: primes-cli check <N>\n", .{});
        std.process.exit(1);
    }
    const n = parseU64(args[0]) catch {
        try stderr.print("error: invalid number \"{s}\"\n", .{args[0]});
        std.process.exit(1);
    };
    if (primes.isPrime(n)) {
        try stdout.print("{d} is prime\n", .{n});
        std.process.exit(0);
    } else {
        try stdout.print("{d} is not prime\n", .{n});
        std.process.exit(1);
    }
}

// ---------------------------------------------------------------------------
// Subcommand: list
// ---------------------------------------------------------------------------

fn runList(allocator: std.mem.Allocator, args: []const []const u8, stdout: anytype, stderr: anytype) !void {
    const to = parseFlag(args, "--to") orelse {
        try stderr.print("Usage: primes-cli list --to <N>\n", .{});
        std.process.exit(1);
    };

    const limit = parseU64(to) catch {
        try stderr.print("error: invalid number \"{s}\"\n", .{to});
        std.process.exit(1);
    };

    const result = primes.sieveOfEratosthenes(allocator, limit) catch |err| {
        try stderr.print("error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    defer allocator.free(result);

    try printList(result, stdout);
}

// ---------------------------------------------------------------------------
// Subcommand: range
// ---------------------------------------------------------------------------

fn runRange(allocator: std.mem.Allocator, args: []const []const u8, stdout: anytype, stderr: anytype) !void {
    const from_str = parseFlag(args, "--from") orelse "0";
    const to_str = parseFlag(args, "--to") orelse {
        try stderr.print("Usage: primes-cli range --from <A> --to <B>\n", .{});
        std.process.exit(1);
    };

    const from = parseU64(from_str) catch {
        try stderr.print("error: invalid number \"{s}\"\n", .{from_str});
        std.process.exit(1);
    };
    const to = parseU64(to_str) catch {
        try stderr.print("error: invalid number \"{s}\"\n", .{to_str});
        std.process.exit(1);
    };

    const result = primes.primesInRange(allocator, from, to) catch |err| {
        try stderr.print("error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    defer allocator.free(result);

    try printList(result, stdout);
}

// ---------------------------------------------------------------------------
// Subcommand: nth
// ---------------------------------------------------------------------------

fn runNth(args: []const []const u8, stdout: anytype, stderr: anytype) !void {
    if (args.len != 1) {
        try stderr.print("Usage: primes-cli nth <N>\n", .{});
        std.process.exit(1);
    }
    const n = parseU64(args[0]) catch {
        try stderr.print("error: invalid number \"{s}\"\n", .{args[0]});
        std.process.exit(1);
    };
    const p = primes.nthPrime(n) catch |err| {
        try stderr.print("error: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    try stdout.print("{d}\n", .{p});
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn parseU64(s: []const u8) !u64 {
    return std.fmt.parseInt(u64, s, 10);
}

fn parseFlag(args: []const []const u8, flag: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], flag) and i + 1 < args.len) {
            return args[i + 1];
        }
    }
    return null;
}

fn printList(ps: []const u64, writer: anytype) !void {
    if (ps.len == 0) {
        try writer.print("(no primes in range)\n", .{});
        return;
    }
    for (ps) |p| try writer.print("{d}\n", .{p});
}

fn printUsage(writer: anytype) !void {
    try writer.print(
        \\primes-cli {s} (Zig) — prime number generator CLI
        \\
        \\  Highlight: first {d} primes are precomputed at COMPILE TIME
        \\  via comptime Sieve of Eratosthenes and embedded in the binary.
        \\  nth/isPrime for n <= {d} are O(1) binary-search lookups.
        \\
        \\Usage:
        \\  primes-cli <command> [arguments]
        \\
        \\Commands:
        \\  check <N>              Test whether N is prime (exit 0=prime, 1=not)
        \\  list  --to <N>         List all primes up to N (inclusive)
        \\  range --from <A> --to <B>
        \\                         List primes in [A, B]
        \\  nth   <N>              Print the N-th prime (1-indexed)
        \\  version                Print version
        \\  help                   Show this help
        \\
        \\Examples:
        \\  primes-cli check 97
        \\  primes-cli list --to 50
        \\  primes-cli range --from 10 --to 50
        \\  primes-cli nth 100
        \\
        \\Copyright 2026 TEAM RelicFrog — Apache-2.0
        \\
    , .{ VERSION, primes.COMPTIME_LIMIT, primes.COMPTIME_LIMIT });
}
