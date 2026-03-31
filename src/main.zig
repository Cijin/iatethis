const std = @import("std");
const sdl = @import("sdl3").c;
const calories = @import("calories.zig");

const Width = 640;
const Height = 480;
const ColOneX = 10;
const ColTwoX = 150;
const RowY = 10;

// Note:
// SDL_Wiki: https://wiki.libsdl.org/SDL3/FrontPage
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var window: *sdl.SDL_Window = undefined;
    var renderer: *sdl.SDL_Renderer = undefined;

    if (!sdl.SDL_SetAppMetadata("SDL Window", "1.0", "com.bored.renderer")) {
        sdl.SDL_Log("Failed to set SDL Metadata: %s", sdl.SDL_GetError());
        return error.SDLSetupFailed;
    }

    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        sdl.SDL_Log("Could'nt initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLFailed;
    }

    if (!sdl.SDL_CreateWindowAndRenderer("clear", Width, Height, 0, @ptrCast(&window), @ptrCast(&renderer))) {
        sdl.SDL_Log("Couldn't create window/renderer: %s", sdl.SDL_GetError());
        return error.SDLWindow;
    }

    if (!sdl.TTF_Init()) {
        sdl.SDL_Log("Couldn't init ttf: %s", sdl.SDL_GetError());
        return error.TTFInitFailed;
    }

    defer {
        sdl.SDL_DestroyWindow(window);
        sdl.SDL_DestroyRenderer(renderer);
        sdl.TTF_Quit();
        sdl.SDL_Quit();
    }

    // Todo: maxInt(i32) is too big? Not sure.
    const font_ttf = try std.fs.cwd().readFileAlloc(allocator, "font/font.ttf", std.math.maxInt(i32));
    const font = sdl.TTF_OpenFontIO(sdl.SDL_IOFromConstMem(font_ttf.ptr, font_ttf.len), true, 18.0);
    if (font == null) {
        sdl.SDL_Log("Could not open font file: %s", sdl.SDL_GetError());
        return error.FontFailed;
    }
    defer sdl.TTF_CloseFont(font);

    const engine = sdl.TTF_CreateRendererTextEngine(renderer);
    if (engine == null) {
        sdl.SDL_Log("Failed to create text engine: %s", sdl.SDL_GetError());
        return error.TextEngineFialed;
    }

    // Todo: render calorie info to window
    //const calories = try calories.getCalories(allocator);

    var quit = false;
    var event: sdl.SDL_Event = undefined;
    while (!quit) {
        while (sdl.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => {
                    quit = true;
                },
                sdl.SDL_EVENT_KEY_DOWN => {
                    if (event.key.key == sdl.SDLK_Q or event.key.key == sdl.SDLK_ESCAPE) {
                        quit = true;
                    }
                },
                sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => |b| {
                    sdl.SDL_Log("Mouse button pressed: %d", b);
                },

                else => {},
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0x18, 0x18, 0x18, 0xff);
        _ = sdl.SDL_RenderClear(renderer);

        _ = sdl.SDL_RenderPresent(renderer);
    }
}
