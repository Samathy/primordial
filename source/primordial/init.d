module primordial.init;

import std.stdio;

import primordial.sdl.sdl_funcs;
import primordial.sdl.display : sdl_window;
import primordial.primitives.shapes : renderable_abstract_object;

version (unittest) import blerp.blerp;

public SDL sdl_context = null;
public TTF ttf_context = null;

/**
  Module initialiser, only if we're testing.
  Automatically initialise this module if we're
  testing so we don't have to call it every time.
*/
version (unittest)
{
    shared static this()
    {
        primordial_init(true, true);
    }
}

/**
  Initialise SDL libraries

Params:
    sdl = true    Load SDL2 libs
    ttf = true    Load the SDL ttf libraries for text rendering.
*/
void primordial_init(bool sdl = true, bool ttf = true)
{

    try
    {
        primordial.sdl.sdl_funcs.load_libs(sdl, ttf);

        primordial.sdl.sdl_funcs.init_sdl();
    }
    catch (SDLException)
    {
        return;
    }

    sdl_context = new SDL();

    if (ttf)
        ttf_context = new TTF();
}
