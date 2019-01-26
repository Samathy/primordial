module primordial.primitives.shapes;

import std.random, std.string, std.stdio;
import std.conv : to;
import std.typecons : Tuple, tuple;
import derelict.sdl2.sdl, derelict.sdl2.ttf;

import primordial.colors;
import primordial.defaults;
import primordial.sdl.sdl_funcs;
import primordial.sdl.display;
import primordial.init;

interface renderable_object
{
    public
    {

        @safe pure nothrow void centered(screen_dimensions s);

        @safe pure nothrow void offset(int offset, char alignment);

        void render();
    }
}

class renderable_abstract_object : renderable_object
{
    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.col = col;
            this.renderer = renderer;
        }

        @safe pure nothrow void centered(screen_dimensions s)
        {
            int new_x;
            int new_y;

            new_y = (s.h - this.height) / 2;
            new_x = (s.w - this.width) / 2;

            this.x = new_x;
            this.y = new_y;

            return;
        }

        @safe pure nothrow void offset(int offset, char alignment)
        {
            if (alignment == 'l')
            {
                this.x += offset;
            }
            else if (alignment == 'r')
            {
                this.x -= offset;
            }

            else if (alignment == 't')
            {
                this.y += offset;
            }
            else if (alignment == 'b')
            {
                this.y -= offset;
            }
        }

        void render()
        {
        }
    }

    private
    {
        int x;
        int y;
        int width;
        int height;
        color col;
        SDL_Renderer* renderer;
    }
}

@("Test renderable_abstract_object")
unittest
{

    auto o = new renderable_abstract_object(10, 10, 50, 50, red, null);
    screen_dimensions screen = {200, 200};

    assert(o.x == 10);
    assert(o.y == 10);
    assert(o.width == 50);
    assert(o.height == 50);

    o.centered(screen);

    assert(o.x == 75);
    assert(o.y == 75);

    o.x = 10;
    o.offset(10, 'r');
    assert(o.x == 10 - 10);

    o.x = 10;
    o.offset(10, 'l');
    assert(o.x == 10 + 10);

    o.y = 10;
    o.offset(10, 't');
    assert(o.y == 10 + 10);

    o.y = 10;
    o.offset(10, 'b');
    assert(o.y == 10 - 10);

}

class rectangle : renderable_abstract_object
{
    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {
            super(x, y, width, height, col, renderer);

            this.create_rect();
        }

        override void render()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.h = this.height;
            this.rect.w = this.width;

            if ((sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.b, this.col.g, this.col.a)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
            if ((sdl_context.RenderFillRect(renderer, &this.rect)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
        }

        @safe nothrow SDL_Rect get_rect()
        {
            update_rect();
            return this.rect;
        }

        @safe nothrow immutable(int) get_width()
        {
            update_rect();
            return immutable(int)(this.width);
        }
    }

    private
    {
        void create_rect()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.w = this.width;
            this.rect.h = this.height;

        }

        @safe nothrow void update_rect()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.h = this.height;
            this.rect.w = this.width;
        }

        SDL_Rect rect;
    }

}

@("Test rectangle class")
unittest
{
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
        writeln(e.msg);
        assert(false);
    }

    color red = {255, 0, 0, 255};

    rectangle rect = new rectangle(0, 0, 120, 120, red, main_window.get_renderer());

    rect.offset(10, 'l');

    assert(rect.get_rect().x == 0 + 10);

    rect.centered(main_window.get_size());

    assert(rect.get_rect().y == (main_window.get_size().h - 120) / 2);
    assert(rect.get_rect().x == (main_window.get_size().w - 120) / 2);

    rect.render();
}

class line_rectangle : rectangle
{

    public
    {
        this(int x, int y, int width, int height, color col, SDL_Renderer* renderer)
        {
            super(x, y, width, height, col, renderer);
        }

        override void render()
        {
            this.rect.x = this.x;
            this.rect.y = this.y;
            this.rect.h = this.height;
            this.rect.w = this.width;

            if ((sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.b, this.col.g, this.col.a)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
            if ((sdl_context.RenderDrawRect(renderer, &this.rect)) < 0)
            {
                throw new SDLException("Could not set render colour: ", to!string(SDL_GetError()));
            }
        }
    }
}

class line : renderable_abstract_object
{

    public
    {
        this(int x, int y, int x2, int y2, color col, SDL_Renderer* renderer)
        {

            super(x, y, 0, 0, col, renderer);

            this.x2 = x2;
            this.y2 = y2;

        }

        override void offset(int offset, char alignment)
        {
            super.offset(offset, alignment);

            if (alignment == 'l')
            {
                this.x2 += offset;
            }
            else if (alignment == 'r')
            {
                this.x2 -= offset;
            }

            else if (alignment == 't')
            {
                this.y2 += offset;
            }
            else if (alignment == 'b')
            {
                this.y2 -= offset;
            }
        }

        override void render()
        {
            sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.g, this.col.b, this.col.a);
            sdl_context.RenderDrawLine(this.renderer, this.x, this.y, this.x2, this.y2);
        }
    }

    private
    {
        int x2;
        int y2;
    }

}

class solid_circle : renderable_abstract_object
{
    public
    {
        this(int x, int y, int radius, color col, SDL_Renderer* renderer)
        {

            super(x, y, 0, 0, col, renderer);

            this.radius = radius;

        }

        override void render()
        {
            sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.g, this.col.b, this.col.a);

            for (int w; w < this.radius * 2; w++)
            {
                for (int h; h < this.radius * 2; h++)
                {
                    int dx = this.radius - w;
                    int dy = this.radius - h;

                    if ((dx * dx + dy * dy) <= (this.radius * this.radius))
                    {
                        sdl_context.RenderDrawPoint(this.renderer, this.x + dx, this.y + dy);
                    }
                }
            }
        }

    }

    private
    {
        int radius;
    }

}

class line_circle : renderable_abstract_object
{
    public
    {
        this(int x, int y, int radius, color col, SDL_Renderer* renderer)
        {

            super(x, y, 0, 0, col, renderer);

            this.radius = radius;

        }

        override void render()
        {
            sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.g, this.col.b, this.col.a);

            int xx = this.radius - 1;
            int yy = 0;
            int dx = 1;
            int dy = 1;
            int diameter = radius * 2;
            int err = dx - diameter;

            while (xx >= yy)
            {
                sdl_context.RenderDrawPoint(this.renderer, this.x + xx, this.y + yy);
                sdl_context.RenderDrawPoint(this.renderer, this.x + yy, this.y + xx);
                sdl_context.RenderDrawPoint(this.renderer, this.x - yy, this.y + xx);
                sdl_context.RenderDrawPoint(this.renderer, this.x - xx, this.y + yy);

                sdl_context.RenderDrawPoint(this.renderer, this.x - xx, this.y - yy);
                sdl_context.RenderDrawPoint(this.renderer, this.x - yy, this.y - xx);
                sdl_context.RenderDrawPoint(this.renderer, this.x + yy, this.y - xx);
                sdl_context.RenderDrawPoint(this.renderer, this.x + xx, this.y - yy);

                if (err <= 0)
                {
                    yy++;
                    err += dy;
                    dy += 2;
                }

                if (err > 0)
                {
                    xx--;
                    dx += 2;
                    err += dx - (diameter);
                }
            }
        }

    }

    private
    {
        int radius;
    }

}

class line_triangle : renderable_abstract_object
{

    public
    {
        this(int x, int y, int base_width, int height, color col, SDL_Renderer* renderer)
        {
            super(x, y, base_width, height, col, renderer);

            this.base_width = base_width;
            this.height = height;

        }

        override void render()
        {
            //These values are all wrong, we also probably need to draw top->left->right?
            SDL_Point top = {this.x, this.y - (this.height / 2)};
            SDL_Point left = {
                this.x - (this.base_width / 2), this.y + (this.height / 2)
            };
            SDL_Point right = {
                this.x + (this.base_width / 2), this.y + (this.height / 2)
            };

            this.points[0] = top;
            this.points[1] = left;
            this.points[2] = right;
            this.points[3] = top;

            sdl_context.SetRenderDrawColor(this.renderer, this.col.r,
                    this.col.g, this.col.b, this.col.a);

            sdl_context.RenderDrawLines(this.renderer, points, cast(ubyte) 4);

        }

    }

    private
    {
        int base_width;
        int height;

        SDL_Point[4] points;
    }
}

unittest
{
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
        writeln(e.msg);
        assert(false);
    }

    color red = {255, 0, 0, 255};

    line_triangle tri = new line_triangle(0, 0, 10, 10, red, main_window.get_renderer());

    assert(tri.x == 0);
    assert(tri.y == 0);

    assert(tri.base_width == 10);
    assert(tri.height == 10);

    tri.render();

    assert(tri.points[0].x == 0);
    assert(tri.points[0].y == -5);
    assert(tri.points[1].x == -5);
    assert(tri.points[1].y == +5);
    assert(tri.points[2].x == +5);
    assert(tri.points[2].y == +5);
    assert(tri.points[3] == tri.points[0]);

}

class text : renderable_abstract_object
{
    public
    {
        this(string text_content, int x, int y, color col, int fontsize,
                SDL_Renderer* renderer, SDL_Rect* clip = null, double angle = 0.0,
                SDL_Point* center = null, SDL_RendererFlip flip = SDL_FLIP_NONE)
        {

            super(x, y, 0, 0, col, renderer);

            this.clip = clip;
            this.angle = angle;
            this.flip = flip;
            this.font_size = fontsize;

            this.font = ttf_context.OpenFont("/usr/share/fonts/TTF/FreeMonoBold.ttf", this.font_size);

            load_rendered_text(text_content);
        }

        ~this()
        {
            sdl_context.FreeSurface(this.text_surface);
            sdl_context.DestroyTexture(this.texture);
        }

        void load_rendered_text(string text, color text_color = black)
        {
            this.text_surface = ttf_context.RenderText_Solid(this.font, toStringz(text), text_color);

            this.texture = sdl_context.CreateTextureFromSurface(this.renderer, this.text_surface);

            this.width = text_surface.w;
            this.height = text_surface.h;
        }

        override void render()
        {
            SDL_Rect texture_space = {this.x, this.y, this.width, this.height};

            if (clip)
            {
                texture_space.w = this.clip.w;
                texture_space.h = this.clip.h;
            }

            sdl_context.RenderCopyEx(this.renderer, this.texture, this.clip,
                    &texture_space, this.angle, this.center, this.flip);
        }

        @safe pure nothrow immutable(int) get_x()
        {
            return immutable(int)(this.x);
        }

        @safe pure nothrow immutable(int) get_y()
        {
            return immutable(int)(this.y);
        }

        @safe pure nothrow immutable(int) get_width()
        {
            return immutable(int)(this.width);
        }

        @safe pure nothrow immutable(int) get_height()
        {
            return immutable(int)(this.height);
        }
    }

    private
    {
        SDL_Surface* text_surface;
        SDL_Texture* texture;
        SDL_Rect* clip;
        SDL_Point* center;
        SDL_RendererFlip flip = SDL_FLIP_NONE;
        TTF_Font* font;

        int font_size;
        double angle;
    }
}

@("Test text class")
unittest
{


    sdl_window main_window;
    try
    {
        main_window = new sdl_window("flatmap", 640, 480);
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

    color red = {255, 0, 0, 255};

    text t = new text("hello", 20, 2, red, 28, main_window.get_renderer());

    t.offset(10, 'r');
    assert(t.get_x() == 20 - 10);

    t.offset(10, 't');
    assert(t.get_y() == 2 + 10);

    t.render();

}

class key
{

    public
    {
        this(screen_dimensions dimensions, SDL_Renderer* renderer,
                bool show_text = true, int fontsize = 16)
        {
            this.font_size = fontsize;
            this.renderer = renderer;
            this.dimensions = dimensions;
            this.show_text = show_text;
            this.y_offset = 0;
        }

        ~this()
        {
            foreach (entry; this.entries)
            {
                destroy(entry.rendered_text);
                destroy(entry.rect);
            }
        }

        void offset(int offset, char alignment)
        {
            switch (alignment)
            {
            case 't':
                this.y_offset = offset;
                break;
            default:
                throw new Exception("ENOTIMPL");
            }
        }

        void add(color col, string label)
        {

            if (search_for_label(label))
            {
                label = label ~ "_" ~ to!string(search_for_label(label));
            }

            entries ~= tuple!("color", "label", "rect", "rendered_text", "offset_calculated")(col,
                    label, cast(rectangle) null, cast(text) null, false);
        }

        void remove(string label)
        {
        }

        void render()
        {
            int y_position = 0 + this.y_offset;

            int longest_label;
            int tallest_label;

            foreach (ref entry; this.entries)
            {
                if (entry.rect is null)
                {
                    entry.rect = this.create_rectangle(entry.color);
                }

                if (entry.rendered_text is null && this.show_text)
                {
                    entry.rendered_text = this.create_text(entry.label);
                }
            }

            if (this.show_text)
            {
                longest_label = this.find_longest_label();
                tallest_label = this.find_tallest_label();
            }

            foreach (ref entry; this.entries)
            {
                if (!entry.offset_calculated)
                {
                    if (this.show_text)
                    {
                        entry.rendered_text.offset(entry.rendered_text.get_width() + this.margin,
                                'r');
                        entry.rendered_text.offset(y_position + tallest_label, 't');
                    }
                    entry.rect.offset(longest_label + entry.rect.get_width() + this.margin, 'r');
                    entry.rect.offset(y_position + tallest_label, 't');

                    entry.offset_calculated = true;
                }

                if (this.show_text)
                {
                    entry.rendered_text.render();
                }
                entry.rect.render();
                y_position += tallest_label + this.margin;
            }
        }

    }

    private
    {
        int search_for_label(string label)
        {
            int similar_labels;

            foreach (entry; entries)
            {
                string entry_label = entry.label;

                int i;
                while (entry_label[$ - i .. $].isNumeric())
                {
                    i++;
                }

                if (i > 0)
                    entry_label = entry_label[$ - i .. $];

                if (entry_label == label)
                    similar_labels++;
            }
            return similar_labels;
        }

        unittest
        {
            /*If we have numbers at the end of the labels, theres a good
             * chance that the de-duplication logic will will not give us what
             * we wanted.
             */

            screen_dimensions s = {640, 480};
            auto main_window = new sdl_window("", 0, 0, 640, 480);
            auto k = new key(s, main_window.get_renderer());

            //set to enable printing the labels
            static immutable bool enable_print = false;

            auto print_all = delegate() {
                static if (enable_print)
                {
                    writeln("----------");
                    foreach (entry; k.entries)
                        writeln(entry.label);
                }
            };

            k.add(red, "hello");

            assert(k.entries[0].label == "hello");

            k.add(red, "hello");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");

            k.add(red, "hello200");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");
            assert(k.entries[2].label == "hello200");

            k.add(red, "hello200");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");
            assert(k.entries[2].label == "hello200");
            assert(k.entries[3].label == "hello200_1");

            k.add(red, "1hello");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");
            assert(k.entries[2].label == "hello200");
            assert(k.entries[3].label == "hello200_1");
            assert(k.entries[4].label == "1hello");

            k.add(red, "hello1");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");
            assert(k.entries[2].label == "hello200");
            assert(k.entries[3].label == "hello200_1");
            assert(k.entries[4].label == "1hello");
            assert(k.entries[5].label == "hello1");

            k.add(red, "hello1");
            print_all();
            assert(k.entries[0].label == "hello");
            assert(k.entries[1].label == "hello_1");
            assert(k.entries[2].label == "hello200");
            assert(k.entries[3].label == "hello200_1");
            assert(k.entries[4].label == "1hello");
            assert(k.entries[5].label == "hello1");
            assert(k.entries[6].label == "hello1_1");

        }

        rectangle create_rectangle(color col)
        {
            return new rectangle(this.dimensions.w, 0, 50, this.font_size, col, this.renderer);
        }

        text create_text(string label)
        {
            return new text(label, dimensions.w, 0, black, this.font_size, this.renderer);
        }

        int find_longest_label()
        {
            int longest_label;

            foreach (entry; this.entries)
            {
                if (entry.rendered_text.get_width() > longest_label)
                {
                    longest_label = entry.rendered_text.get_width();
                }
            }

            return longest_label;
        }

        int find_tallest_label()
        {
            int tallest_label;

            foreach (entry; this.entries)
            {
                if (entry.rendered_text.get_height() > tallest_label)
                {
                    tallest_label = entry.rendered_text.get_height();
                }
            }

            return tallest_label;
        }

        Tuple!(color, "color", string, "label", rectangle, "rect", text,
                "rendered_text", bool, "offset_calculated")[] entries;
        screen_dimensions dimensions;
        SDL_Renderer* renderer;

        bool show_text = true;

        int margin = 5;
        int font_size;
        int y_offset;
    }
}

class scale
{
    public
    {
        this(int x, int y, int length, int tic_distance, int multiplier,
                bool tic_labels, color col, SDL_Renderer* renderer)
        {
            this.x = x;
            this.y = y;
            this.thickness = thickness;
            this.length = length;
            this.col = col;
            this.renderer = renderer;

            create_tics(tic_distance, multiplier, tic_labels);

            this.xline = new line(this.x, this.y, this.length, this.y, this.col, this.renderer);
        }

        ~this()
        {
            foreach (t; this.tics)
            {
                destroy(t);
            }

            foreach (l; this.labels)
            {
                destroy(l);
            }

            destroy(this.xline);
        }

        void offset(int offset, char alignment)
        {

            auto update_tics = delegate void{
                foreach (tic; this.tics)
                {
                    tic.offset(offset, alignment);
                }
            };
            auto update_labels = delegate void{
                foreach (label; this.labels)
                {
                    label.offset(offset, alignment);
                }
            };

            switch (alignment)
            {
            case 'l':
                this.x += offset;
                break;
            case 'r':
                this.x -= offset;
                break;
            default:
                throw new Exception("ENOTIMPL");
            }

            update_tics();
            update_labels();
        }

        void render()
        {

            foreach (tic; this.tics)
            {
                tic.render();
            }

            foreach (label; this.labels)
                label.render();

            this.xline.render();
        }

    }
    private
    {

        void create_tics(int tic_distance, int multiplier, bool tic_labels)
        {
            for (int i = this.x; i < this.length; i += tic_distance * multiplier)
            {
                this.tics ~= new line(i, this.y, i, this.y - 10, this.col, this.renderer);

                if (tic_labels)
                {
                    this.labels ~= new text(to!string(i / multiplier), i,
                            this.y + 5, this.col, 10, this.renderer);
                }
            }

        }

        text[] labels;
        line[] tics;
        line xline;

        int x;
        int y;
        int thickness;
        int length;
        color col;
        SDL_Renderer* renderer;
    }
}

