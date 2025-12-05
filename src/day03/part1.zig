pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lines = try util.readInputFileLines([]u8, allocator, "day03.txt", parseLine);
    defer allocator.free(lines);
    defer {
        for (lines) |line| {
            allocator.free(line);
        }
    }

    var sum: u32 = 0;

    for (lines) |line| {
        var max_joltage: u32 = 0;

        var i: usize = 0;
        while (i < line.len - 1) : (i += 1) {
            var j: usize = i + 1;
            while (j < line.len) : (j += 1) {
                if (line[i] * 10 + line[j] > max_joltage) {
                    max_joltage = line[i] * 10 + line[j];
                }
            }
        }

        // print("{any}: {d}\n", .{ line, max_joltage });
        sum += max_joltage;
    }

    print("{d}", .{sum});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    const nums = try allocator.dupe(u8, line);
    for (nums, 0..) |_, i| {
        nums[i] -= '0';
    }
    return nums;
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
