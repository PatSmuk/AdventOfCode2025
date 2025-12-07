pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input_allocator = std.heap.ArenaAllocator.init(allocator);
    defer input_allocator.deinit();
    const lines = try util.readInputFileLines([]u8, input_allocator.allocator(), "day07.txt", parseLine);

    // Initialize beams list
    const start_x = std.mem.indexOfScalar(u8, lines[0], 'S') orelse return error.StartPositionNotFound;
    var beams: std.ArrayList(Coord) = .{};
    defer beams.deinit(allocator);
    try beams.append(allocator, .{ start_x, 0 });

    // Keep track of which splitters have been visited and created their two side beams
    var splitters_visited = std.AutoHashMap(Coord, void).init(allocator);
    defer splitters_visited.deinit();

    while (beams.items.len > 0) {
        var beam = beams.orderedRemove(0);
        beam[1] += 1;

        // Have we hit the bottom?
        if (beam[1] == lines.len) {
            continue;
        }

        if (lines[beam[1]][beam[0]] != '^') {
            if (lines[beam[1]][beam[0]] == '|') {
                continue;
            }
            lines[beam[1]][beam[0]] = '|';
            beams.appendAssumeCapacity(beam);
        } else {
            if (splitters_visited.contains(beam)) {
                continue;
            }
            try splitters_visited.put(beam, {});
            beams.appendAssumeCapacity(.{ beam[0] - 1, beam[1] });
            try beams.append(allocator, .{ beam[0] + 1, beam[1] });

            lines[beam[1]][beam[0] - 1] = '|';
            lines[beam[1]][beam[0] + 1] = '|';
        }
    }

    print("{d}", .{splitters_visited.count()});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    return allocator.dupe(u8, line);
}

const Coord = [2]usize;

const std = @import("std");
const util = @import("util");

const print = std.debug.print;
