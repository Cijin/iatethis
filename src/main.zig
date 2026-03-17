const std = @import("std");
const sdl = @import("sdl3");
// Docs: https://7games.codeberg.page/zig-sdl3/@docs/#sdl3.render

const Width = 640;
const Height = 480;

pub fn main() !void {
    var window: *sdl.c.SDL_Window = undefined;
    var renderer: *sdl.c.SDL_Renderer = undefined;

    if (!sdl.c.SDL_SetAppMetadata("SDL Window", "1.0", "com.bored.renderer")) {
        sdl.c.SDL_Log("Failed to set SDL Metadata: %s", sdl.c.SDL_GetError());
        return error.SDLSetupFailed;
    }

    if (!sdl.c.SDL_Init(sdl.c.SDL_INIT_VIDEO)) {
        sdl.c.SDL_Log("Could'nt initialize SDL: %s", sdl.c.SDL_GetError());
        return error.SDLFailed;
    }

    if (!sdl.c.SDL_CreateWindowAndRenderer("clear", Width, Height, 0, @ptrCast(&window), @ptrCast(&renderer))) {
        sdl.c.SDL_Log("Couldn't create window/renderer: %s", sdl.c.SDL_GetError());
        return error.SDLWindow;
    }

    errdefer sdl.c.SDL_DestroyWindow(window);
    errdefer sdl.c.SDL_DestroyRenderer(renderer);

    var quit = false;
    var event: sdl.c.SDL_Event = undefined;
    while (!quit) {
        while (sdl.c.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.c.SDL_EVENT_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = sdl.c.SDL_SetRenderDrawColor(renderer, 0x18, 0x18, 0x18, 0xff);
        _ = sdl.c.SDL_RenderClear(renderer);

        var rect = sdl.c.struct_SDL_FRect{
            .w = Width / 10,
            .h = Height / 10,
        };
        rect.x = (Width - rect.w) / 2;
        rect.y = (Height - rect.h) / 2;
        _ = sdl.c.SDL_SetRenderDrawColor(renderer, 0xff, 0, 0, 0xff);
        _ = sdl.c.SDL_RenderFillRect(renderer, @ptrCast(&rect));
        _ = sdl.c.SDL_RenderPresent(renderer);
    }

    sdl.c.SDL_Quit();
}
