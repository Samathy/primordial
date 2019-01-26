module primordial.sdl.display;

import std.string;
import std.conv : to;

import derelict.sdl2.sdl, derelict.sdl2.ttf;

import primordial.init : sdl_context;
import primordial.sdl.sdl_funcs;
import primordial.input.keyboard;
import primordial.colors : color;

struct screen_dimensions
{
    int w = 640;
    int h = 480;
};

class sdl_window
{

    public
    {
        this()
        {
            this("");
        }

        this(string title, int x = SDL_WINDOWPOS_UNDEFINED, int y = SDL_WINDOWPOS_UNDEFINED,
                immutable(int) width = 640, immutable(int) height = 480,
                immutable(bool) init = true, immutable(bool) has_surface = false)
        {
            this.title = title;
            this.window_x = x;
            this.window_y = y;
            this.window_width = width;
            this.window_height = height;

            this.has_surface = has_surface;

            this.create_window(SDL_WINDOW_SHOWN);

            if (!this.has_surface)
            {
                this.create_renderer();
            }

            this.clear();
        }

        ~this()
        {
            sdl_context.DestroyWindow(this.window);
        }

        void update()
        {
            sdl_context.RenderPresent(this.renderer);
        }

        void clear()
        {
            sdl_context.SetRenderDrawColor(this.renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            sdl_context.RenderClear(this.renderer);
        }

        void clear(color col)
        {
            sdl_context.SetRenderDrawColor(this.renderer, col.r, col.g, col.b, col.a);
            sdl_context.RenderClear(this.renderer);
        }

        @safe pure nothrow immutable(string) get_title()
        {
            return this.title.dup();
        }

        @safe pure nothrow screen_dimensions get_size()
        {
            screen_dimensions s;
            s.w = this.window_width;
            s.h = this.window_height;
            return s;
        }

        @safe pure nothrow SDL_Window* get_window()
        {
            return this.window;
        }

        @safe pure nothrow SDL_Surface* get_surface()
        {
            return this.surface;
        }

        @safe pure nothrow SDL_Renderer* get_renderer()
        {
            return this.renderer;
        }

    }

    private
    {
        /* \brief Actualy create a window.
         *
         * Throws SDLException on error */
        void create_window(SDL_WindowFlags flags)
        {

            this.window = sdl_context.CreateWindow(toStringz(this.title), this.window_x,
                    this.window_y, this.window_width, this.window_height, flags);

            if (this.has_surface)
            {
                this.surface = sdl_context.GetWindowSurface(this.window);
            }

        }

        void create_renderer()
        {
            this.renderer = sdl_context.CreateRenderer(this.window, -1, SDL_RENDERER_SOFTWARE);
        }

        string title;
        int window_x;
        int window_y;
        int window_width;
        int window_height;
        bool has_surface;
        SDL_Window* window = null;
        SDL_Surface* surface = null;
        SDL_Renderer* renderer = null;
    }
}

unittest
{

    import std.stdio;

    primordial.sdl.display.sdl_window main_window;
    try
    {
        main_window = new primordial.sdl.display.sdl_window("flatmap", 640, 480);
    }
    catch (SDLException e)
    {
        writeln("Setting up an SDL window failed with: " ~ e.GetError());
        assert(false);
    }
    catch (Exception e)
    {
        assert(false);
    }

    assert(main_window.title == "flatmap");
    assert(main_window.window != null);
    /* assert(main_window.surface != null); */
}
