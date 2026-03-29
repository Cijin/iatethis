const std = @import("std");

const calorie_folder = "calories";
const calorie_file_name = "calories.txt";

fn getCalories(allocator: std.mem.Allocator) ![][7]u32 {
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

pub fn getCalorieInfo(allocator: std.mem.Allocator) ![]const u8 {
    var calorie_text: []const u8 = "| Week | Average |\n";
    const calories = try getCalories(allocator);
    for (calories, 0..) |weekly, i| {
        const week_number: usize = calories.len - i;
        var sum: f32 = 0;
        var len: f32 = weekly.len;
        for (weekly, 0..) |c, j| {
            sum += @floatFromInt(c);
            if (c == 0) {
                len = @floatFromInt(j);
                break;
            }
        }

        var avg:f32 = 0; 
        if (len == 0) {
            // Fix: this spacing shit is not precise, there has to be a better way
            calorie_text = try std.fmt.allocPrint(allocator, "{s}|     {d:0<2} | {d:0>7.2} |\n", .{calorie_text, week_number, avg});         
            continue;
        }
        avg = sum / len;
        calorie_text = try std.fmt.allocPrint(allocator, "{s}|     {d:0>2} | {d:0>7.2} |\n", .{calorie_text, week_number, avg});         
    }

    return calorie_text;
}
