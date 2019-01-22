module primordial.init;

import std.stdio;

import primordial.sdl.sdl_funcs;

import blerp.blerp;

public SDL sdl_context = null;
public TTF ttf_context = null;

version(unittest)
{
    shared static this()
    {
        primordial_init(true, true);
    }
}


///Initialise SDL libraries
void primordial_init(bool sdl=true, bool ttf=true)
{
    
    try
    {
        primordial.sdl.sdl_funcs.load_libs(sdl,ttf);

        primordial.sdl.sdl_funcs.init_sdl();
    }
    catch (SDLException)
    {
        return;
    }

    sdl_context = new SDL();

    if(ttf)
        ttf_context = new TTF();
}
