const std = @import("std");

const MAX_DAY = 2;

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Add utilities module to the project
    const util_module = b.createModule(.{
        .root_source_file = b.path("src/util.zig"),
        .target = target,
        .optimize = optimize,
    });

    // For each day and each part, add an executable built from the corresponding source file
    inline for (1..MAX_DAY + 1) |day| {
        inline for (1..3) |part| {
            const day_str = try std.fmt.allocPrint(b.allocator, "day{d:0>2}", .{day});
            const part_str = try std.fmt.allocPrint(b.allocator, "part{d}", .{part});
            const exe_name = try std.fmt.allocPrint(b.allocator, "{s}_{s}", .{ day_str, part_str });

            const exe_module = b.createModule(.{
                .root_source_file = b.path(try std.fmt.allocPrint(b.allocator, "src/{s}/{s}.zig", .{ day_str, part_str })),
                .target = target,
                .optimize = optimize,
            });

            exe_module.addImport("util", util_module);

            const exe = b.addExecutable(.{
                .name = exe_name,
                .root_module = exe_module,
            });

            // b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());

            const run_step = b.step(exe_name, try std.fmt.allocPrint(b.allocator, "Run solution for day {d} part {d}", .{ day, part }));
            run_step.dependOn(&run_cmd.step);
        }
    }
}
