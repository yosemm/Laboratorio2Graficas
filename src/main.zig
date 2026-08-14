const rl = @import("raylib");

const framebuffer_width: i32 = 120;
const framebuffer_height: i32 = 90;
const pixel_size: i32 = 8;

const screen_width: i32 = framebuffer_width * pixel_size;
const screen_height: i32 = framebuffer_height * pixel_size;
const framebuffer_size: usize = @intCast(framebuffer_width * framebuffer_height);

const alive_color = rl.Color.init(110, 235, 255, 255);
const dead_color = rl.Color.init(5, 15, 40, 255);

const Framebuffer = [framebuffer_size]rl.Color;
const Cell = struct {
    x: i32,
    y: i32,
};

var current_framebuffer: Framebuffer = [_]rl.Color{dead_color} ** framebuffer_size;
var next_framebuffer: Framebuffer = [_]rl.Color{dead_color} ** framebuffer_size;

fn index(x: i32, y: i32) usize {
    const row: usize = @intCast(y);
    const column: usize = @intCast(x);
    const width: usize = @intCast(framebuffer_width);
    return row * width + column;
}

fn point(framebuffer: *Framebuffer, x: i32, y: i32, color: rl.Color) void {
    if (x < 0 or x >= framebuffer_width or y < 0 or y >= framebuffer_height) {
        return;
    }

    framebuffer[index(x, y)] = color;
}

fn get_color(framebuffer: *const Framebuffer, x: i32, y: i32) rl.Color {
    const wrapped_x = @mod(x, framebuffer_width);
    const wrapped_y = @mod(y, framebuffer_height);
    return framebuffer[index(wrapped_x, wrapped_y)];
}

fn is_alive(color: rl.Color) bool {
    return color.r == alive_color.r and
        color.g == alive_color.g and
        color.b == alive_color.b;
}

fn count_neighbors(framebuffer: *const Framebuffer, x: i32, y: i32) u8 {
    var neighbors: u8 = 0;
    var offset_y: i32 = -1;

    while (offset_y <= 1) : (offset_y += 1) {
        var offset_x: i32 = -1;
        while (offset_x <= 1) : (offset_x += 1) {
            if (offset_x == 0 and offset_y == 0) {
                continue;
            }

            if (is_alive(get_color(framebuffer, x + offset_x, y + offset_y))) {
                neighbors += 1;
            }
        }
    }

    return neighbors;
}

fn render(current: *Framebuffer, next: *Framebuffer) void {
    var y: i32 = 0;
    while (y < framebuffer_height) : (y += 1) {
        var x: i32 = 0;
        while (x < framebuffer_width) : (x += 1) {
            const neighbors = count_neighbors(current, x, y);
            const alive = is_alive(get_color(current, x, y));

            const will_live = (alive and (neighbors == 2 or neighbors == 3)) or
                (!alive and neighbors == 3);

            if (will_live) {
                point(next, x, y, alive_color);
            } else {
                point(next, x, y, dead_color);
            }
        }
    }

    current.* = next.*;
}

fn draw_framebuffer(framebuffer: *const Framebuffer) void {
    var y: i32 = 0;
    while (y < framebuffer_height) : (y += 1) {
        var x: i32 = 0;
        while (x < framebuffer_width) : (x += 1) {
            const color = get_color(framebuffer, x, y);
            rl.drawRectangle(
                x * pixel_size,
                y * pixel_size,
                pixel_size,
                pixel_size,
                color,
            );
        }
    }
}

fn add_pattern(framebuffer: *Framebuffer, start_x: i32, start_y: i32, cells: []const Cell) void {
    for (cells) |cell| {
        point(framebuffer, start_x + cell.x, start_y + cell.y, alive_color);
    }
}

fn add_block(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 0, .y = 0 }, .{ .x = 1, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_beehive(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 3, .y = 1 },
        .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 2 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_loaf(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 3, .y = 1 },
        .{ .x = 1, .y = 2 }, .{ .x = 3, .y = 2 },
        .{ .x = 2, .y = 3 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_boat(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 0, .y = 0 }, .{ .x = 1, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 2, .y = 1 },
        .{ .x = 1, .y = 2 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_tub(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 },
        .{ .x = 0, .y = 1 },
        .{ .x = 2, .y = 1 },
        .{ .x = 1, .y = 2 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_blinker(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 0, .y = 0 },
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 2 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_toad(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 3, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_beacon(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 0, .y = 0 }, .{ .x = 1, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 },
        .{ .x = 2, .y = 2 }, .{ .x = 3, .y = 2 },
        .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 3 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_glider(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 },
        .{ .x = 2, .y = 1 },
        .{ .x = 0, .y = 2 },
        .{ .x = 1, .y = 2 },
        .{ .x = 2, .y = 2 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn add_lwss(framebuffer: *Framebuffer, x: i32, y: i32) void {
    const cells = [_]Cell{
        .{ .x = 1, .y = 0 }, .{ .x = 4, .y = 0 },
        .{ .x = 0, .y = 1 }, .{ .x = 0, .y = 2 },
        .{ .x = 4, .y = 2 }, .{ .x = 0, .y = 3 },
        .{ .x = 1, .y = 3 }, .{ .x = 2, .y = 3 },
        .{ .x = 3, .y = 3 },
    };
    add_pattern(framebuffer, x, y, &cells);
}

fn load_initial_pattern(framebuffer: *Framebuffer) void {
    // Still lifes.
    add_block(framebuffer, 8, 8);
    add_beehive(framebuffer, 32, 8);
    add_loaf(framebuffer, 58, 8);
    add_boat(framebuffer, 84, 8);
    add_tub(framebuffer, 108, 8);

    // Osciladores.
    add_blinker(framebuffer, 15, 36);
    add_toad(framebuffer, 50, 36);
    add_beacon(framebuffer, 85, 35);

    // Naves espaciales.
    add_glider(framebuffer, 35, 66);
    add_lwss(framebuffer, 88, 66);
}

pub fn main() void {
    rl.initWindow(screen_width, screen_height, "Conway's Game of Life");
    defer rl.closeWindow();

    rl.setTargetFPS(10);
    load_initial_pattern(&current_framebuffer);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        draw_framebuffer(&current_framebuffer);
        rl.endDrawing();

        render(&current_framebuffer, &next_framebuffer);
    }
}