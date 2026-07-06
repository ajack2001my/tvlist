# tvlist v1.0.2

TV List, an HTML generator for keeping track of your favorite show from site EZTVx.to or create a TV series 
search if EZTV does not have a dedicated show page as well as a quick search on some torrent search engines 
if the episode is missing and to also check show statuses on TV websites.

To use, modify the TVLIST.TXT file to add/remove TV series you follow.  Then run TVLIST to generate a 
TVLIST.HTM file that you can then open in your web browser. Some elements can be customized via TVLIST.CFG 
whichshould be self explanatory. 

-----------------------

Update from previous version:

Code has been enhanced (small and too numerous to remember at time of writing this). Some of the changes I do
remember are:

* Added [InDev] tag in TVList.txt as well as color customization in TVList.cfg file.
* Updated Yesmovies.ag search implmentation.
* Restructured source code for easier reading.
* Removed Torrentz2.eu, and TorrentGalaxy Search Engine.
* Added links to subtitle resources (search, convert, extract, translate).
* Changed CUSTOMSEARCH to my own liking.
* Update/removed alternative links list in .cfg file.
* Restructured TVList to show most of it's functions until you hit the TOGGLE button to see actual show list.
* Search for completed seasons (uses keyword COMPLETE). However, not all torrents carry that keyword.
* Updated Bitcoin link to show balance in account.
* Added 150 more quotes making the total quotes 200 (quote number will be shown in square brackets).
* Added a trailer search link to YouTube "[TR]" to see if anything is available outside the show itself.
* Changed subtitle search to opensubtitles.org
* New shows with day set in TVList.txt but no EZTV show path will have a blinking "Search" text.
* Added UIndex, and Ext support.
* Enhanced site status check using official site, or Is It Down Right Now (isitdownrightnow.com) service.
* De-clutter screen by making the Subtitle and Site Status checks into pull-down menus.
* Hard-coded snowfall that appears between 18th and 31st, December.
* Changed day tags from SMTWTFS to sMtWTFS for easier reading.
* Added a TVList_Manual.htm manual.

-----------------------

Free Pascal 3.2.2 was used to compile this source code.  Has been tested in Windows and Linux environments and 
on 32-bit and 64-bit targets.
