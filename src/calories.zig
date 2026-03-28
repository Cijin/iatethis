const std = @import("std");

const calorie_folder = "calories";
const calorie_file_name = "calories.txt";

pub fn getCalories(allocator: std.mem.Allocator) ![][7]u32 {
    // 1 for the `/`
    var buf: [calorie_folder.len + calorie_file_name.len + 1]u8 = undefined;
    const calorie_file_path = try std.fmt.bufPrint(&buf, "{s}/{s}", .{ calorie_folder, calorie_file_name });
    var file_buf: [8192]u8 = undefined;
    const file = try std.fs.cwd().openFile(calorie_file_path, .{});
    defer file.close();

    var list: std.ArrayList([7]u32) = .empty;
    defer list.deinit(allocator);

    var file_reader = file.reader(&file_buf);
    var reader = &file_reader.interface;
    var is_week_start = false;
    var calorie_items_prev = std.mem.zeroes([7]u32);
    var idx: usize = 0;
    while (reader.peekDelimiterInclusive('\n')) |line| {
        reader.toss(line.len);

        if (line[0] == 'W') {
            if (is_week_start) {
                try list.append(allocator, calorie_items_prev);
                calorie_items_prev = [_]u32{0} ** 7;
            } else {
                is_week_start = true;
            }
            idx = 0;
            continue;
        }

        if (idx >= 7) continue;
        const trimmed = std.mem.trim(u8, line, "\n");
        if (trimmed.len == 0) continue;

        calorie_items_prev[idx] = try std.fmt.parseInt(u32, trimmed, 10);
        idx += 1;
    } else |err| {
        if (err == error.EndOfStream) {
            try list.append(allocator, calorie_items_prev);
        } else {
            return err;
        }
    }

    return allocator.dupe([7]u32, list.items);
}
