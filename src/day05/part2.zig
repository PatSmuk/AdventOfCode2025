pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ranges_and_values = try util.readInputFileLines(RangeOrValue, allocator, "day05.txt", parseLine);
    defer allocator.free(ranges_and_values);

    var non_overlapping_ranges: std.ArrayList(?Range) = .{};
    defer non_overlapping_ranges.deinit(allocator);

    for (ranges_and_values) |range_or_value| {
        switch (range_or_value) {
            .range => |original_range| {
                var updated_range: ?Range = original_range;

                for (non_overlapping_ranges.items, 0..) |maybe_range, i| {
                    if (maybe_range) |clipping_range| {
                        const result = clipRange(updated_range, clipping_range);
                        updated_range = result[0];

                        // If we cover the clip range, make it null so it doesn't count twice in the final count
                        if (result[1] == null) {
                            non_overlapping_ranges.items[i] = null;
                        }
                    }

                    // Range falls entirely within another range already in the list
                    if (updated_range == null) {
                        break;
                    }
                }

                // If there's still anything left after clipping, add it to the list
                if (updated_range) |updated| {
                    try non_overlapping_ranges.append(allocator, updated);
                }
            },

            // Ignore the values
            .value => {},
        }
    }

    // Sum up all the fresh items of the ranges
    var fresh_count: u64 = 0;
    for (non_overlapping_ranges.items) |maybe_range| {
        if (maybe_range) |range| {
            fresh_count += range[1] - range[0] + 1;
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

fn clipRange(range: ?Range, clipping_range: Range) [2]?Range {
    var clipped_range = range orelse return .{ null, clipping_range };

    // Check whether it is entirely inside the clipping range
    if (clipped_range[0] >= clipping_range[0] and clipped_range[1] <= clipping_range[1]) {
        return .{ null, clipping_range };
    }
    // And vice-versa
    if (clipping_range[0] >= clipped_range[0] and clipping_range[1] <= clipped_range[1]) {
        return .{ clipped_range, null };
    }

    // Clip top end of range if it is within clip range
    if (clipped_range[0] < clipping_range[0] and clipped_range[1] >= clipping_range[0] and clipped_range[1] <= clipping_range[1]) {
        clipped_range[1] = clipping_range[0] - 1;
    }
    // Clip bottom end of range if it is within clip range
    if (clipped_range[1] > clipping_range[1] and clipped_range[0] >= clipping_range[0] and clipped_range[0] <= clipping_range[1]) {
        clipped_range[0] = clipping_range[1] + 1;
    }

    return .{ clipped_range, clipping_range };
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
