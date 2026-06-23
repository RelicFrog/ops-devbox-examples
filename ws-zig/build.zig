// Copyright 2026 TEAM RelicFrog
// SPDX-License-Identifier: Apache-2.0
//
// build.zig — Zig build script for primes-cli.
//
// Note: on macOS with Nix, zig build requires SDKROOT to be set because
// the build runner itself links against macOS system libraries.
// Use 'make build' which sets the target explicitly via zig build-exe,
// or run inside a devbox shell where the env is configured correctly.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ---------------------------------------------------------------------------
    // Binary
    // ---------------------------------------------------------------------------
    const exe = b.addExecutable(.{
        .name = "primes-cli",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run primes-cli");
    run_step.dependOn(&run_cmd.step);

    // ---------------------------------------------------------------------------
    // Tests
    // ---------------------------------------------------------------------------
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/primes.zig"),
        .target = target,
        .optimize = optimize,
    });

    const integration_tests = b.addTest(.{
        .root_source_file = b.path("src/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);
    test_step.dependOn(&b.addRunArtifact(integration_tests).step);
}
