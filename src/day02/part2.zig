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
            const n_str = try std.fmt.bufPrint(buf, "{d}", .{n});

            var chars: u8 = 1;
            nextChars: while (chars <= n_str.len / 2) : (chars += 1) {
                if (n_str.len % chars != 0) {
                    continue;
                }

                const copies = n_str.len / chars - 1;
                var i: u8 = 0;
                while (i < copies) : (i += 1) {
                    if (!std.mem.eql(u8, n_str[0..chars], n_str[chars * (i + 1) .. chars * (i + 2)])) {
                        continue :nextChars;
                    }
                }

                // print("{d} {s}\n", .{ n, n_str[0..chars] });
                sum += n;
                break;
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
