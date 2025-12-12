pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines(Coord, input_allocator.allocator(), "day09.txt", parseLine);

    // Compress space preserving gaps between coordinates by sorting all distinct X and Y coordinates
    var big_to_small_x = std.AutoArrayHashMap(u32, u32).init(allocator);
    var big_to_small_y = std.AutoArrayHashMap(u32, u32).init(allocator);
    defer big_to_small_x.deinit();
    defer big_to_small_y.deinit();
    var max_x: usize = 0;
    var max_y: usize = 0;
    {
        // Find all distinct X and Y coords
        var distinct_x: std.ArrayList(u32) = .{};
        var distinct_y: std.ArrayList(u32) = .{};
        defer distinct_x.deinit(allocator);
        defer distinct_y.deinit(allocator);

        for (lines) |coord| {
            if (std.mem.indexOfScalar(u32, distinct_x.items, coord.x) == null) {
                try distinct_x.append(allocator, coord.x);
            }
            if (std.mem.indexOfScalar(u32, distinct_y.items, coord.y) == null) {
                try distinct_y.append(allocator, coord.y);
            }
        }

        // Sort X and Y coords
        std.sort.heap(u32, distinct_x.items, {}, std.sort.asc(u32));
        std.sort.heap(u32, distinct_y.items, {}, std.sort.asc(u32));

        // Remap them to smaller numbers, keeping a gap between consecutive coords
        // and preserving a gap at 0
        for (distinct_x.items, 0..) |x, i| {
            try big_to_small_x.put(x, @as(u32, @intCast(i * 2 + 1)));
            max_x = i * 2 + 1;
        }
        for (distinct_y.items, 0..) |y, i| {
            try big_to_small_y.put(y, @as(u32, @intCast(i * 2 + 1)));
            max_y = i * 2 + 1;
        }
    }

    // Initialize image buffer
    const image = try allocator.alloc([]u8, max_y + 2);
    defer allocator.free(image);

    for (0..max_y + 2) |y| {
        image[y] = try allocator.alloc(u8, (max_x + 2) * 3);
        @memset(image[y], 0);
    }
    defer {
        for (0..max_y + 2) |y| {
            allocator.free(image[y]);
        }
    }

    // Draw points in white and their lines in red in the image buffer
    for (lines, 0..) |coord, i| {
        const x1 = big_to_small_x.get(coord.x).?;
        const y1 = big_to_small_y.get(coord.y).?;
        image[y1][x1 * 3 + RED] = 0xFF;
        image[y1][x1 * 3 + GREEN] = 0xFF;
        image[y1][x1 * 3 + BLUE] = 0xFF;

        const end = lines[(i + 1) % lines.len];
        const x2 = big_to_small_x.get(end.x).?;
        const y2 = big_to_small_y.get(end.y).?;

        if (x1 != x2) {
            if (x1 < x2) {
                for (x1..x2) |x| {
                    image[y1][x * 3 + RED] = 0xFF;
                }
            } else {
                for (x2..x1) |x| {
                    image[y1][x * 3 + RED] = 0xFF;
                }
            }
        } else {
            if (y1 < y2) {
                for (y1..y2) |y| {
                    image[y][x1 * 3 + RED] = 0xFF;
                }
            } else {
                for (y2..y1) |y| {
                    image[y][x1 * 3 + RED] = 0xFF;
                }
            }
        }
    }

    // Uncomment this and choose a point inside the polygon for the start X and Y
    // Too lazy to write the code to calculate this
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    // try util.dumpImage(image, "image.ppm"); if (true) return;

    // Flood fill the image green starting from a point inside
    {
        const flood_start_x = 250;
        const flood_start_y = 150;

        var frontier: std.ArrayList(Coord) = .{};
        defer frontier.deinit(allocator);
        try frontier.append(allocator, .{ .x = flood_start_x, .y = flood_start_y });

        while (frontier.items.len > 0) {
            const next = frontier.pop().?;
            if (image[next.y][next.x * 3 + GREEN] != 0x00) {
                continue;
            }

            image[next.y][next.x * 3 + GREEN] = 0xFF;

            if (isPixelBlack(image, next.x, next.y - 1)) {
                try frontier.append(allocator, .{ .x = next.x, .y = next.y - 1 });
            }
            if (isPixelBlack(image, next.x, next.y + 1)) {
                try frontier.append(allocator, .{ .x = next.x, .y = next.y + 1 });
            }
            if (isPixelBlack(image, next.x - 1, next.y)) {
                try frontier.append(allocator, .{ .x = next.x - 1, .y = next.y });
            }
            if (isPixelBlack(image, next.x + 1, next.y)) {
                try frontier.append(allocator, .{ .x = next.x + 1, .y = next.y });
            }
        }
    }

    // Find the largest rectangle entirely within the polygon
    var largest_area: u64 = 0;
    var largest_first: Coord = undefined;
    var largest_second: Coord = undefined;

    for (0..lines.len - 1) |i| {
        nextPair: for (i..lines.len) |j| {
            const first = lines[i];
            const second = lines[j];

            // Calculate area and continue if this isn't bigger than an already found rectangle
            const area = ((@abs(@as(i64, first.x) - @as(i64, second.x)) + 1) * (@abs(@as(i64, first.y) - @as(i64, second.y)) + 1));
            if (area < largest_area) {
                continue;
            }

            const x1 = big_to_small_x.get(@min(first.x, second.x)).?;
            const x2 = big_to_small_x.get(@max(first.x, second.x)).?;

            const y1 = big_to_small_y.get(@min(first.y, second.y)).?;
            const y2 = big_to_small_y.get(@max(first.y, second.y)).?;

            // Check every pixel inside the rectangle to see if any are outside the polygon
            for (y1..y2 + 1) |y| {
                for (x1..x2 + 1) |x| {
                    if (isPixelBlack(image, x, y)) {
                        continue :nextPair;
                    }
                }
            }

            largest_area = area;
            largest_first = first;
            largest_second = second;
        }
    }

    // Draw the largest rectangle in blue
    {
        const x1 = big_to_small_x.get(@min(largest_first.x, largest_second.x)).?;
        const x2 = big_to_small_x.get(@max(largest_first.x, largest_second.x)).?;

        const y1 = big_to_small_y.get(@min(largest_first.y, largest_second.y)).?;
        const y2 = big_to_small_y.get(@max(largest_first.y, largest_second.y)).?;

        for (y1..y2 + 1) |y| {
            for (x1..x2 + 1) |x| {
                image[y][x * 3 + BLUE] = 0xFF;
            }
        }
    }

    // try util.dumpImage(image, "image.ppm");
    print("{d}", .{largest_area});
}

fn parseLine(_: std.mem.Allocator, line: []const u8) !Coord {
    const comma_index = std.mem.indexOfScalar(u8, line, ',') orelse return error.CommaNotFound;
    const x = try std.fmt.parseInt(u32, line[0..comma_index], 10);
    const y = try std.fmt.parseInt(u32, line[comma_index + 1 .. line.len], 10);
    return .{ .x = x, .y = y };
}

const RED = 0;
const GREEN = 1;
const BLUE = 2;

fn isPixelBlack(image: []const []const u8, x: usize, y: usize) bool {
    return image[y][x * 3 + RED] == 0x00 and image[y][x * 3 + GREEN] == 0x00 and image[y][x * 3 + BLUE] == 0x00;
}

const Coord = struct { x: u32, y: u32 };

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
