# tvlist v1.0

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

* Long display names can be truncated by the '=' character.
* The search results in some search engines are now sorted by time (easier to find latest releases).
* Updated/removed search engine URLs (removed Torrenz2, updated yesmovies)
* Update alternative links list in .cfg file
* Added a subtitle translation service URL.
* Added countdown from date to today for starting/returning shows.  Using the [YYYYMMDD] format, please see .txt for examples.
* Now TVList requires a javascript capable browser to use all features.
* Added additional quotes (now up to 50).
* Cleaned up the code and make (hopefully) useful comments and descriptions in the source.
* Improved the HTML refresh META code, will only be embedded in HTML if user defined a refresh value.

-----------------------

Free Pascal 3.2.2 was used to compile this source code.  Has been tested in Windows and Linux environments and 
on 32-bit and 64-bit targets.
