pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();

    const lines = try util.readInputFileLines([]u8, input_allocator.allocator(), "day06.txt", parseLine);

    const problems = try computeProblems(allocator, lines[lines.len - 1]);
    defer allocator.free(problems);

    // Allocate memory to hold result of each problem
    const results = try allocator.alloc(u64, problems.len);
    defer allocator.free(results);

    const num_buf = try allocator.alloc(u8, lines.len);
    defer allocator.free(num_buf);

    for (problems, 0..) |problem, i| {
        // Initialize result based on operation
        results[i] = if (problem.op == .multiply) 1 else 0;

        // For each column the problem occupies...
        for (problem.first_index..problem.last_index + 1) |col| {
            // Construct a number using the column
            @memset(num_buf, 0);
            var buf_i: usize = 0;
            for (0..lines.len - 1) |row| {
                const char = lines[row][col];
                if (char == ' ') {
                    continue;
                }
                num_buf[buf_i] = char;
                buf_i += 1;
            }
            const num = try std.fmt.parseInt(u64, num_buf[0..buf_i], 10);
            // print("{d}\n", .{num});

            if (problem.op == .add) {
                results[i] += num;
            } else {
                results[i] *= num;
            }
        }
    }

    var total: u64 = 0;
    for (results) |result| {
        // print("{d}\n", .{result});
        total += result;
    }

    print("{d}", .{total});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    return allocator.dupe(u8, line);
}

const Op = enum { add, multiply };
const Problem = struct {
    op: Op,
    first_index: usize,
    last_index: usize,
};

fn computeProblems(allocator: std.mem.Allocator, line: []const u8) ![]Problem {
    var problems: std.ArrayList(Problem) = .{};

    var first_index: usize = 0;

    while (first_index < line.len) {
        std.debug.assert(line[first_index] != ' ');
        const op: Op = if (line[first_index] == '+') .add else .multiply;

        var last_index = first_index + 1;
        while (last_index < line.len and line[last_index] == ' ') : (last_index += 1) {}
        last_index -= if (last_index == line.len) 1 else 2; // account for extra space between problems

        try problems.append(allocator, .{ .op = op, .first_index = first_index, .last_index = last_index });

        first_index = last_index + 2; // same here
    }

    return problems.toOwnedSlice(allocator);
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
