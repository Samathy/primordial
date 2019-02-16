module primordial.sdl.display;

import std.string;
import std.conv : to;

import derelict.sdl2.sdl, derelict.sdl2.ttf;

import primordial.init : sdl_context;
import primordial.sdl.sdl_funcs;
import primordial.input.keyboard;
import primordial.colors : color;

/*
   Represents screen dimensions
*/
struct screen_dimensions
{
    int w = 640;
    int h = 480;
};

/**
  Represents an SDL window including drawable SDL renderer.
*/
class sdl_window
{

    public
    {
        this()
        {
            this("");
        }
        /* 
           Constructor.

            Params:
                string title    The title of the window
                int x = SDL_WINDOWPOS_UNDEFINED    The x location of the window
                int y = SDL_WINDOWPOS_UNDEFINED    The y location of the window
                immutable(int) width    The width of the window
                immutable(int) height   The height of the window
                immutable(bool) init = true    Ignored
                immutable(bool) hasSurface = false    Create an SDL surface? (currently ignored and useless)
        */

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

        /**
          Update this window, rendering to screen everything drawn to it since the last call to clear()
        */
        void update()
        {
            sdl_context.RenderPresent(this.renderer);
        }

        /**
          Clear the screen with white.
        */
        void clear()
        {
            sdl_context.SetRenderDrawColor(this.renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            sdl_context.RenderClear(this.renderer);
        }

        /**
          Clear the screen with a given color
          Params:
              color col    The color struct with which to paint the whole screen.
        */
        void clear(color col)
        {
            sdl_context.SetRenderDrawColor(this.renderer, col.r, col.g, col.b, col.a);
            sdl_context.RenderClear(this.renderer);
        }

        /**
          Returns: immutable copy of the window title
        */
        @safe nothrow immutable(string) get_title()
        {
            return this.title.dup();
        }

        /**
            Returns: A new screen_dimensions struct with the dimensions of this window.
        */
        @safe nothrow screen_dimensions get_size()
        {
            screen_dimensions s;
            s.w = this.window_width;
            s.h = this.window_height;
            return s;
        }

        /**
            Returns: A raw SDL_Window pointer to this window
        */
        @safe nothrow SDL_Window* get_window()
        {
            return this.window;
        }

        /** 
            Returns: A raw SDL_Surface pointer to the surface assotiated with
            this window.
        */
        @safe nothrow SDL_Surface* get_surface()
        {
            return this.surface;
        }

        /** 
            Returns: A raw SDL_Renderer pointer to the renderer assotiated 
            with this window.
        */
        @safe nothrow SDL_Renderer* get_renderer()
        {
            return this.renderer;
        }

    }

    private
    {
        /**
            Creates a new SDL window.

            This might be nicer in a functional form instead of modifying instance variables.

            Throws: SDLException on error
        */
        void create_window(SDL_WindowFlags flags)
        {

            this.window = sdl_context.CreateWindow(toStringz(this.title), this.window_x,
                    this.window_y, this.window_width, this.window_height, flags);

            if (this.has_surface)
            {
                this.surface = sdl_context.GetWindowSurface(this.window);
            }

        }

        /**
            Creates a new renderer for this window

            This might be nicer in a functional form instead of modifying instance variables.
        */
        void create_renderer(
                SDL_RendererFlags flags = SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
        {
            this.renderer = sdl_context.CreateRenderer(this.window, -1, flags);
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
