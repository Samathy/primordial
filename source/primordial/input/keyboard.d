module primordial.input.keyboard;

import std.concurrency;
import core.time : msecs;
import std.stdio;

import derelict.sdl2.sdl;

import primordial.sdl.display;

/**
  Listens for keypresses and reports them when asked.
*/
class sdl_event_listener
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
        If there has been a key pressed since the last call, return it.
        Returns: SDL_Keycode    The key pressed.
    */
    SDL_Keycode getLastKey()
    {
        receiveTimeout(msecs(0), (SDL_Keycode keycode) {
            this.last = keycode;
            this.newEvent = true;
        });

        if (this.newEvent)
        {
            return this.last;
        }
        else
        {
            return 0;
        }
    }

    /**
       Clear the recent events.
       MUST be called straight after successfully getting a keypress, or before calling it next time.
    */
    public void clearEvents()
    {
        this.last = 0;
        this.newEvent = false;
    }

    /**
        Starts a task to listen for key presses
    */
    void listen()
    {
        this.listenerTid = spawn(&this.keysymlistener, thisTid);
    }

    void callback_on(SDL_Keycode key, void function() f)
    {
        //TODO

        /* 
           Listner thread should check for whenever a key comes up with a 
           call back on it and then ask the owner thread to make the callback
        */
    }

    /**
        Tell our keypress listener to shutdown.
    */
    void sendShutdown()
    {
        send(this.listenerTid, true);
    }

    private
    {
        shared SDL_Keycode last;

        bool newEvent = false;

        Tid listenerTid;

        static void keysymlistener(Tid ownerTid)
        {
            SDL_Event e;
            bool shutdown = false;

            while (!shutdown)
            {
                //First argument MUST be a time, cannot be an int.
                receiveTimeout(msecs(0), (bool sig) { shutdown = sig; });

                while (SDL_PollEvent(&e) != 0)
                {
                    if (e.type == SDL_KEYDOWN)
                    {
                        send(ownerTid, e.key.keysym.sym);
                    }

                    //TODO support different events, not just keydown
                }
            }
        }

    }

}

version (interactive)
{
    unittest
    {
        //TODO Update dub.json with a rule to exclude this
        // if we're not doing integration tests
        int quit = 0;
        sdl_window main_window = new sdl_window("example");
        sdl_event_listener listner = new sdl_event_listener(main_window);

        listner.listen();

        while (listner.getLastKey() != SDLK_q)
        {
            if (quit >= 100000000)
            {
                assert(false);
            }
        }

        listner.sendShutdown();

        assert(true);
    }
}
