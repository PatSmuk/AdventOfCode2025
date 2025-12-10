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
    var iteration: u32 = 0;

    // Used by allConnected, no point in it allocating on every call
    const point_is_in_network = try allocator.alloc(bool, connections.len);
    defer allocator.free(point_is_in_network);

    // Same here
    var frontier: std.ArrayList(usize) = .{};
    defer frontier.deinit(allocator);
    try frontier.ensureTotalCapacity(allocator, connections.len);

    while (!allConnected(connections, point_is_in_network, &frontier)) {
        // print("{d}\n", .{iteration});

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
        iteration += 1;
    }

    print("{any}\n", .{closest_pair});
    print("{any}\n", .{lines[closest_pair[0]]});
    print("{any}\n", .{lines[closest_pair[1]]});
    print("{d}\n", .{lines[closest_pair[0]].x * lines[closest_pair[1]].x});
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

fn allConnected(connections: [][]bool, point_is_in_network: []bool, frontier: *std.ArrayList(usize)) bool {
    @memset(point_is_in_network, false);

    frontier.clearRetainingCapacity();
    frontier.appendAssumeCapacity(0);

    while (frontier.items.len > 0) {
        const next = frontier.pop().?;
        point_is_in_network[next] = true;

        for (connections[next], 0..) |is_connected, i| {
            if (is_connected and !point_is_in_network[i] and std.mem.indexOfScalar(usize, frontier.items, i) == null) {
                frontier.appendAssumeCapacity(i);
            }
        }
    }

    return std.mem.allEqual(bool, point_is_in_network, true);
}

const Coord = struct { x: u32, y: u32, z: u32 };

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
