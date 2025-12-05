pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const rows = try util.readInputFileLines([]bool, allocator, "day04.txt", parseLine);
    defer allocator.free(rows);
    defer {
        for (rows) |row| {
            allocator.free(row);
        }
    }

    var accessible_rolls: u32 = 0;
    for (rows, 0..) |row, roll_y| {
        for (row, 0..) |is_roll, roll_x| {
            if (!is_roll) {
                continue;
            }

            var occupied_neighbours: u8 = 0;
            for (direction_vectors) |v| {
                const x = @as(isize, @intCast(roll_x)) + v[0];
                const y = @as(isize, @intCast(roll_y)) + v[1];

                if (x < 0 or x >= row.len or y < 0 or y >= rows.len) {
                    continue;
                }

                const is_neighbour_roll = rows[@as(usize, @intCast(y))][@as(usize, @intCast(x))];
                if (is_neighbour_roll) {
                    occupied_neighbours += 1;
                }
            }

            if (occupied_neighbours < 4) {
                accessible_rolls += 1;
            }
        }
    }

    print("{d}", .{accessible_rolls});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]bool {
    const row = try allocator.alloc(bool, line.len);
    for (line, 0..) |char, i| {
        row[i] = if (char == '@') true else false;
    }
    return row;
}

const DirectionVector = [2]isize;

const direction_vectors = [_]DirectionVector{
    .{ 0, -1 }, // up
    .{ -1, -1 }, // up-left
    .{ 1, -1 }, // up-right
    .{ 1, 0 }, // right
    .{ 0, 1 }, // down
    .{ -1, 1 }, // down-left
    .{ 1, 1 }, // down-right
    .{ -1, 0 }, // left
};

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
