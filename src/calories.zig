const std = @import("std");

const calorie_folder = "calories";

pub const Calorie = struct {
    start_date: u8,
    end_date: u8,
    average: f32,
    calories: [7]u32,
};

pub fn getCalories() !void {
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const cwd = std.fs.cwd();
    const path = try cwd.realpath(calorie_folder, &buf);
    std.debug.print("{s}\n", .{path});

    var calories_dir = try cwd.openDir(calorie_folder, .{ .iterate = true });
    defer calories_dir.close();

    var iterator = calories_dir.iterate();
    while (try iterator.next()) |entry| {
        std.debug.print("{s}\n", .{entry.name});
    }
}
