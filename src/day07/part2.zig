pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines([]u8, input_allocator.allocator(), "day07.txt", parseLine);

    // Initialize beams list
    const start_x = std.mem.indexOfScalar(u8, lines[0], 'S') orelse return error.StartPositionNotFound;
    var beams: std.ArrayList(Beam) = .{};
    defer beams.deinit(allocator);
    try beams.append(allocator, .{ .created_by = .{ start_x, 0 }, .coord = .{ start_x, 0 }, .paths = 1 });

    // Keep track of which splitters have been visited and created their two side beams
    var splitters_visited = std.AutoHashMap(Coord, void).init(allocator);
    defer splitters_visited.deinit();

    // When a beam hits the bottom we'll add its paths to this map for that coordinate
    var final_nodes = std.AutoHashMap(Coord, u64).init(allocator);
    defer final_nodes.deinit();

    while (beams.items.len > 0) {
        // Dequeue a beam and move it downward
        const beam = beams.orderedRemove(0);
        const x = beam.coord[0];
        const y = beam.coord[1] + 1;

        // Have we hit the bottom?
        if (y == lines.len) {
            try util.mapInc(&final_nodes, .{ x, y }, beam.paths);
            continue;
        }

        // Is this anything but a splitter?
        if (lines[y][x] != '^') {
            // Add the moved beam to the list
            beams.appendAssumeCapacity(.{ .coord = .{ x, y }, .paths = beam.paths, .created_by = beam.created_by });
            continue;
        }

        // Have we already created beams for this splitter?
        if (splitters_visited.contains(.{ x, y })) {
            for (beams.items, 0..) |unchecked_beam, i| {
                // Only increment the beams that were created by this splitter
                if (unchecked_beam.created_by[0] == x and unchecked_beam.created_by[1] == y) {
                    beams.items[i].paths += beam.paths;
                }
            }
            continue;
        }

        // Create two beams for this splitter
        try splitters_visited.put(.{ x, y }, {});
        beams.appendAssumeCapacity(.{ .created_by = .{ x, y }, .coord = .{ x - 1, y }, .paths = beam.paths });
        try beams.append(allocator, .{ .created_by = .{ x, y }, .coord = .{ x + 1, y }, .paths = beam.paths });
    }

    // Calculate total amount of paths leading to bottom
    var total_paths: u64 = 0;
    var final_nodes_iter = final_nodes.valueIterator();
    while (final_nodes_iter.next()) |paths| {
        total_paths += paths.*;
    }
    print("{d}", .{total_paths});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    return allocator.dupe(u8, line);
}

const Beam = struct {
    coord: Coord,
    created_by: Coord,
    paths: u64,
};
const Coord = [2]usize;

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
