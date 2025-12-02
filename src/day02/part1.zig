pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ranges = try util.readInputFileLines([]Range, allocator, "day02.txt", parseLine);
    defer allocator.free(ranges);
    defer allocator.free(ranges[0]);

    const buf = try allocator.alloc(u8, 256);
    defer allocator.free(buf);

    var sum: u64 = 0;

    for (ranges[0]) |range| {
        var n = range.start;

        while (n <= range.end) : (n += 1) {
            const n_log = std.math.log10(n);
            if (n_log % 2 == 0) {
                continue;
            }

            const n_str = try std.fmt.bufPrint(buf, "{d}", .{n});
            if (n_str.len % 2 != 0) {
                continue;
            }

            if (std.mem.eql(u8, n_str[0 .. n_str.len / 2], n_str[n_str.len / 2 .. n_str.len])) {
                // print("{s}\n", .{n_str});
                sum += n;
            }
        }
    }

    print("{d}\n", .{sum});
}

const Range = struct {
    start: u64,
    end: u64,
};

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]Range {
    var ranges: std.ArrayList(Range) = .{};
    var ranges_iterator = std.mem.splitScalar(u8, line, ',');

    while (ranges_iterator.next()) |rangeStr| {
        const dash_index = std.mem.indexOfScalar(u8, rangeStr, '-') orelse return error.NoDash;
        const start = try std.fmt.parseInt(u64, rangeStr[0..dash_index], 10);
        const end = try std.fmt.parseInt(u64, rangeStr[dash_index + 1 .. rangeStr.len], 10);
        try ranges.append(allocator, .{ .start = start, .end = end });
    }

    return ranges.toOwnedSlice(allocator);
}

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
