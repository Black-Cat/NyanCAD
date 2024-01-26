const std = @import("std");
const builtin = @import("builtin");

const nyan_build = @import("nyancore/build.zig");

const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var nyanCAD = b.addExecutable(.{
        .name = "NyanCAD",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const vulkan_validation: bool = b.option(bool, "vulkan-validation", "Use vulkan validation layer, useful for vulkan development. Needs Vulkan SDK") orelse false;
    const enable_tracing: bool = b.option(bool, "enable-tracing", "Enable tracing with tracy v0.8") orelse false;
    const panic_on_all_errors: bool = b.option(bool, "panic-on-all-errors", "Panic on all errors") orelse false;

    nyanCAD.linkSystemLibrary("c");

    var nyancoreLib = nyan_build.addStaticLibrary(b, nyanCAD, "nyancore/", vulkan_validation, enable_tracing, panic_on_all_errors, true);

    nyanCAD.linkLibrary(nyancoreLib);
    nyanCAD.step.dependOn(&nyancoreLib.step);

    b.installArtifact(nyanCAD);

    const run_target = b.step("run", "Run NyanCAD");
    const run = b.addRunArtifact(nyanCAD);

    if (b.args) |args|
        run.addArgs(args);

    run.step.dependOn(b.getInstallStep());
    run_target.dependOn(&run.step);
}
