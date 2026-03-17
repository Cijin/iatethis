const std = @import("std");
const sdl = @import("sdl3").c;
const calories = @import("calories.zig");

const Width = 640;
const Height = 480;

// Note:
// SDL_Wiki: https://wiki.libsdl.org/SDL3/FrontPage
pub fn main() !void {
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

    errdefer sdl.SDL_DestroyWindow(window);
    errdefer sdl.SDL_DestroyRenderer(renderer);

    try calories.getCalories();

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

        var rect = sdl.struct_SDL_FRect{
            .w = Width / 10,
            .h = Height / 10,
        };
        rect.x = (Width - rect.w) / 2;
        rect.y = (Height - rect.h) / 2;
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0xff, 0, 0, 0xff);
        _ = sdl.SDL_RenderFillRect(renderer, @ptrCast(&rect));
        _ = sdl.SDL_RenderPresent(renderer);
    }

    sdl.SDL_Quit();
}
