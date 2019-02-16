module primordial.input.mouse;

import std.concurrency;
import core.time : msecs;

import derelict.sdl2.sdl;

import primordial.sdl.display;

enum MOUSE
{
    MOTIONEVENT,
    BUTTONDOWN,
    BUTTONUP
}

/**
    Listen for mouse inputs and report them when asked.
*/
class sdl_mouse_listener
{
    this(sdl_window window)
    {
        //If no sdl window is provided, get upset.
        //Because if we try to listen for events with no window then we'll
        //loop forever!
    }

    ~this()
    {
        sendShutdown();
    }

    /**
        Returns: int[2]    The mouse location.
    */
    int[2] getMouseLocation()
    {
        int[2] locations;

        SDL_GetMouseState(&locations[0], &locations[1]);

        this.mousex = locations[0];
        this.mousey = locations[1];

        return locations;
    }

    bool clicked()
    {
        bool mouseClicked = false;
        receiveTimeout(msecs(0), (bool clicked) { mouseClicked = clicked; });

        return mouseClicked;
    }

    /*
    bool mousedown()
    {
        bool down = false;
        receiveTimeout(msecs(0), (SDL_MOUSEBUTTONDOWN mousedown) {down = true;});

        return down;
    }

    bool mouseup()
    {
        bool up = false;
        receiveTimeout(msecs(0), (SDL_MOUSEBUTTONUP mousedown) {up = true;});

        return up;
    }

    */

    void listen()
    {
        this.listenerTid = spawn(&this.mouselistener, thisTid);
    }

    void sendShutdown()
    {
        send(this.listenerTid, true);
    }

    private
    {
        /*
        shared SDL_MOUSEMOTION lastMotion;
        shared SDL_MOUSEBUTTONDOWN lastButtonDown;
        shared SDL_MOUSEBUTTONUP lastButtonUp;
        */

        int mousex;
        int mousey;

        Tid listenerTid;

        static void mouselistener(Tid ownderTid)
        {
            SDL_Event e;
            bool shutdown = false;
            bool down = true;

            while (!shutdown)
            {
                receiveTimeout(msecs(0), (bool sig) { shutdown = sig; });

                while (SDL_PollEvent(&e) != 0)
                {
                    if (e.type == SDL_MOUSEMOTION)
                    {
                        send(ownerTid, MOUSE.MOTIONEVENT);
                    }

                    if (e.type == SDL_MOUSEBUTTONDOWN)
                    {
                        down = true;
                        //send(ownerTid, MOUSE.BUTTONDOWN);
                    }

                    if (e.type == SDL_MOUSEBUTTONUP && down == true)
                    {
                        down = false;
                        //send(ownerTid, SDL_MOUSEBUTTONUP);
                        send(ownerTid, true);
                    }
                }
            }
        }
    }
}

version (interactive)
{
    unittest
    {

        import core.thread;

        import primordial.primitives.shapes;
        import primordial.colors : red;

        //TODO Update dub.json with a rule to exclude this
        // if we're not doing integration tests
        int quit = 0;
        sdl_window main_window = new sdl_window("example");
        sdl_mouse_listener listener = new sdl_mouse_listener(main_window);

        solid_circle c = new solid_circle(100, 100, 30, red, main_window.get_renderer());

        listener.listen();

        c.render();

        main_window.update();

        while (!listener.clicked())
        {
            if (quit >= 100000000)
            {
                assert(false);
            }
        }

        import std.stdio;

        listener.getMouseLocation();
        listener.sendShutdown(); //Must shutdown the listener early

        assert(listener.mousex > 100 - 30);
        assert(listener.mousex < 100 + 30);
        assert(listener.mousey > 100 - 30);
        assert(listener.mousey < 100 + 30);

        Thread.sleep(dur!("seconds")(1));

    }
}
