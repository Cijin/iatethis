const std = @import("std");

const calorie_folder = "calories";
const calorie_file_name = "calories.txt";

pub const Calorie = struct {
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

    // 1 for the `/`
    var path_buf: [calorie_folder.len + calorie_file_name.len + 1]u8 = undefined;
    const calorie_file_path = try std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ calorie_folder, calorie_file_name });

    var calorie_raw: [4096]u8 = undefined;
    var calorie_len: usize = undefined;

    var iterator = calories_dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.kind == .file) {
            if (std.mem.eql(u8, entry.name, calorie_file_name)) {
                const calorie_file = try cwd.openFile(calorie_file_path, .{});
                defer calorie_file.close();

                calorie_len = try calorie_file.readAll(&calorie_raw);
                break;
            }
        }
    }
}
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

pub fn main() !void {
    try getCalories();
}
