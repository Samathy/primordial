module primordial.models.component;

import primordial.primitives.shapes;

/**
    Contains a component of a model.
*/
class model_component
{
    this(renderable_abstract_object renderable, void function(int, int,
            renderable_abstract_object) update_x_y)
    {
        this.renderable = renderable;
        this.update = update_x_y;
    }

    /**
        Render the encapsulated renderable object
    */
    void render()
    {
        this.renderable.render();
    }
    
    /**
        Update the encapsulated renderable object's position.
    */
    void updatePosition(int x, int y)
    {
        this.update(x, y, this.renderable);
    }

    /** 
       Returns: The encapsulated renderable object (note: Does not return copy, but the actual object)
    */
    renderable_abstract_object get_renderable()
    {
        return this.renderable;
    }

    private
    {
        renderable_abstract_object renderable;
        void function(int, int, renderable_abstract_object) update;
    }
}

version (interactive)
{
    unittest
    {
        import core.thread;

        import primordial.sdl.display;
        import primordial.primitives.shapes;
        import primordial.colors : red;

        sdl_window main_window = new sdl_window("Example");
        rectangle r = new rectangle(0, 0, 10, 10, red, main_window.get_renderer());
        model_component c = new model_component(new rectangle(0, 0, 10, 10, red,
                main_window.get_renderer()), function(int x, int y,
                renderable_abstract_object renderable) {
            renderable = cast(rectangle) renderable;
            renderable.setx(x + 10);
            renderable.sety(y);
        });
        r.render();

        c.updatePosition(0, 0);
        c.render();

        main_window.update();

        Thread.sleep(dur!("seconds")(1));
    }
}
