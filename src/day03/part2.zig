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

    var sum: u64 = 0;

    for (lines) |line| {
        var digits = [_]u8{0} ** 12;
        var digit_i: usize = 0;
        var next_min_i: usize = 0;

        // For each digit we need to acquire...
        while (digit_i < 12) : (digit_i += 1) {
            var i = next_min_i;
            var max_digit: u8 = 0;
            var max_digit_i: usize = 0;

            // Check up to the last possible index for the largest digit
            const max_possible_i = line.len - 12 + digit_i;
            while (i <= max_possible_i) : (i += 1) {
                if (line[i] > max_digit) {
                    max_digit = line[i];
                    max_digit_i = i;
                }
            }

            // Convert digit to ASCII again
            digits[digit_i] = max_digit + '0';
            next_min_i = max_digit_i + 1;
        }

        const max_joltage = try std.fmt.parseInt(u64, &digits, 10);
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
