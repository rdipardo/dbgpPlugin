DBGP Notepad++ plugin
=====================

Status
------

After a [request from the Notepad++ community][0], this project was created to reboot development of DBGp.
The original plugin is [abandonware][1]. The author now maintains a [VS Code extension][2] with the same and better functionality.

The goals of this project are to:

* make DBGp's code base available in a clean, organized form, while preserving as much of the original as possible
* upgrade the visual components libraries for compatibility with recent Delphi IDEs
* make the code binary compatible with recent 64-bit versions of Notepad++

There are currently __*no*__ plans to implement new features. Users looking for those will be better served by the [VS Code extension][2].

Configuring Xdebug 3
--------------------

By default, plugin versions >= 0.14 will open a TCP connection on port 9003, the same default port as Xdebug 3: https://xdebug.org/docs/upgrade_guide#Step-Debugging

Older versions will listen on port 9000 by default, the same as Xdebug 2.

For any v3 release of Xdebug, a minimal configuration resembles the following:

    [xdebug]
    xdebug.mode = debug
    xdebug.remote_enable = On

*Note*
The `xdebug.remote_handler` property is obsolete as of version 2.9: https://2.xdebug.org/docs/all_settings#remote_handler

Xdebug 2 can be configured according to the "SERVER SIDE INSTALL" section of [the original README][3], except the port number must be set explicitly:

    [xdebug]
    xdebug.remote_port = 9003

Alternatively, change the plugin's default port by editing the configuration file at `<NPP_PLUGINS_DIRECTORY>\Config\dbgp.ini`:

    [Misc]
    listen_port = 9000

Known Issues
------------

* Re-positioning the debugger panel too many times may cause an infinite redraw loop, hanging Notepad++.
  This could simply be [a race condition][4], or a limitation of the editor's [window management capabilities][5].
  Independent bug reports found [here][6], [here][7] and [here][8] suggest that it's a longstanding problem, and
  not unique to DBGp. See [5b0af29].

* Tooltips are not always destroyed completely, leaving hollow outlines on the screen. See [6560b64].

[0]: https://community.notepad-plus-plus.org/topic/22772/new-cross-platform-plugin-template-for-delphi-developers/3
[1]: https://github.com/zobo/dbgpPlugin/issues/1#issuecomment-770746125
[2]: https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug
[3]: https://bitbucket.org/rdipardo/dbgp/raw/bf0577b6c621063ff1b82d220afcc32eea9c930e/README.orig.txt
[4]: https://community.notepad-plus-plus.org/topic/13116/creating-a-docked-window-from-a-background-thread
[5]: https://github.com/kbilsted/NotepadPlusPlusPluginPack.Net/issues/17#issuecomment-683459898
[6]: https://sourceforge.net/p/notepad-plus/discussion/482781/thread/ab626469
[7]: https://github.com/kbilsted/NotepadPlusPlusPluginPack.Net/issues/17
[8]: https://community.notepad-plus-plus.org/topic/23667/npp-got-stuck-after-rearranging-dialogs
[5b0af29]: https://bitbucket.org/rdipardo/dbgp/commits/5b0af29
[6560b64]: https://bitbucket.org/rdipardo/dbgp/commits/6560b64
