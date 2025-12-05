pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ranges_and_values = try util.readInputFileLines(RangeOrValue, allocator, "day05.txt", parseLine);
    defer allocator.free(ranges_and_values);

    var ranges: std.ArrayList(Range) = .{};
    defer ranges.deinit(allocator);
    var fresh_count: u32 = 0;

    for (ranges_and_values) |range_or_value| {
        switch (range_or_value) {
            .range => |range| {
                try ranges.append(allocator, range);
            },

            .value => |value| {
                for (ranges.items) |range| {
                    if (value >= range[0] and value <= range[1]) {
                        fresh_count += 1;
                        // print("{d} is fresh\n", .{value});
                        break;
                    }
                } else {
                    // print("{d} is spoiled\n", .{value});
                }
            },
        }
    }

    print("{d}", .{fresh_count});
}

fn parseLine(_: std.mem.Allocator, line: []const u8) !RangeOrValue {
    const dash_index = std.mem.indexOfScalar(u8, line, '-');

    if (dash_index) |index| {
        const start = try std.fmt.parseInt(u64, line[0..index], 10);
        const end = try std.fmt.parseInt(u64, line[index + 1 .. line.len], 10);
        return RangeOrValue{ .range = .{ start, end } };
    } else {
        const value = try std.fmt.parseInt(u64, line, 10);
        return RangeOrValue{ .value = value };
    }
}

const Range = [2]u64;
const RangeOrValueTag = enum { range, value };
const RangeOrValue = union(RangeOrValueTag) {
    range: Range,
    value: u64,
};

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
