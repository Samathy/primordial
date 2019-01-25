module example;

import core.thread;

import primordial.init;
import primordial.sdl.display;
import primordial.primitives.shapes;
import primordial.defaults : default_screen;
import primordial.colors : red;

int main()
{

    primordial.init.primordial_init(true);

    sdl_window window = new sdl_window("Example");

    rectangle r = new rectangle(0, 0, 10, 10, red, window.get_renderer());

    line_circle c = new line_circle(50, 50, 20, red, window.get_renderer());

    r.render();

    c.render();

    window.update();

    Thread.sleep(dur!("seconds")(2));

    return 0;

}
