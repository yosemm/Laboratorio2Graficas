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

var current_framebuffer: Framebuffer = [_]rl.Color{dead_color} ** framebuffer_size;

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

pub fn main() void {
    rl.initWindow(screen_width, screen_height, "Conway's Game of Life");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    // Dibujar un punto
    point(&current_framebuffer, framebuffer_width / 2, framebuffer_height / 2, alive_color);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        draw_framebuffer(&current_framebuffer);
        rl.endDrawing();
    }
}
