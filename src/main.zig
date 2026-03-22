const std = @import("std");
const sdl = @import("sdl3").c;
const calories = @import("calories.zig");

const Width = 640;
const Height = 480;

// Note:
// SDL_Wiki: https://wiki.libsdl.org/SDL3/FrontPage
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();
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

    // Fix: maxInt(i32) is too big? Not sure. Need to check how people do this.
    const font_ttf = try std.fs.cwd().readFileAlloc(alloc, "font/font.ttf", std.math.maxInt(i32));
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

    const hello = "Hello World!\n";
    const text = sdl.TTF_CreateText(engine, font.?, hello.ptr, hello.len);
    if (text == null) {
        sdl.SDL_Log("Failed to create text: %s", sdl.SDL_GetError());
        return error.TextFailed;
    }

    if (!sdl.TTF_SetTextColor(text, 0xff, 0xff, 0xff, 0xff)) {
        sdl.SDL_Log("Failed to set text color: %s", sdl.SDL_GetError());
        return error.TextColorFailed;
    }

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

        _ = sdl.TTF_DrawRendererText(text, 200, 200);
        _ = sdl.SDL_RenderPresent(renderer);
    }
}
