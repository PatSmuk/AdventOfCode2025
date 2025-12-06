pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines([]u8, input_allocator.allocator(), "dayXX.txt", parseLine);
    _ = lines; // autofix
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    return allocator.dupe(u8, line);
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
