pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input_allocator = std.heap.ArenaAllocator.init(allocator);

    const lines = try util.readInputFileLines([][]u8, input_allocator.allocator(), "day06.txt", parseLine);
    defer input_allocator.deinit();
    const ops = lines[lines.len - 1];

    // Allocate memory to hold result of each problem
    const num_problems = lines[0].len;
    var results = try allocator.alloc(u64, num_problems);
    defer allocator.free(results);

    // Initialize result to 0 and then any multiplication problems to 1
    @memset(results, 0);
    for (0..num_problems) |i| {
        if (ops[i][0] == '*') {
            results[i] = 1;
        }
    }

    for (lines[0 .. lines.len - 1]) |line| {
        for (line, 0..) |num_str, i| {
            const num = try std.fmt.parseInt(u64, num_str, 10);

            if (ops[i][0] == '+') {
                results[i] += num;
            } else {
                std.debug.assert(ops[i][0] == '*');
                results[i] *= num;
            }
        }
    }

    var total: u64 = 0;
    for (results) |result| {
        print("{d}\n", .{result});
        total += result;
    }

    print("{d}", .{total});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![][]u8 {
    var iter = std.mem.tokenizeScalar(u8, line, ' ');
    var nums_or_ops: std.ArrayList([]u8) = .{};

    while (iter.next()) |token| {
        const num_or_op = try allocator.dupe(u8, token);
        try nums_or_ops.append(allocator, num_or_op);
    }
    return nums_or_ops.toOwnedSlice(allocator);
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
