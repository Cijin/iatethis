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
        // Todo:
        // Read the file inside this dir if it's a *.txt file
        // There is only one at the moment so just read that one
        // Get start_date, end_date, calories for the week
        // If current week has less than 7 values show projected
        // based on last week's calories for those days.
        //
        // Later I can do some maths to put weight and select gain or loose
        // and it will show me a breakdown of how many calories I should eat
        // per day. But based on my preference of eating more calories on
        // alternate days.
    }
}
