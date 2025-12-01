const std = @import("std");
const util = @import("util");

const print = std.debug.print;

pub const std_options: std.Options = .{
    .log_level = .info,
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lines = try util.readInputFileLines([]u8, allocator, "day01.txt", parseLine);
    _ = lines; // autofix
    // defer allocator.free(lines);
    // defer {
    //     for (lines) |line| {
    //         allocator.free(line);
    //     }
    // }
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    return allocator.dupe(u8, line);
}
