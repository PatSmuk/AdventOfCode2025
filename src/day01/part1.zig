pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lines = try util.readInputFileLines(Movement, allocator, "day01.txt", parseLine);
    defer allocator.free(lines);

    var dial: i16 = 50;
    var zeroes: i16 = 0;

    for (lines) |line| {
        if (line.direction == .right) {
            dial += line.steps;
        } else {
            dial -= line.steps;
        }

        dial = @mod(dial, 100);
        // print("{any} {d}\n", .{ line, dial });

        if (dial == 0) {
            zeroes += 1;
        }
    }

    print("{d}", .{zeroes});
}

const LeftOrRight = enum { left, right };

const Movement = struct {
    direction: LeftOrRight,
    steps: i16,
};

fn parseLine(_: std.mem.Allocator, line: []const u8) !Movement {
    const direction: LeftOrRight = if (line[0] == 'L') .left else .right;
    const steps = try std.fmt.parseInt(i16, line[1..line.len], 10);
    return .{ .direction = direction, .steps = steps };
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
