module primordial.models.container;

import primordial.primitives.shapes;
import primordial.models.component;

/**Model  containers contain a bunch of renderable objects.
  Each object should have it's x and y set to 0, and give the model container a function to change it's x & y in relation to the model's x & y.
  When the render() method of the model is called, the update x&y method is called on each component
  */

///Contains all the renderable objects that make up a model
class model_container
{

    this(string name, int x, int y, int z)
    {
        this.name = name;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public void addComponent(model_component renderable_component)
    {
        this.components ~= renderable_component;
    }

    //Get rid of part of the model
    public void removeComponent()
    {

    }

    void render()
    {
        foreach (component; this.components)
        {
            component.updatePosition(this.x, this.y);
            component.render();
        }
    }

    int getz()
    {
        return this.z;
    }

    string getname()
    {
        return this.name;
    }

    private
    {
        int x;
        int y;
        int z;

        string name;

        model_component[] components;
    }
}

version (interactive)
{
    unittest
    {

        import core.thread;

        import primordial.sdl.display;
        import primordial.sdl.sdl_funcs;
        import primordial.models.component;
        import primordial.colors : red;

        sdl_window main_window = new sdl_window("Example");

        rectangle r = new rectangle(0, 0, 10, 10, red, main_window.get_renderer());

        line l = new line(0, 0, 10, 10, red, main_window.get_renderer());

        model_component line_c = new model_component(l, function(int x, int y,
                renderable_abstract_object renderable) {
            renderable.setx(x);
            renderable.sety(y);
        });

        model_component rect_c = new model_component(r, function(int x, int y,
                renderable_abstract_object renderable) {
            renderable = renderable;
            renderable.setx(x - (x / 2));
            renderable.sety(y);
        });

        model_container model = new model_container("Test model", 10, 10, 0);

        model.addComponent(line_c);
        model.addComponent(rect_c);

        assert(l.getx() == 0);
        assert(l.gety() == 0);

        assert(r.getx() == 0);
        assert(r.gety() == 0);

        model.render();
        main_window.update();

        main_window.clear();

        model.x = 30;
        model.y = 30;

        model.render();
        main_window.update();

        assert(l.getx() == 30);
        assert(l.gety() == 30);

        assert(r.getx() == (30 - (30 / 2)));
        assert(r.gety() == 30);

        Thread.sleep(dur!("seconds")(4));

    }
}

///Like the normal model container, except all renderables are named.
class keyword_model_container : model_container
{

    this(string name, int x, int y, int z)
    {
        super(name, x, y, z);
    }

    ///Add a named renderable
    template addNamedComponent(renderable_type)
    {
        public void addNamedComponent(model_component!(renderable_type) renderable_component,
                string name)
        {
            this.components[name] = renderable_component;

            ///Should also add the renderable to the tail of the renderables list.
        }
    }

    private
    {
        model_component[string] components;
    }

}
