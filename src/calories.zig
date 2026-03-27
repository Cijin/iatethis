const std = @import("std");

const calorie_folder = "calories";
const calorie_file_name = "calories.txt";

pub const Calorie = struct {
    average: f32,
    calories: [7]u32,
};

pub fn getCalories() !void {
    // 1 for the `/`
    var buf: [calorie_folder.len + calorie_file_name.len + 1]u8 = undefined;
    const calorie_file_path = try std.fmt.bufPrint(&buf, "{s}/{s}", .{ calorie_folder, calorie_file_name });
    var file_buf: [8192]u8 = undefined;
    const file = try std.fs.cwd().openFile(calorie_file_path, .{});
    defer file.close();

    var file_reader = file.reader(&file_buf);
    var reader = &file_reader.interface;
    while (reader.takeDelimiterInclusive('\n')) |line| {
        if (line.len == 0) continue;
        var is_week_start = false;
        if (line[0] == 'W') is_week_start = true;

        // Todo:
        // Just the calories
        // Take 7 at a time
        std.debug.print("WeekStart: {} => {s}", .{ is_week_start, line });
    } else |err| {
        if (err != error.EndOfStream) return err;
    }
}

pub fn main() !void {
    try getCalories();
}
