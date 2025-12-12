pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines(Coord, input_allocator.allocator(), "day09.txt", parseLine);

    var largest_area: u64 = 0;

    for (0..lines.len - 1) |i| {
        for (i + 1..lines.len) |j| {
            const a = lines[i];
            const b = lines[j];
            const width = @abs(@as(i32, @intCast(a.x)) - @as(i32, @intCast(b.x))) + 1;
            const height = @abs(@as(i32, @intCast(a.y)) - @as(i32, @intCast(b.y))) + 1;

            const area: u64 = @as(u64, width) * @as(u64, height);
            if (area > largest_area) {
                largest_area = area;
            }
        }
    }

    print("{d}", .{largest_area});
}

fn parseLine(_: std.mem.Allocator, line: []const u8) !Coord {
    const comma_index = std.mem.indexOfScalar(u8, line, ',') orelse return error.CommaNotFound;
    const x = try std.fmt.parseInt(u32, line[0..comma_index], 10);
    const y = try std.fmt.parseInt(u32, line[comma_index + 1 .. line.len], 10);
    return .{ .x = x, .y = y };
}

const Coord = struct { x: u32, y: u32 };

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
