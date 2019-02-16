module primordial.colors;

import derelict.sdl2.sdl : SDL_Color;

import std.random : Random, uniform, unpredictableSeed;

alias color = SDL_Color;

static immutable color red = {255, 0, 0, 255};
static immutable color green = {0, 255, 0, 255};
static immutable color blue = {0, 0, 255, 255};
static immutable color black = {0, 0, 0, 255};
static immutable color white = {255, 255, 255, 255};

/**
  Generate random colours.
*/
static color get_random_color()
{
    auto rnd = new Random(unpredictableSeed);

    color col;

    col.r = cast(ubyte) uniform(0, 255, rnd);
    col.g = cast(ubyte) uniform(0, 255, rnd);
    col.b = cast(ubyte) uniform(0, 255, rnd);
    col.a = cast(ubyte) uniform(0, 255, rnd);

    return col;
}

unittest
{
    for (int i = 0; i < 100; i++)
    {
        color c = get_random_color();

        assert(c.r >= 0);
        assert(c.r <= 255);
        assert(c.g >= 0);
        assert(c.g <= 255);
        assert(c.b >= 0);
        assert(c.b <= 255);
    }

}
