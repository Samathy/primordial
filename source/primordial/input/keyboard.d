module primordial.input.keyboard;

import std.concurrency;
import core.time : msecs;

import derelict.sdl2.sdl;

import primordial.sdl.display;

///Launch a new thread and listen for keypresses
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

    SDL_Keycode getLastKey()
    {
        this.last = receiveOnly!(SDL_Keycode);
        return this.last;
    }

    ///Starts a task to listen for key presses
    void listen()
    {
        this.listenerTid = spawn(&this.keysymlistener, thisTid);
    }

    ///Calls given function when key is pressed
    void callback_on(SDL_Keycode key, void function() f)
    {
        //TODO

        /* 
           Listner thread should check for whenever a key comes up with a 
           call back on it and then ask the owner thread to make the callback
        */
    }

    void sendShutdown()
    {
        send(this.listenerTid, true);
    }

    private
    {
        shared SDL_Keycode last;

        shared bool shutdown = false;

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

unittest
{
    //TODO Update dub.json with a rule to exclude this
    // if we're not doing integration tests
    int quit = 0;
    sdl_event_listener listner = new sdl_event_listener();

    sdl_window main_window = new sdl_window("example");

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
