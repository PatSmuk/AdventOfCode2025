pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines(Coord, input_allocator.allocator(), "day08.txt", parseLine);

    var connections = try allocator.alloc([]bool, lines.len);
    defer allocator.free(connections);

    for (0..lines.len) |i| {
        connections[i] = try allocator.alloc(bool, lines.len);
        @memset(connections[i], false);
    }
    defer {
        for (0..lines.len) |i| {
            allocator.free(connections[i]);
        }
    }

    var shortest_distance: f64 = std.math.inf(f64);
    var closest_pair: [2]usize = undefined;

    for (0..1000) |iteration| {
        print("{d}\n", .{iteration});

        for (0..lines.len - 1) |i| {
            for (i + 1..lines.len) |j| {
                if (connections[i][j]) {
                    continue;
                }
                const d = dist(lines[i], lines[j]);
                if (d < shortest_distance) {
                    closest_pair = .{ i, j };
                    shortest_distance = d;
                }
            }
        }

        const a = closest_pair[0];
        const b = closest_pair[1];
        connections[a][b] = true;
        connections[b][a] = true;

        shortest_distance = std.math.inf(f64);
    }

    var unvisited_points: std.ArrayList(usize) = .{};
    defer unvisited_points.deinit(allocator);
    for (0..lines.len) |i| {
        try unvisited_points.append(allocator, i);
    }

    var network_sizes: std.ArrayList(u32) = .{};
    defer network_sizes.deinit(allocator);

    while (unvisited_points.items.len > 0) {
        const start = unvisited_points.items[unvisited_points.items.len - 1];
        var network_size: u32 = 0;

        var frontier: std.ArrayList(usize) = .{};
        defer frontier.deinit(allocator);
        try frontier.append(allocator, start);

        while (frontier.items.len > 0) {
            const next = frontier.pop().?;

            // Remove it from unvisited_points (if it wasn't already visited since being added to frontier)
            const index = std.mem.indexOfScalar(usize, unvisited_points.items, next);
            if (index == null) {
                continue;
            }

            network_size += 1;
            _ = unvisited_points.orderedRemove(index.?);

            // Add any connected points that are unvisited to the frontier
            for (connections[next], 0..) |is_connected, neighbour| {
                if (!is_connected) {
                    continue;
                }
                if (std.mem.indexOfScalar(usize, unvisited_points.items, neighbour) != null) {
                    try frontier.append(allocator, neighbour);
                }
            }
        }

        try network_sizes.append(allocator, network_size);
    }

    std.sort.insertion(u32, network_sizes.items, {}, std.sort.desc(u32));

    for (0..3) |i| {
        print("{d}\n", .{network_sizes.items[i]});
    }
    print("{d}", .{network_sizes.items[0] * network_sizes.items[1] * network_sizes.items[2]});
}

fn parseLine(_: std.mem.Allocator, line: []const u8) !Coord {
    var iter = std.mem.tokenizeScalar(u8, line, ',');

    const x_str = iter.next() orelse return error.CouldNotParseLine;
    const x = try std.fmt.parseInt(u32, x_str, 10);

    const y_str = iter.next() orelse return error.CouldNotParseLine;
    const y = try std.fmt.parseInt(u32, y_str, 10);

    const z_str = iter.next() orelse return error.CouldNotParseLine;
    const z = try std.fmt.parseInt(u32, z_str, 10);

    return .{ .x = x, .y = y, .z = z };
}

fn dist(a: Coord, b: Coord) f64 {
    const x_diff = @as(i64, @intCast(a.x)) - @as(i64, @intCast(b.x));
    const y_diff = @as(i64, @intCast(a.y)) - @as(i64, @intCast(b.y));
    const z_diff = @as(i64, @intCast(a.z)) - @as(i64, @intCast(b.z));
    return @sqrt(@as(f64, @floatFromInt(x_diff * x_diff + y_diff * y_diff + z_diff * z_diff)));
}

const Coord = struct { x: u32, y: u32, z: u32 };

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
