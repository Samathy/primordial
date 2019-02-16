module primordial.sdl.sdl_funcs;

import std.conv : to;
import std.stdio, std.string;

import derelict.sdl2.sdl, derelict.sdl2.ttf, derelict.util.exception,
    derelict.util.loader : SharedLibVersion;

///Which modules have we loaded?
public bool sdl = false;
public bool ttf = false;

public bool initialised = false;

/**
  Loads the SDL2 libraries using Derelict.

  Throws: SDLException on load failure.


  Params:
      use_sdl = true    Load the SDL Libs?
      use_ttf = true    Load the SDL TTF libs? 
*/
void load_libs(bool use_sdl = true, bool use_ttf = true)
{
    if (use_sdl)
    {
        try
        {
            DerelictSDL2.load(SharedLibVersion(2, 0, 2));
        }
        catch (SharedLibLoadException e)
        {
            throw new Error(e.msg);
        }
    }
    if (use_ttf)
    {
        try
        {
            DerelictSDL2ttf.load();
        }
        catch (SharedLibLoadException e)
        {
            throw new SDLException("Could not load SDL TTF Library", "");
        }
    }

    sdl = use_sdl;
    ttf = use_ttf;
}

/**
  Initialises the loded libraries.

  Throws: SDLException if SDL fails to initialise
*/

void init_sdl()
{
    if (sdl)
    {
        if (SDL_Init(SDL_INIT_VIDEO) > 0)
        {
            throw new SDLException("Failed to initialise SDL", to!string(SDL_GetError()));
        }
    }

    if (ttf)
    {
        TTF_Init();
    }

    initialised = true;
}

/**
    An exception thrown whenever SDL functions return errors.
*/
class SDLException : Exception
{
    this(string msg, string sdl_error, string file = __FILE__, size_t line = __LINE__)
    {
        this.sdl_error = sdl_error;
        super(msg, file, line);
    }

    /** 
      Commonly stores the output of SDL's GetError function.
      Returns: An SDL Error string.
    */
    string GetError()
    {
        return this.sdl_error;
    }

    private
    {
        string sdl_error;
    }
}

/**
  Contains all SDL functions used in Primordial, wrapped
  in similarly named methods. 
  Interested parties should look up documentation for SDL counterpart methods.
*/
class SDL
{
    public
    {

        this()
        {
        }

        ~this()
        {
            SDL_Quit();
        }

        /**
            Throws: SDLException
        */
        SDL_Window* CreateWindow(immutable(char)* title, int x, int y, int w,
                int h, SDL_WindowFlags flags)
        {
            SDL_Window* win = null;

            if ((win = SDL_CreateWindow(title, x, y, w, h, flags)) == null)
            {
                throw new SDLException("Failed to create SDL window" ~ to!string(title),
                        to!string(SDL_GetError()));
            }

            return win;
        }

        /**
            Throws: SDLException
        */
        SDL_Renderer* CreateRenderer(SDL_Window* window, int index, SDL_RendererFlags flags)
        {
            SDL_Renderer* ren = null;

            if ((ren = SDL_CreateRenderer(window, index, flags)) == null)
            {
                throw new SDLException("Failed to create renderer.", to!string(SDL_GetError()));
            }

            return ren;
        }

        /**
            Throws: SDLException
        */
        SDL_Texture* CreateTextureFromSurface(SDL_Renderer* ren, SDL_Surface* surface)
        {
            SDL_Texture* new_texture = null;

            if ((new_texture = SDL_CreateTextureFromSurface(ren, surface)) == null)
            {
                throw new SDLException("Could not create text texture", to!string(SDL_GetError()));
            }

            return new_texture;
        }

        int SetRenderDrawColor(SDL_Renderer* ren, ubyte r, ubyte g, ubyte b, ubyte a)
        {
            return SDL_SetRenderDrawColor(ren, r, g, b, a);
        }

        int RenderDrawPoint(SDL_Renderer* ren, int x, int y)
        {
            return SDL_RenderDrawPoint(ren, x, y);
        }

        int RenderDrawLines(SDL_Renderer* ren, SDL_Point[] points, ubyte pointcount)
        {
            return SDL_RenderDrawLines(ren, points.ptr, pointcount);
        }

        int RenderDrawRect(SDL_Renderer* ren, SDL_Rect* rect)
        {
            return SDL_RenderDrawRect(ren, rect);
        }

        int SetRenderFillRect(SDL_Renderer* ren, SDL_Rect* rect)
        {
            return SDL_RenderFillRect(ren, rect);
        }

        /**
            Throws: SDLException
        */
        SDL_Surface* GetWindowSurface(SDL_Window* win)
        {
            SDL_Surface* sur = null;

            if ((sur = SDL_GetWindowSurface(win)) == null)
            {
                throw new SDLException("Could not get Window surface", to!string(SDL_GetError()));
            }

            return sur;
        }

        int RenderCopyEx(SDL_Renderer* ren, SDL_Texture* tex, SDL_Rect* clip,
                SDL_Rect* texture_space, double angle, SDL_Point* center, SDL_RendererFlip flip)
        {
            return SDL_RenderCopyEx(ren, tex, clip, texture_space, angle, center, flip);
        }

        int RenderFillRect(SDL_Renderer* ren, SDL_Rect* rect)
        {
            return SDL_RenderFillRect(ren, rect);
        }

        int RenderDrawLine(SDL_Renderer* ren, int x, int y, int x2, int y2)
        {
            return SDL_RenderDrawLine(ren, x, y, x2, y2);
        }

        int SaveBMP(SDL_Surface* surface, string filename)
        {
            return SDL_SaveBMP(surface, toStringz(filename));
        }

        void FreeSurface(SDL_Surface* surface)
        {
            SDL_FreeSurface(surface);
        }

        void DestroyTexture(SDL_Texture* texture)
        {
            SDL_DestroyTexture(texture);
        }

        void Delay(int time)
        {
            SDL_Delay(time);
        }

        void RenderPresent(SDL_Renderer* ren)
        {
            return SDL_RenderPresent(ren);
        }

        void RenderClear(SDL_Renderer* ren)
        {
            SDL_RenderClear(ren);
        }

        void DestroyWindow(SDL_Window* window)
        {
            return SDL_DestroyWindow(window);
        }

    }
}

/**
  Contains all SDL TTF functions used in Primordial, wrapped
  in similarly named methods. 
  Interested parties should look up documentation for SDL counterpart methods.
*/
class TTF
{

    public
    {
        this()
        {
        }

        ~this()
        {
            TTF_Quit();
        }

        /**
            Throws: SDLException
        */
        SDL_Surface* RenderText_Solid(TTF_Font* font, immutable(char)* text, SDL_Color color)
        {
            SDL_Surface* new_surface = null;

            if ((new_surface = TTF_RenderText_Solid(font, text, color)) == null)
            {
                throw new SDLException("Could not create text surface", to!string(TTF_GetError()));
            }

            return new_surface;
        }

        /**
            Throws: SDLException
        */
        SDL_Surface* RenderText_Blended(TTF_Font* font, immutable(char)* text, SDL_Color color)
        {
            SDL_Surface* new_surface = null;
            if ((new_surface = TTF_RenderText_Blended(font, text, color)) == null)
            {
                throw new SDLException("Could not create text surface", to!string(TTF_GetError()));
            }

            return new_surface;
        }

        /**
            Throws: SDLException
        */
        TTF_Font* OpenFont(immutable(char)* file, int size)
        {
            TTF_Font* font;

            if ((font = TTF_OpenFont(file, size)) == null)
            {
                writeln(to!string(TTF_GetError()));
                throw new SDLException("Could not load font", to!string(TTF_GetError()));
            }

            return font;
        }
    }
}
