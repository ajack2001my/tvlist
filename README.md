# tvlist v0.9.7

TV List, an HTML generator for keeping track of your favorite show from EZTV.re or create a TV series search 
if EZTV does not have a dedicated show page as well as a quick search on some torrent search engines if the 
episode is missing and to also check show statuses on TV websites.

To use, modify the TVLIST.TXT file to add/remove TV series you follow.  Then run TVLIST to generate a 
TVLIST.HTM file that you can then open in your web browser. Some elements can be customized via TVLIST.CFG which
should be self explanatory. 

-----------------------

Update from previous version:

Code has been enhanced (small and too numerous to remember at time of writing this. Some of the changes I do
remember are:

> I've also updated/removed some of the URLs to support your search/download efforts. 
> Font names can now be more than one word. Use the '\' character instead of ' ' in the name, so the font
    name "New Times Roman" will be labelled "New\Times\Roman" in the configuration (see tvlist.cfg file).
> Added help on what to do if your DNS services provided by your provider is blocking sites.
> Added help when you want to do "EZTV Quick Checks" and your browser doesn't open all the tabs.
> Can now check the EZTV site for newly listed shows.

-----------------------

Free Pascal 3.0.2 was used to compile this source code.  Has been tested in Windows and Linux environments and 
on 32-bit and 64-bit targets.
