const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep = b.dependency("raylib_zig", .{});

    const raylib_module = dep.module("raylib");
    const raygui_module = dep.module("raygui");
    const raylib_artifact = dep.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "patience",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            }),
    });
    exe.root_module.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib_module);
    exe.root_module.addImport("raygui", raygui_module);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());
}
