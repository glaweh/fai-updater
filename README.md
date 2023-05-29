First the legal stuff:
I put this code under the GPLv2, as you can find it in the LICENSE file
in the root directory of the distribution.

Screenshots:
Normal view (Unreachable hosts are laptops not in office or VMs switched off)
![fai-updater](https://github.com/glaweh/fai-updater/assets/516503/6e4227d8-9069-408c-8063-0401c44a6bc0)

View with Log subwindow (the ``fai softupdate`` stdout is displayed in the lower window, and updated as soon as new data arrives)
![fai-updater-with-log](https://github.com/glaweh/fai-updater/assets/516503/df17f8d1-ba7f-476f-8536-2d8f7eceb656)


Now a word to the needed packages:
for the frontend, you need the Curses::UI perl module, in Debian you get
it via

apt-get install libcurses-ui-perl


On the client side, fai-client is needed and of course a FAI configuration
which is update-safe.

I know the code is quite rough, as though I tried programming cleanly, a
lot of hacks have slipped in, and I don't have the time to clean up the
code right now due to my diploma thesis' deadline ;)

If you have any questions or suggestions, feel free to write me.

Henning Glawe <glaweh@debian.org>
