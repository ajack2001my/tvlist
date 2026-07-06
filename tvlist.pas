{*

TVList $ProgVer$

An HTML generator for keeping track of your favorite shows from EZTV or create a TV series search if EZTV does not have a dedicated
show page as well as a quick search of various torrent search engines if episode is missing and check show status on various TV sites.

Developed by Adrian Chiang in 2015, last updated on $ProgDate$.

===================================================================================
LEGALESSE

This source code is public domain.  The coder is not liable for anything
whatsoever.  The only guarantee it has is that it will take up storage space in
your computer.  Oh! It would be nice if you gave me credit if you use this source
code (in whole or in part).
===================================================================================

CSS Highlight code adapted from
  URL http://www.java2s.com/Tutorials/HTML_CSS/Table/Style/Highlight_both_column_and_row_on_hover_in_CSS_only_in_HTML_and_CSS.htm
  
Days Countdown code adapted from 
  URL http://hilios.github.io/jQuery.countdown/examples/multiple-instances.html
  Uses the following libraries:
    * jQuery JavaScript Library v1.11.1 (http://jquery.com/)
	* The Final Countdown for jQuery v2.2.0 (http://hilios.github.io/jQuery.countdown/)
  Thanks to Christopher Chua for HOWTO to embed this.

*}

{$IFDEF MSWINDOWS}
  {$R tvlist.rc}
{$ENDIF}

{$DEFINE EASTEREGG1}
{$DEFINE EASTEREGG2}
{$DEFINE CHRISTMAS}
{$DEFINE DNSHELP8888}
{$DEFINE BROWSERHELP}
{$DEFINE ANIMESEARCH}
{$DEFINE TOGGLETABLE}
{$DEFINE CUSTOMSEARCH}


PROGRAM TVList;

USES
  CRT,
  DOS,
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

CONST
  ProgName        = 'TVList';
  ProgVer         = 'v1.0.2';
  ProgDate        = '20260706';

  HTMLSpace       = '&nbsp;';
  HTMLOpenSB      = '&#91;';
  HTMLCloseSB     = '&#93;';
  
{$IFDEF CUSTOMSEARCH}
  CustomText      = '&#9679;';
  CustomColor     = '#8FF00FF';
{$ENDIF}
  

  ProgAuthor      = 'Adrian Chiang';
  ProgDesc        = 'An EZTV Series Manager';
{
My Bitcoin wallet ID, please don't change it.
}
  MyBitCoin       = '1FSMJRMk65o25frAsBoMYoZEZMkqncQ4Jm';

  CTime           = {$I %TIME%};
  CDate           = {$I %DATE%};

  EZTVPageMax     = 512;

  LL1             = '$' + ProgName + '(';
  LL2             = ') took ';
  LL3             = ' second(s) to generate HTML...';

  Desc_Show       = 'Name of the show';
  Desc_EZTV       = 'Go to EZTV''s show info page or search the EZTV database for similar name episodes.';
  Desc_Search     = 'Search torrent engines for show if not found in EZTV.';
  Desc_TVProfiles = 'Show sites with status of show, cast, dates.';
  Desc_TVNews     = 'News of shows, viewer feedback, ratings, etc.';
  Desc_Online     = 'Watch show online instead of downloading/torrenting.';
  Desc_Airs       = 'Show status or countdown to start/return. The day show airs, between seasons, mid-season break, ended or unknown.';
  Desc_General    = 'Search in Google for your TV dramas.';
  Desc_DNS8888    = 'Click to learn how to change the DNS address to your own choosing.';
  Desc_EZTVStatus = 'Check status of EZTV servers.';
  Desc_Firefox2   = 'In ''about:config'', change ''dom.block_multiple_popups'' to ''false''';
  Desc_Chrome2    = 'Chrome will alert you with a ''Pop-ups were blocked on this page'' icon, click the icon ' +
                    'and select ''Always allow pop-ups and redirects...''';
  Desc_Opera2     = 'Opera will alert you with a ''Pop-up blocked'' icon, click the icon and select ''Always allow pop-ups from...''';
  
  URL_TVList_Source  = 'https://www.github.com/ajack2001my/tvlist';
  URL_HOWTO_DNS      = 'https://www.howtogeek.com/167533/the-ultimate-guide-to-changing-your-dns-server/';


  TDStr         = '<TD ALIGN="CENTER">';
  TDStrAlt      = '<TD ALIGN="CENTER" STYLE="color:#FFFF00">';
  
  AnimeHiragana = '&#x30a2;&#x30cb;&#x30e1;';
  AnimeFlag     = '^';
  
  TruncFlag     = '=';
  CountFlag     = '>';


  TVListLnkSize = 21;
  NewIconHeight = 10;

  TVListPNGB64_1 = 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTU';
  TVListPNGB64_2 = 'UH4QoZCikZW9fQzgAAAKRJREFUOMutktENwyAMRO88awZBjJERkgW63fWjMXKKQ4haJIsEfKdnYwLCs0UBov/ZL+KBATUjHhiIZ5NcDAAc';
  TVListPNGB64_3 = '98BNcnEw4NNONlJz8bZhlYSrWBa8MkLiqEG6hyD7SiyKSbaIAt89z6m6V4gJs2s4SJJAsjPcd66N7pMnZCRZzdGQ5JnABWaGWmvXk5gXz3';
  TVListPNGB64_4 = 'RQyL89SintLrv3CdM3+uwT/mUS3xRgd123Bf8bAAAAAElFTkSuQmCC';

  MonthName : Array [1..12] of String = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
  DayName   : Array [0..6]  of String = ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                                         'Thursday', 'Friday', 'Saturday');

VAR
  S,
  T                 : Text;
  LineCount,
  V,
  I                 : Word;
  TempPath,
  RString,
  TVListString,
  TVList_Data,
  TVList_HTML,
  TVList_Config,
  HTML_RefreshRate,
  __DisplayHighlight,
  Highlight_BGColor,
  HTML_FontName,
  Header_Color,
  Header_BGColor,
  CSS_Link_Color,
  CSS_VLink_Color,
  Line1_BGColor,
  Line2_BGColor,
  ComText_Color,
  ComText,
  ShowDay,
  StatusNewShow,
  StatusUnknown,
  StatusEnded,
  StatusBreak,
  StatusRunning,
  StatusInDev,
  AnimeXlateGroup,
  Countdown,
  L1,
  L2,
  L3,
  W,
  XN,
  XNN,
  XL                : String;
  xHo,
  xMi,
  xSe,
  xuSe,
  xYe,
  xMo,
  xDa,
  xuDa              : Word;
  xStart,
  xEnd              : QWord;
  xDiff             : Real;
  LinkURL,
  URL               : Array[1..TVListLnkSize] of String;
  DisplayHighlight  : Boolean = True;
  TK,
  EZTVPage          : Array [1..EZTVPageMax] of String;
  EZTVDay           : Array [1..EZTVPageMax] of Char;
  EZTVPageCount     : Word;
  Base64New         : Array [1..63] of String;
  FancyShow         : Boolean;

{$I tvlist-js.pas}
{$I tvlist-css.pas}

FUNCTION RandomStr (X: Byte): String;
CONST
  Charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
VAR
  i: Byte;
  Result : String;
BEGIN
  Result := '';
  Randomize;
  FOR i := 1 TO X DO
    Result := Result + Charset[Random(Length(Charset)) + 1];
  RandomStr := Result;	
END;

FUNCTION UpStr(I: String): String;
VAR
  J : Word;
BEGIN
  FOR J := 1 TO Length(I) DO
    I[J] := UpCase (I[J]);
  UpStr := I;
END;


{
Initialise variables used with DEFAULT values before then get replaced by the (.cfg) configuration file. 
}
PROCEDURE VARInit;
VAR
  C : Text;
  X,
  _FancyShowFlag : String;
  PROCEDURE _UpdateVAR (VAR N: String; S, R: String);
  VAR
    P : String;
	I : Word;
  BEGIN
    P := R;
	IF (Pos('=', P) < 1) OR (Pos('= ', P) > 0) THEN
	  BEGIN
	    N := '';
		EXIT;
	  END;
	WHILE (P[1] = ' ') AND (Length(P) > 1) DO
	  Delete (P, 1, 1);
    Delete (P, 1, Length(S) + 1);
	I := Pos(' ', P);
	IF I > 1 THEN
	  Delete (P, I, (Length(P) - I) + 1);

    {
	Allow SPACE in names by replacing the '\' character.
	}
	FOR I := 1 TO Length(P) DO 
      IF P[I] = '\' THEN
        P[I] := ' ';	  

    N := P;
  END;
BEGIN
  
{$I tvlist-pg.pas}

  RString := '';
  RString := RandomStr(16) + '-';
  EZTVPageCount := 0;

  URL[ 1] := 'https://eztvx.to';                           {URL_EZTV}
  URL[ 2] := 'https://thepiratebay.org';                   {URL_ThePirateBay}
  URL[ 3] := 'http://www.tv.com';
  URL[ 4] := 'http://variety.com';
  URL[ 5] := 'http://tvline.com';
  URL[ 6] := 'https://yesmovies.ag';                       {URL_YesMovies}
  URL[ 7] := 'https://tvseriesfinale.com';
  URL[ 8] := 'https://nyaa.si';                            {URL_Nyaa}
  URL[ 9] := 'https://limetorrents.cc';                    {URL_LimeTorrent}
  URL[10] := 'https://next-episode.net';                   {URL_NextEpisode}          
  URL[11] := 'http://eztvstatus.com';
  URL[12] := 'https://www.youtube.com';                    {URL_YouTube}
  URL[13] := 'http://1337x.to';                            {URL_1337x}
  URL[14] := 'https://www.google.com';                     {URL_Google}
  URL[15] := 'http://www.returndates.com';
  URL[16] := 'https://ext.to';                             {URL_Ext}

  URL[17] := 'https://www.syedgakbar.com/projects/dst';    
  URL[18] := 'https://downsub.com/';
  URL[19] := 'https://subtitletools.com/convert-to-srt-online';  
  
  URL[20] := 'https://www.opensubtitles.org';
  URL[21] := 'https://uindex.org';      {URL_UIndex}
  
  
  FancyShow          := False;
  HTML_FontName      := 'Calibri';
  Header_Color       := '"#FFFFFF"';
  Header_BGColor     := '"#000000"';
  CSS_Link_Color     := '#000';
  CSS_VLink_Color    := '#777';
  Line1_BGColor      := '"#FFFFFF"';
  Line2_BGColor      := '"#D0D0D0"';
  ComText_Color      := '"#FF0000"';
  Highlight_BGColor  := '#FF0';
  HTML_RefreshRate   := '';
  __DisplayHighlight := '';
  DisplayHighlight   := True;
  StatusBreak        := '"#00EE00"';
  StatusEnded        := '"#CC0000"';
  StatusUnknown      := '"#FFA500"';
  StatusRunning      := '"#000000"';
  StatusInDev        := '"#0000FF"';
  StatusNewShow      := '"#000000"';
  AnimeXlateGroup    := '';

  IF FileExists (TVList_Config) THEN
    BEGIN
	  Assign (C, TVList_Config);
	  Reset (C);
	    WHILE NOT Eof(C) DO
		  BEGIN
		    ReadLn (C, X);
			IF (X[1] <> '#') THEN
			  BEGIN
			    IF Pos('FANCYSHOW=', UpStr(X)) > 0 THEN
			      BEGIN
			        _UpdateVAR (_FancyShowFlag, 'FancyShow', X);
			        IF UpCase(_FancyShowFlag[1]) = 'Y' THEN
		              FancyShow := True;
			      END;
     			IF Pos ('Highlight=', X) > 0 THEN
				  BEGIN
 	    		    _UpdateVAR (__DisplayHighlight, 'Highlight', X);
					IF UpCase(__DisplayHighlight[1]) = 'Y' THEN
					  DisplayHighlight := True
					ELSE
					  DisplayHighlight := False;
				  END;

    			IF Pos ('HTML_RefreshRate=', X) > 0 THEN
	    		  _UpdateVAR (HTML_RefreshRate, 'HTML_RefreshRate', X);
    			IF Pos ('URL_YesMovies=', X) > 0 THEN
	    		  _UpdateVAR (URL[6], 'URL_YesMovies', X);
    			IF Pos ('URL_EZTV=', X) > 0 THEN
	    		  _UpdateVAR (URL[1], 'URL_EZTV', X);
    			IF Pos ('URL_Google=', X) > 0 THEN
	    		  _UpdateVAR (URL[14], 'URL_Google', X);
    			IF Pos ('URL_ThePirateBay=', X) > 0 THEN
	    		  _UpdateVAR (URL[2], 'URL_ThePirateBay', X);
    			IF Pos ('URL_KickAssTor=', X) > 0 THEN
	    		  _UpdateVAR (URL[21], 'URL_UIndex', X);
    			IF Pos ('URL_Ext=', X) > 0 THEN
	    		  _UpdateVAR (URL[16], 'URL_Ext', X);
    			IF Pos ('URL_YouTube=', X) > 0 THEN
	    		  _UpdateVAR (URL[12], 'URL_YouTube', X);
    			IF Pos ('URL_Nyaa=', X) > 0 THEN
	    		  _UpdateVAR (URL[8], 'URL_Nyaa', X);
    			IF Pos ('AnimeXlateGroup=', X) > 0 THEN
	    		  _UpdateVAR (AnimeXlateGroup, 'AnimeXlateGroup', X);

    			IF Pos ('URL_LimeTorrent=', X) > 0 THEN
	    		  _UpdateVAR (URL[9], 'URL_LimeTorrent', X);
				  
    			IF Pos ('URL_1337x=', X) > 0 THEN
	    		  _UpdateVAR (URL[13], 'URL_1337x', X);

        		IF Pos ('HTML_FontName=', X) > 0 THEN
	    		  _UpdateVAR (HTML_FontName, 'HTML_FontName', X);

		    	IF Pos ('Header_Color=', X) > 0 THEN
			      _UpdateVAR (Header_Color, 'Header_Color', X);
    			IF Pos ('Header_BGColor=', X) > 0 THEN
	    		  _UpdateVAR (Header_BGColor, 'Header_BGColor', X);
		    	IF Pos ('CSS_Link_Color=', X) > 0 THEN
			      _UpdateVAR (CSS_Link_Color, 'CSS_Link_Color', X);
    			IF Pos ('CSS_VLink_Color=', X) > 0 THEN
	    		  _UpdateVAR (CSS_VLink_Color, 'CSS_VLink_Color', X);

				IF Pos ('Highlight_BGColor=', X) > 0 THEN
	    		  _UpdateVAR (Highlight_BGColor, 'Highlight_BGColor', X);

		    	IF Pos ('Line1_BGColor=', X) > 0 THEN
			      _UpdateVAR (Line1_BGColor, 'Line1_BGColor', X);
    			IF Pos ('Line2_BGColor=', X) > 0 THEN
	    		  _UpdateVAR (Line2_BGColor, 'Line2_BGColor', X);
		    	IF Pos ('ComText_Color=', X) > 0 THEN
			      _UpdateVAR (ComText_Color, 'ComText_Color', X);

                IF Pos ('Status_Break=', X) > 0 THEN
			      _UpdateVAR (StatusBreak, 'Status_Break', X);
                IF Pos ('Status_Running=', X) > 0 THEN
			      _UpdateVAR (StatusRunning, 'Status_Running', X);
                IF Pos ('Status_InDev=', X) > 0 THEN
			      _UpdateVAR (StatusInDev, 'Status_InDev', X);
                IF Pos ('Status_Unknown=', X) > 0 THEN
			      _UpdateVAR (StatusUnknown, 'Status_Unknown', X);
                IF Pos ('Status_Ended=', X) > 0 THEN
			      _UpdateVAR (StatusEnded, 'Status_Ended', X);
                IF Pos ('Status_NewShow=', X) > 0 THEN
			      _UpdateVAR (StatusNewShow, 'Status_NewShow', X);
			  END;
		  END;
		Close (C);
	END;

  LinkURL[ 1] := URL[ 1];  
  LinkURL[ 2] := URL[ 1] + '/search/';
  LinkURL[ 3] := URL[ 2] + '/search.php?cat=0&q=';
  LinkURL[ 4] := URL[ 3] + '/search?q=';
  LinkURL[ 5] := URL[ 4] + '/results/#?q=';
  LinkURL[ 6] := URL[ 5] + '/tag/';
  LinkURL[ 7] := URL[ 6] + '/search.html?q=';
  LinkURL[ 8] := URL[ 7] + '/tv-show/';
  LinkURL[ 9] := URL[ 8] + '/?f=0&c=0_0&q=';
  LinkURL[10] := URL[ 9] + '/search/all/';
  LinkURL[11] := URL[10] + '/search/?name=';
  LinkURL[12] := URL[11] + '/?s=';
  LinkURL[13] := URL[12] + '/results?search_query=';                    
  LinkURL[14] := URL[13] + '/sort-search/';
  LinkURL[15] := URL[14] + '/search?&q=';
  LinkURL[16] := URL[16] + '/browse/?cat=2&sort=age&order=desc&with_adult=1&q=';
  LinkURL[17] := URL[21] + '/search.php?c=2&search=';
END;

PROCEDURE RuntimeError (Msg: String);
BEGIN
  WriteLn (Msg);
  Halt;
END;

{
Capture compiler environment for TVList target build.
}
FUNCTION OSVersion: String;
BEGIN
  OSVersion := 'Other';

{$IFDEF UNIX}
  OSVersion := 'Unix';
  {$IFDEF Linux}
    OSVersion := 'Linux';
  {$ENDIF}
{$ENDIF}

{$IFDEF MSWINDOWS}
  OSVersion := 'Windows';
  {$IFDEF WIN32}
     OSVersion := 'Win32';
  {$ENDIF}
  {$IFDEF WIN64}
     OSVersion := 'Win64';
  {$ENDIF}
{$ENDIF}
END;

{
Write HTML header, embed HTML icon, STYLE code, and javascript code used in TVList.
}
PROCEDURE Write_HTML_Headers;
BEGIN
  WriteLn (T, '<!DOCTYPE HTML>');
  Write (T, '<HTML><HEAD><META CHARSET="UTF-8">');
  
{
If HTML_RefreshRate is set, embed HTML META refresh code.
}  
  IF HTML_RefreshRate <> '' THEN
    Write (T, '<META HTTP-EQUIV="REFRESH" CONTENT="', HTML_RefreshRate, '">');

  Write (T, '<TITLE>', ProgName, ' ', ProgVer,
            '</TITLE><LINK REL="icon" TYPE="image/png" HREF="data:image/x-icon;base64,', TVListPNGB64_1, TVListPNGB64_2, TVListPNGB64_3, TVListPNGB64_4);
  WriteLn (T, '" REL="icon" TYPE="image/x-icon" />');

{
CSS code for Table Highlight.
}

  IF DisplayHighlight THEN
	WriteStyle_TableHighlight;

{
CSS code for blinking text.
}
  WriteStyle_Blink;

  WriteLn (T);
  
{$IFDEF CHRISTMAS}
  WriteStyle_SnowFlake;
{$ENDIF}  

  WriteJSScript3 ('SiteStatus');    {***  Pull down menu for site status         ***}
  WriteJSScript3 ('SubtitlesUtil'); {***  Pull down menu for site status         ***}
  WriteJSScript2;                   {***  jQuery JavaScript Library v1.11.1      ***}
  WriteJSScript1;                   {***  The Final Countdown for jQuery v2.2.0  ***}
  
  WriteLn (T);
{
CSS code for snowflake...
}

  Write   (T, '</HEAD>');
  Write   (T, '<BODY>');
  Write   (T, '<STYLE>A {text-decoration: none;}</STYLE>');
END;

{
Write HTML header, about, EXTV Status, copyright message, etc.
}

FUNCTION UFilter (I: String): String;
VAR
  O : String;
BEGIN
  O := I;
  Delete (O, 1, Pos('//', O) + 1);
  UFilter := O;
END;

PROCEDURE Write_Headers;
BEGIN
  WriteLn (T, '<FONT FACE="', HTML_FontName, '">');
  WriteLn (T, '<FONT SIZE=+1>', L1);
  
{$IFDEF CUSTOMSEARCH}
  Write (T, HTMLSpace + HTMLSpace + '<FONT COLOR="#FF0000"><B>\(^O^)/</B></FONT>');  
{$ENDIF}
  
  WriteLn (T, '<BR>&copy;' + L2 + '</FONT>');

  WriteLn (T, '<SPAN STYLE="float:right;">');
  
  Write (T, 'Site Status: ');

WriteLn (T, '    <select id="SiteStatus" onchange="openLinkSiteStatus()">');

WriteLn (T, '        <option value="">Select...</option>');

WriteLn (T, '        <option value="https://eztvstatus.org">EZTV (official)</option>');
WriteLn (T, '        <option value="https://1337x-status.org/">1337x (official)</option>');
WriteLn (T, '        <option value="">----------</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/eztvstatus.org.html">EZTV (official) (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/l337x-status.org.html">1337x (official) (IIDRN)</option>');
WriteLn (T, '        <option value="">----------</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[16]), '.html">', UFilter(URL[16]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[ 1]), '.html">', UFilter(URL[ 1]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[ 8]), '.html">', UFilter(URL[ 8]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[ 2]), '.html">', UFilter(URL[ 2]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[ 9]), '.html">', UFilter(URL[ 9]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[21]), '.html">', UFilter(URL[21]), ' (IIDRN)</option>');
WriteLn (T, '        <option value="https://www.isitdownrightnow.com/', UFilter(URL[ 6]), '.html">', UFilter(URL[ 6]), ' (IIDRN)</option>');

WriteLn (T, '    </select>');

  
  WriteLn (T, '</SPAN>');
  
  Write   (T, '<P STYLE="text-align:left;">');
  Write   (T, '<FONT SIZE=-1><I>', L3, '</I>');
  Write   (T, '<SPAN STYLE="float:right;">');

{$IFDEF DNSHELP8888}
  Write   (T, '<A HREF="', URL_HOWTO_DNS, '" TARGET=_BLANK TITLE="', Desc_DNS8888, '">');
  WriteLn (T, '<B>Website blocked? Use DNS 8.8.8.8 or 8.8.4.4</B></A>');
{$ENDIF}

WriteLn (T, '</SPAN></P></FONT>');

  {$IFDEF TOGGLETABLE}
  
  WriteLn (T, '<HR>');
  WriteLn (T, '<button onclick="ToggleTable()">Toggle Shows</button><P/>');
  WriteLn (T, '<DIV id="DataTable">');

  {$ENDIF}

  IF DisplayHighlight THEN
    Write   (T, '<TABLE class="myTable myTable-highlight-all" WIDTH="100%" BORDER=1><THEAD><TR BGCOLOR=', Header_BGColor, '>')
  ELSE
    Write   (T, '<TABLE WIDTH="100%" BORDER=1><TR BGCOLOR=', Header_BGColor, '>');

  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_Show, '"><FONT COLOR=', Header_Color, '>Show</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_Airs, '"><FONT COLOR=', Header_Color, '>Airs</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_EZTV, '"><FONT COLOR=', Header_Color, '>EZTV</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_General, '"><FONT COLOR=', Header_Color, '>General</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_Search, '"><FONT COLOR=', Header_Color, '>Torrent Searches</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_TVProfiles, '"><FONT COLOR=', Header_Color, '>TV Profiles</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_TVNews, '"><FONT COLOR=', Header_Color, '>TV News</FONT></DIV></TH>');
  Write   (T, '<TH ALIGN="CENTER"><DIV TITLE="', Desc_Online, '"><FONT COLOR=', Header_Color, '>Watch Online</FONT></DIV></TH>');
  WriteLn (T, '</TR>');
  
  IF DisplayHighlight THEN
    WriteLn (T, '</THEAD>');
END;

{
Write bookmarks, and colated data from source.
}
PROCEDURE Write_Bookmarks;
VAR
  J,
  K : Word;
  PROCEDURE _Pull (C: Char; VAR N: Word);
  VAR
    J : Word;
  BEGIN
    J := 0;
    FOR I := EZTVPageCount DOWNTO 1 DO
	  IF EZTVDay[I] = C THEN
	    BEGIN
		  Inc (J);
		  TK[J] := EZTVPage[I];
		  IF TK[J] = '' THEN
		    Dec (J);
		END;
	N := J;
  END;
  PROCEDURE _Pull2 (VAR N: Word);
  VAR
    J : Word;
  BEGIN
    J := 0;
    FOR I := EZTVPageCount DOWNTO 1 DO
	  IF NOT (EZTVDay[I] IN ['0', '1', '2', '3', '4', '5', '6']) THEN
	    BEGIN
		  Inc (J);
		  TK[J] := EZTVPage[I];
		  IF TK[J] = '' THEN
		    Dec (J);
		END;
	N := J;
  END;
  PROCEDURE _Gen(CC: String);
  VAR
    J: Word;
  BEGIN
    IF K > 0 THEN
      BEGIN
        Write (T, '<A ONCLICK="');
        FOR J := 1 TO (K - 1) DO
          Write (T, 'window.open (''', TK[J], '''); ');
        Write (T, '" HREF="', TK[K], '" TARGET="_BLANK">', CC, '(',K,')</A>');
      END
    ELSE
      Write (T, CC, '(0)');
  END;

BEGIN
  K := 0;

  Write (T, '<TABLE WIDTH=100% BORDER=0><TR><TH>EZTV Quick Checks</TH></TR><TR><TD><CENTER>');
  
  Write (T, '<A ONCLICK="');
  FOR J := 1 TO (EZTVPageCount - 1) DO
    IF EZTVPage[J] <> '' THEN
	  Write (T, 'window.open (''', EZTVPage[J], '''); ');
  Write (T, '" HREF="', EZTVPage[EZTVPageCount], '" TARGET="_BLANK">All(',EZTVPageCount,')</A>,', HTMLSpace);

  _Pull('0', K);
  _Gen('Sun');
  Write (T, ',', HTMLSpace);
  _Pull('1', K);
  _Gen('Mon');
  Write (T, ',', HTMLSpace);
  _Pull('2', K);
  _Gen('Tue');
  Write (T, ',', HTMLSpace);
  _Pull('3', K);
  _Gen('Wed');
  Write (T, ',', HTMLSpace);
  _Pull('4', K);
  _Gen('Thu');
  Write (T, ',', HTMLSpace);
  _Pull('5', K);
  _Gen('Fri');
  Write (T, ',', HTMLSpace);
  _Pull('6', K);
  _Gen('Sat');
  Write (T, ',', HTMLSpace, 'and', HTMLSpace);

  _Pull2(K);
  _Gen('Others');
  Write (T, '.');
  Write (T, '</CENTER></TD></TR></TABLE>');
  
  Write (T, '<CENTER><A HREF="', LinkURL[2], 'S01E01" TARGET="_BLANK">New Shows on EZTV.<IMG HEIGHT="', NewIconHeight, 
            '" SRC="data:image/png;base64,');
  FOR J := 1 TO 63 DO 
    Write (T, Base64New[J]);
  WriteLn (T, '"/></A>');
  
  Write (T, HTMLSpace, HTMLSpace, '<A HREF="', LinkURL[2], 'Complete" TARGET="_BLANK">Completed Seasons on EZTV.</A>');

{$IFDEF BROWSERHELP}
  Write (T, '<P>');
  Write (T, 'Cannot open multiple tabs with "EZTV Quick Checks"? Mouseover for solution &#10230;', HTMLSpace);
  Write (T, '<A TITLE="', Desc_Firefox2, '"><B>Firefox,', HTMLSpace, '</B></A>');
  Write (T, '<A TITLE="', Desc_Chrome2, '"><B>Chrome,', HTMLSpace, '</B></A>and', HTMLSpace);
  Write (T, '<A TITLE="', Desc_Opera2, '"><B>Opera', HTMLSpace, '</B></A>.');
{$ENDIF}

  Write (T, '</CENTER>');

  Write (T, '<P><TT><CENTER>Homepages for', HTMLSpace);

  Write (T, '<A HREF="', URL[ 1], '" TARGET="_BLANK">EZTV</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[ 8], '" TARGET="_BLANK">Nyaa(', AnimeHiragana, ')</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[ 2], '" TARGET="_BLANK">The Pirate Bay</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[ 9], '" TARGET="_BLANK">Lime Torrent</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[16], '" TARGET="_BLANK">Ext</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[21], '" TARGET="_BLANK">UIndex</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[12], '" TARGET="_BLANK">YouTube</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[13], '" TARGET="_BLANK">1337x</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[10], '" TARGET="_BLANK">Next Episode</A>,', HTMLSpace);

  Write (T, 'and', HTMLSpace);

  Write (T, '<A HREF="', URL[ 6], '" TARGET="_BLANK">Yes Movies</A>');

  WriteLn (T, '<P/>Subtitles Utility:', HTMLSpace);
  WriteLn (T, '    <select id="SubtitlesUtil" onchange="openLinkSubtitlesUtil()">');
  WriteLn (T, '        <option value="">Select...</option>');
  WriteLn (T, '        <option value="', URL[17], '">Translate SRT (language)</option>');
  WriteLn (T, '        <option value="', URL[18], '">Extract SRT (online)</option>');
  WriteLn (T, '        <option value="', URL[19], '">Convert SRT (from other formats)</option>');
  WriteLn (T, '        <option value="', URL[20], '">Locate SRT (subtitles)</option>');
  WriteLn (T, '    </select>');
    
  WriteLn (T, '</CENTER></TT>');
END;

{
Write Footer HTML code after TABLE generation.
}
PROCEDURE Write_Footer;
{$IFDEF EASTEREGG1}
CONST
  SQMax = 200;
  
VAR
  SQ      : String;
  R       : Real;
  I       : Word;
  SQS     : Array [0..SQMax] of String;
{$ENDIF}
  
BEGIN
  WriteLn (T, '</TABLE><P>');
  
{$IFDEF TOGGLETABLE}
  WriteLn (T, '</DIV>');
{$ENDIF}
  
  Write_Bookmarks;

{$IFDEF EASTEREGG1}

  {$I tvlist-sq.pas}
  
  Randomize;
  R := Random * SQMax;
  I := Round (R);
  
  Write (T, '<P><CENTER><FONT SIZE=-2><I>');

  SQ := SQS[I];
  Write (T, SQ, HTMLSpace, HTMLOpenSB, I, HTMLCloseSB);  
  Write (T, '</I></FONT></CENTER></P>');
{$ENDIF}
  
  xEnd := getTickCount64;
  xDiff := (xEnd - xStart) / 1000;
  Write (T, '<P/><TT><HR><I><FONT SIZE=-1>', LL1, OSVersion, LL2, xDiff:3:2, LL3);
  Write (T, '<BR/>$Program compiled at ' + CTime + ' (local time) on ' + CDate + '<BR>');
  Write (T, '$Get the source code from <A HREF="', URL_TVList_Source, '" TARGET="_BLANK">github.com</A><BR>');
  Write (T, '$BitCoin Donate', HTMLSpace, '<A HREF="bitcoin:', MyBitCoin, '">', MyBitCoin, '</A></I>');
  WriteLn (T, '</FONT></FONT></TT>');

{$IFDEF EASTEREGG2}
  WriteLn (T, '<P/ ALIGN="RIGHT"><A HREF="https://www.cultdeadcow.com/" TARGET=_BLANK>&pi;</A>');
{$ENDIF}

{
ORIGINAL>>>>>>        $this.html(event.strftime('%D days %H:%M:%S'));
}
  WriteJS_DayCount;

{$IFDEF TOGGLETABLE}
  WriteJS_TableHighlight;
{$ENDIF}  

{
Code for the snowfalling effect...
}
{$IFDEF CHRISTMAS}
  WriteJS_SnowFlake;
{$ENDIF}		
  WriteLn (T, '</BODY></HTML>');
END;

FUNCTION Num2Str (N: Word): String;
VAR
  X : String;
BEGIN
  Str (N, X);
  IF N < 10 THEN
    X := '0' + X;
  Num2Str := X;
END;

FUNCTION R2S (I:Real):String;
VAR
  X : String;
  J : Real;
BEGIN
  J := I;
  J := J / 60;
  IF J < 0 THEN
    J := J * -1;
  Str (J:2:1, X);
  IF I < 0 THEN
    X := '+' + X
  ELSE
    X := '-' + X;

  IF X[Length(X)] = '0' THEN
    Delete (X, Length(X) - 1, 2);
  R2S := X;
END;

{
TVList program message.
}
PROCEDURE Prog_Message;
BEGIN
  L1 := ProgName + ' ' + ProgVer + ' - ' + ProgDesc + ' - Created by ' + ProgAuthor + '. Build ' + ProgDate;
  L2 := ' Copyright ' + ProgAuthor + ', 2015-' + ProgDate[1] + ProgDate[2] + ProgDate[3] + ProgDate[4] + 
        '. All Rights Reserved. Distributed under an MIT license.';
  L3 := 'List generated on ' + DayName[xuDa] + ', ' + Num2Str(xDa) + '-' + MonthName[xMo] + '-' +
        Num2Str(xYe) + ', ' + Num2Str(xHo) + ':' + Num2Str(xMi) + ':' + Num2Str(xSe) + ' UTC' +
		R2S(GetLocalTimeOffset);

  WriteLn (L1);
  WriteLn ('(c)', L2);
  WriteLn;
  
  WriteLn (L3);
  WriteLn;
END;

PROCEDURE GetDateTime;
BEGIN
{
Grab current date and time for various reports and calculations.
}
  xStart := getTickCount64;
  GetDate (xYe, xMo, xDa, xuDa);
  GetTime (xHo, xMi, xSe, xuSe);
END;

FUNCTION RepSpaceStr (C: Char; X: String): String;
VAR
  I : Word;
BEGIN
  FOR I := 1 TO Length(X) DO
    IF X[I] = ' ' THEN
      X[I] := C;
  RepSpaceStr := X;
END;

PROCEDURE ProcessFilesOpen;
BEGIN
{
Open the source (.txt) and recreate target (.htm) files.
}
  IF NOT FileExists (TVList_Data) THEN
    RuntimeError ('Error, file "' + TVList_Data + '" not found.');
  Assign (S, TVList_Data);
  Assign (T, TVList_HTML);
  Reset (S);
  ReWrite (T);
  Write_HTML_Headers;
  Write_Headers;
  LineCount := 0;
END;

{
Check and extract comments from string W, then delete the comments from string W.
}
PROCEDURE ExtractComments;
VAR
  A : Word;
BEGIN
  ComText := '';
  A := Pos('@', W);
  IF A < 1 THEN
    EXIT;
  ComText := W;
  Delete (ComText, 1, A);
  Delete (W, A, (Length(W) - A) + 1);
END;


PROCEDURE ProcessData;
VAR
  EntryIsCountdown,
  IsAnime           : Boolean;
  AS                : String;
  _I                : Word;
  CurRunShowDay     : Char;
  
  PROCEDURE _Showday(SS: String; C: Char);
  BEGIN
    Inc (EZTVPageCount);
    ShowDay := SS;
	EZTVDay[EZTVPageCount] := C;
  END;
BEGIN
  CurRunShowDay := #00;
  WHILE NOT Eof (S) DO
    BEGIN
      IsAnime := False;
      REPEAT
        ReadLn (S, W);
		ExtractComments;
      UNTIL (W[1] <> '#') OR Eof(S);
{
Check if string W has the [YYYYMMDD] data, and initiate countdown code into "Coundown" variable, and remove the [YYYYMMDD] data from string W.   
}      
	  ShowDay := '<B><FONT COLOR=' + StatusUnknown + '>&#91;UNKWN&#93;</FONT></B>';

      Countdown := '';
	  EntryIsCountdown := False;
	  IF ((Length(W) > 10) AND ((W[1] = '[') AND (W[10] = ']'))) THEN
	    BEGIN
	      Countdown := '<div data-countdown="' + W[2] + W[3] + W[4] + W[5] + '/' + W[6] + W[7] + '/' + W[8] + W[9] + '">';
		  Delete (W, 1, 10);
		  EntryIsCountdown := True;
	    END;

{
Check if char in position 2 of string W is a "|" char, if so add the relevant status from char in position 1 or defaults to UNKNOPWN. 
  Then, elete status data from string W.
}	  
      IF W[2] = '|' THEN
        BEGIN
		  CurRunShowDay := UpCase(W[1]);
          CASE CurRunShowDay OF
            '0' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>s------</FONT></B>', '0');
            '1' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>-M-----</FONT></B>', '1');
            '2' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>--t----</FONT></B>', '2');
            '3' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>---W---</FONT></B>', '3');
            '4' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>----T--</FONT></B>', '4');
            '5' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>-----F-</FONT></B>', '5');
            '6' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>------S</FONT></B>', '6');
            'X' : _ShowDay('<B><FONT COLOR=' + StatusInDev   + '>&#91;INDEV&#93;</FONT></B>', 'X');
            'Y' : _ShowDay('<B><FONT COLOR=' + StatusBreak   + '>&#91;BREAK&#93;</FONT></B>', 'Y');
            'Z' : _ShowDay('<B><FONT COLOR=' + StatusEnded   + '>&#91;ENDED&#93;</FONT></B>', 'Z');
          END;
          Delete (W, 1, 2);
        END;
{
Copy show name out of string W.
}		
      V := Pos (',', W);
      IF V > 1 THEN
        BEGIN
          XN := '';
          FOR I := 1 TO (V - 1) DO
            XN := XN + W[I];
{
If show name has AnimeFlag, flag Anime search and any search variables that come with it.
}			
		  IF Pos (AnimeFlag, XN) > 0 THEN
		    BEGIN
			  AnimeXlateGroup := '';
			  AS := Copy (XN, Pos (AnimeFlag, XN) + 1, (Length(XN) - Pos (AnimeFlag, XN))); 
			  FOR _I := 1 TO Length(AS) DO 
			    IF AS[_I] = ' ' THEN 
				  AS[_I] := '+';
			  IF Length(AS) > 1 THEN 
			    AnimeXlateGroup := AS;
			  AS := Copy (XN, 1, Pos(AnimeFlag, XN) - 1);
			  XN := AS;
			  IsAnime := True;
			END;
			
          Write (T, '<TR');

{
If highligh bar is not wanted, display background in alternate shades per row.
}
          IF NOT DisplayHighlight THEN
		    BEGIN
    		  IF (LineCount MOD 2) = 0 THEN
	    	    Write (T, ' BGCOLOR=', Line1_BGColor)
		      ELSE
		        Write (T, ' BGCOLOR=', Line2_BGColor);
			END;

		  Write (T, '><TD>');
{
If string W had comment, inserted by the following code.
}		  
		  IF ComText <> '' THEN
		    Write (T, '<DIV TITLE="', ComText, '"><FONT COLOR=', ComText_Color, '>');
		  
{
If show name has a truncate flag, to cut the display name and remove said flag, but only for display. Full
  name is still used for other things.
}
		  XNN := XN;

		  IF Pos(TruncFlag, XN) > 0 THEN
		    BEGIN
			  WHILE (Pos(TruncFlag, XN) > 0) DO 
			    Delete (XN, Length(XN), 1);
			  XN := XN + '...';	                            { adds "..." to name at point of truncation to indicate it has been truncated. }
			END;

          Write (T, XN);
		  
		  XN := XNN;
		  WHILE Pos(TruncFlag, XN) > 0 DO 
		    Delete (XN, Pos(TruncFlag, XN), 1);
			
		  IF ComText <> '' THEN
		    Write (T, '</FONT></DIV>');
		  Write (T, '</TD>');

          XL := '';
          FOR I := (V + 1) TO Length (W) DO
            XL := XL + W[I];
{
Display show day as provided. This is superseded if countdown date is provided. 
}
          IF Countdown = '' THEN
            Write (T, TDStr + '<TT>', ShowDay, '</TT></TD>')
		  ELSE
			Write (T, TDStr + '<TT>', Countdown, '</TT></TD>');

{
Display search data from EZTV search engine, and if provided, EZTV's dedicated page for said show.
}
		  Write (T, TDStr);
		  IF XL <> '0//' THEN
		    BEGIN
              Write (T, '<A HREF="', LinkURL[ 1], '/shows/', XL, '" TARGET="_BLANK">Info</A>,', HTMLSpace);
			  IF EZTVPageCount < EZTVPageMax THEN
                BEGIN
	              EZTVPage[EZTVPageCount] := LinkURL[1] + '/shows/' + XL;
	            END;
			END;

{
Added a Google search using show name and added the "+TV +Show" parameters to the search query.
}			
          Write (T, '<A HREF="', LinkURL[ 2], RepSpaceStr('-', XN), '" TARGET="_BLANK">');
		  
		  IF ((XL = '0//') AND (CurRunShowDay IN ['0'..'6']) AND (NOT EntryIsCountdown)) THEN 
		    Write (T, '<FONT COLOR=', StatusNewShow, '><DIV CLASS="blinking-text"><B>Search</B></DIV></FONT>') 
		  ELSE 
			Write (T, 'Search');
		  
		  Write (T, '</A></TD>');
		  Write (T,  TDStr + '<A HREF="', LinkURL[15], RepSpaceStr('+', XN), '+%2BTV+%2BShow" TARGET="_BLANK">Google</A>');


{
Show trailer for show if available on YouTube
}		  
          Write (T, HTMLSpace, '<A HREF="', LinkURL[13], RepSpaceStr('+', XN), '+Official+Trailer" TARGET="_BLANK"><B>', HTMLOpenSB, 'TR', HTMLCloseSB, '</B></A>');
          Write (T, TDStr);

{$IFDEF ANIMESEARCH}

{
If show is flagged as Anime, add additional search option for anime torrent search site.
}
          IF IsAnime THEN
		    BEGIN
  		      Write (T, '<A HREF="', LinkURL[ 9]);
			  IF AnimeXlateGroup = '' THEN ELSE
			    Write (T, AnimeXlateGroup + '+');
			  Write (T, RepSpaceStr('+', XN), '" TARGET="_BLANK">' + AnimeHiragana + '</A>,', HTMLSpace);
            END;
{$ENDIF}
{
Add the other torrent search engine links to search show name.
}
          Write (T, '<A HREF="', LinkURL[ 3], RepSpaceStr('+', XN), '" TARGET="_BLANK">PirateBay</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[10], XN, '/" TARGET="_BLANK">LimeTor</A>,', HTMLSpace);
		  Write (T, '<A HREF="', LinkURL[16], RepSpaceStr('+', XN), '" TARGET="_BLANK">Ext</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[17], RepSpaceStr(' ', XN), '" TARGET="_BLANK">UIndex</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[14], RepSpaceStr('+', XN), '/time/desc/1/" TARGET="_BLANK">1337x</A>');

{$IFDEF CUSTOMSEARCH}
{
Custom search that I psersonally use, but can be modified if you understand how TVList works in this source code.
}

          Write (T, ',', HTMLSpace, '<A TITLE="Ext-x265-MeGusta" HREF="',       LinkURL[16], RepSpaceStr('+', XN), '+x265+MeGusta" TARGET="_BLANK"><FONT COLOR=',                CustomColor, '><B>', HTMLOpenSB, 'EMG', HTMLCloseSB, '</B></FONT></A>');
          Write (T, '' , HTMLSpace, '<A TITLE="Ext-720p-x265-MeGusta" HREF="',  LinkURL[16], RepSpaceStr('+', XN), '+720p+x265+MeGusta" TARGET="_BLANK"><FONT COLOR=',           CustomColor, '><B>', HTMLOpenSB, 'EMG7', HTMLCloseSB, '</B></FONT></A>');
{$ENDIF}		  
		  Write (T, '</TD>');
{
Add the news, streaming, and episode guide sites to show.
}		
          Write (T, TDStr + '<A HREF="', LinkURL[11], RepSpaceStr('-', XN), '" TARGET="_BLANK">NextEpisode</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[ 8], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVfinale</A></TD>');
          Write (T, TDStr + '<A HREF="', LinkURL[ 5], XN, '" TARGET="_BLANK">Variety</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[ 6], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVLine</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 7], RepSpaceStr('+', XN), '" TARGET="_BLANK">YesMovies</A>', HTMLSpace);
          WriteLn (T, '</TD></TR>');
          Write ('.');
          Inc (LineCount);
        END
      ELSE
        Write ('X');
	END;
  WriteLn (':done!');	
END;

PROCEDURE ProcessFilesClose;
BEGIN
{
Close the source (.txt) and target (.htm) files.
}
  Write_Footer;
  Close (S);
  Close (T);
END;

PROCEDURE GetTempPath;
VAR
  VarName : String;
  PA      : Char;
BEGIN
  VarName := 'TMPDIR';
  PA := '/';
{$IFDEF MSWINDOWS}
  VarName := 'TEMP';
  PA := '\';
{$ENDIF}
  TempPath := GetEnvironmentVariable(VarName);
  IF TempPath[Length(TempPath)] <> PA THEN 
    TempPath := TempPath + PA;
  
END;

PROCEDURE ProcessParameters;
VAR
  I : Word;
  S : String;
BEGIN
  
  TVListString  := 'tvlist';
  IF (ParamCount > 0) THEN
    BEGIN
      FOR I := 1 TO ParamCount DO
        BEGIN
		  S := ParamStr (I);
		  IF S = '/s' THEN
		    BEGIN
		      FancyShow := True;
			END  
		  ELSE
		    BEGIN
			  IF Pos('.', S) > 0 THEN 
			    BEGIN
				END
			  ELSE
		        TVListString := S;
			END;
        END;
    END;
  TVList_Data   := TVListString + '.txt';
  TVList_HTML   := TVListString + '.htm';
  TVList_Config := TVListString + '.cfg';
END;

{
Sort data file into three categories (running, upcoming, other),
then merge back into a single sorted temp file for processing.
Temp files are deleted automatically via CleanupTempFiles after output is generated.
}
PROCEDURE DoFancy;
VAR
  S,
  T,
  U,
  V      : Text;
  A      : String;
  PROCEDURE _OpenFiles_Seperate;
  BEGIN
    Assign (S, TVList_Data);
    Assign (T, TempPath + RString + 'tvlist1.txt');
    Assign (U, TempPath + RString + 'tvlist2.txt');
    Assign (V, TempPath + RString + 'tvlist3.txt');
    Reset (S);
    ReWrite (T);
    ReWrite (U);
    ReWrite (V);
  END;  
  PROCEDURE _CloseFiles_Seperate;
  BEGIN
    Close (S);
    Close (T);
    Close (U);  
    Close (V);
  END;
  PROCEDURE _Work_Seperate;
  BEGIN
    WHILE NOT Eof(S) DO
      BEGIN
	    Write ('.');
	    ReadLn (S, A);
	    IF A[1] IN ['0'..'6'] THEN
	      WriteLn (T, A);
	    IF A[1] = '[' THEN
	      WriteLn (U, A);
	    IF A[1] IN ['0'..'6', '[', '#'] THEN 
	      Write ('@')
		ELSE
  	      WriteLn (V, A);
	  END;	
  END;
  PROCEDURE _OpenFiles_Merge;
  BEGIN
    Assign (S, TempPath + RString + 'tvlist0.txt');
    Assign (T, TempPath + RString + 'tvlist1.txt');
    Assign (U, TempPath + RString + 'tvlist2.txt');
    Assign (V, TempPath + RString + 'tvlist3.txt');
    ReWrite (S);
    Reset (T);
    Reset (U);
    Reset (V);
  END;
  PROCEDURE _CloseFiles_Merge;
  BEGIN
    _CloseFiles_Seperate; {* Closes the same file handles *}
  END;
  PROCEDURE _Work_Merge;
    PROCEDURE __Progress;
    BEGIN
      Write ('*');
    END;
  BEGIN
    WHILE NOT Eof(T) DO
      BEGIN
	    __Progress;
	    ReadLn (T, A);
	    WriteLn (S, A);
	  END;
    WHILE NOT Eof(U) DO
      BEGIN
	    __Progress;
	    ReadLn (U, A);
	    WriteLn (S, A);
	  END;
    WHILE NOT Eof(V) DO
      BEGIN
	    __Progress;
	    ReadLn (V, A);
	    WriteLn (S, A);
	  END;
  END;
PROCEDURE _SortUpcomming;
CONST
  StrLimit = 10000;
VAR
  S     : Text;
  T     : String;
  A     : Array [1..StrLimit] of String;
  N,
  I,
  J      : Word;
BEGIN
    Assign (S, TempPath + RString + 'tvlist2.txt');
	Reset (S);
	N := 1;
	WHILE ((NOT Eof (S)) AND (N <= StrLimit)) DO
	  BEGIN
	    ReadLn (S, A[N]);
		Inc (N);
	  END;
	Close (S);  
	Dec (N);  
	FOR J := 1 TO N DO
	  FOR I := 1 TO (N - 1) DO
	    IF A[I] > A[I + 1] THEN
		  BEGIN
		    T := A[I];
			A[I] := A[I + 1];
			A[I + 1] := T;
		  END;
    Assign (S, TempPath + RString + 'tvlist2.txt');
	ReWrite (S);	  
	FOR I := 1 TO N DO
	  WriteLn (S, A[I]);
	Close (S);  
END;
  
BEGIN
  _OpenFiles_Seperate;
  _Work_Seperate;  
  _CloseFiles_Seperate;
  _SortUpcomming;
  _OpenFiles_Merge;
  _Work_Merge;
  _CloseFiles_Merge;
  TVList_Data := TempPath + RString + 'tvlist0.txt';
END;

{
Remove temp files created by DoFancy from the system temp directory.
Only runs if FancyShow mode was active.
}
PROCEDURE CleanupTempFiles;
BEGIN
  IF FancyShow THEN
    BEGIN
      DeleteFile (TempPath + RString + 'tvlist0.txt');
      DeleteFile (TempPath + RString + 'tvlist1.txt');
      DeleteFile (TempPath + RString + 'tvlist2.txt');
      DeleteFile (TempPath + RString + 'tvlist3.txt');
    END;
END;

BEGIN
  GetTempPath;
  TVListString := 'tvlist';
  TVList_Data  := 'tvlist.txt';
  TVList_HTML  := 'tvlist.htm';
  TVList_Config:= 'tvlist.cfg';
  VARInit;
  ProcessParameters;
  GetDateTime;
  Prog_Message;
  IF FancyShow Then
    DoFancy;
  ProcessFilesOpen;
  IF DisplayHighlight THEN
    WriteLn (T, '<TBODY>');
  ProcessData;
  IF DisplayHighlight THEN
    WriteLn (T, '</TBODY>');
	
{$IFDEF TOGGLETABLE}
  Write (T, '</DIV>');
{$ENDIF}
	
  ProcessFilesClose;
  CleanupTempFiles;
END.
