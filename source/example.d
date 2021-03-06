module example;

import core.thread;

import primordial.init;
import primordial.sdl.display;
import primordial.primitives.shapes;
import primordial.defaults : default_screen;
import primordial.colors : red, black;

int main()
{

    primordial.init.primordial_init(true);

    sdl_window window = new sdl_window("Example");

    window.clear(black);

    rectangle r = new rectangle(0, 0, 10, 10, red, window.get_renderer());

    line_rectangle line_r = new line_rectangle(30, 60, 10, 10, red, window.get_renderer());

    line_circle c = new line_circle(50, 50, 20, red, window.get_renderer());

    line_triangle t = new line_triangle(100, 100, 10, 100, red, window.get_renderer());

    text text_line = new text("HELLO WORLD", 100, 100, red, 12, window.get_renderer());

    text_line.render();

    t.render();

    r.render();

    line_r.render();

    c.render();

    window.update();

    Thread.sleep(dur!("seconds")(2));

    return 0;

}
