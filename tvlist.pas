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

*}

{$R tvlist.rc}

{$DEFINE EASTEREGG1}
{$DEFINE EASTEREGG2}
{$DEFINE DNSHELP8888}

PROGRAM TVList;

USES
  CRT,
  DOS,
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

CONST
  ProgName             = 'TVList';
  ProgVer              = 'v0.9.5';
  ProgDate             = '20201208';
  ProgAuthor           = 'Adrian Chiang';
  ProgDesc             = 'An EZTV Series Manager';

  MyBitCoin            = '1FSMJRMk65o25frAsBoMYoZEZMkqncQ4Jm';

  CTime                = {$I %TIME%};
  CDate                = {$I %DATE%};

  EZTVPageMax          = 512;

  LL1 = '$' + ProgName + '(';
  LL2 = ') took ';
  LL3 = ' second(s) to generate HTML...';

  Desc_Show       = 'Name of the show';
  Desc_EZTV       = 'Go to EZTV''s show info page or search the EZTV database for similar name episodes.';
  Desc_Search     = 'Search torrent engines for show if not found in EZTV.';
  Desc_TVProfiles = 'Show sites with status of show, cast, dates.';
  Desc_TVNews     = 'News of shows, viewer feedback, ratings, etc.';
  Desc_Online     = 'Watch show online instead of downloading/torrenting.';
  Desc_Airs       = 'Day show airs, between seasons, mid-season break, ended or unknown.';
  Desc_General    = 'Search in Google for your TV dramas.';
  Desc_DNS8888    = 'Click to learn how to change the DNS address to your own choosing.';


  URL_TVList_Source  = 'https://www.github.com/ajack2001my/tvlist';
  URL_HOWTO_DNS      = 'https://www.howtogeek.com/167533/the-ultimate-guide-to-changing-your-dns-server/';


  TDStr = '<TD ALIGN="CENTER">';

  TVListString  = 'tvlist';
  TVList_Data   = TVListString + '.txt';
  TVList_HTML   = TVListString + '.htm';
  TVList_Config = TVListString + '.cfg';

  TVListLnkSize = 16;

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
  StatusUnknown,
  StatusEnded,
  StatusBreak,
  StatusRunning,
  L1,
  L2,
  L3,
  W,
  XN,
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

PROCEDURE VARInit;
VAR
  C : Text;
  X : String;
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
    N := P;
  END;
BEGIN

  EZTVPageCount := 0;

  URL[ 1] := 'https://eztv.re';                            {URL_EZTV}
  URL[ 2] := 'https://lepiratebay.org';                    {URL_ThePirateBay}
  URL[ 3] := 'http://www.tv.com';
  URL[ 4] := 'http://variety.com';
  URL[ 5] := 'http://tvline.com';
  URL[ 6] := 'https://yesmovies.ag';                       {URL_YesMovies}
  URL[ 7] := 'https://tvseriesfinale.com';
  URL[ 8] := 'https://extratorrents.it';                   {URL_ExtraTorrent}
  URL[ 9] := 'https://limetorrents.cc';                    {URL_LimeTorrent}
  URL[10] := 'https://next-episode.net';                   {URL_NextEpisode}          
  URL[11] := '';
  URL[12] := 'https://torrentzeu.org';                     {URL_TorrentZ2}
  URL[13] := 'http://1337x.to';                            {URL_1337x}
  URL[14] := 'https://www.google.com';                     {URL_Google}
  URL[15] := 'http://www.returndates.com';
  URL[16] := 'https://torrentgalaxy.to';                   {URL_TorGalaxy}

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

  IF FileExists (TVList_Config) THEN
    BEGIN
	  Assign (C, TVList_Config);
	  Reset (C);
	    WHILE NOT Eof(C) DO
		  BEGIN
		    ReadLn (C, X);
			IF (X[1] <> '#') THEN
			  BEGIN
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
    			IF Pos ('URL_123Movies=', X) > 0 THEN
	    		  _UpdateVAR (URL[10], 'URL_123Movies', X);
    			IF Pos ('URL_EZTV=', X) > 0 THEN
	    		  _UpdateVAR (URL[1], 'URL_EZTV', X);
    			IF Pos ('URL_Google=', X) > 0 THEN
	    		  _UpdateVAR (URL[14], 'URL_Google', X);
    			IF Pos ('URL_ThePirateBay=', X) > 0 THEN
	    		  _UpdateVAR (URL[2], 'URL_ThePirateBay', X);
    			IF Pos ('URL_TorGalaxy=', X) > 0 THEN
	    		  _UpdateVAR (URL[16], 'URL_TorGalaxy', X);
    			IF Pos ('URL_ExtraTorrent=', X) > 0 THEN
	    		  _UpdateVAR (URL[8], 'URL_ExtraTorrent', X);
    			IF Pos ('URL_LimeTorrent=', X) > 0 THEN
	    		  _UpdateVAR (URL[9], 'URL_LimeTorrent', X);
    			IF Pos ('URL_TorrentZ2=', X) > 0 THEN
	    		  _UpdateVAR (URL[12], 'URL_TorrentZ2', X);
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
                IF Pos ('Status_Unknown=', X) > 0 THEN
			      _UpdateVAR (StatusUnknown, 'Status_Unknown', X);
                IF Pos ('Status_Ended=', X) > 0 THEN
			      _UpdateVAR (StatusEnded, 'Status_Ended', X);
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
  LinkURL[ 7] := URL[ 6] + '/searching/';
  LinkURL[ 8] := URL[ 7] + '/tv-show/';
  LinkURL[ 9] := URL[ 8] + '/search/?search=';
  LinkURL[10] := URL[ 9] + '/search/all/';
  LinkURL[11] := URL[10] + '/search/?name=';
  LinkURL[12] := URL[11] + '/?s=';
  LinkURL[13] := URL[12] + '/verified?f=';
  LinkURL[14] := URL[13] + '/search/';
  LinkURL[15] := URL[14] + '/search?&q=';
  LinkURL[16] := URL[16] + '/torrents.php?search=';
END;

PROCEDURE RuntimeError (Msg: String);
BEGIN
  WriteLn (Msg);
  Halt;
END;

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

PROCEDURE Write_HTML_Headers;
BEGIN
  WriteLn (T, '<!DOCTYPE HTML>');
  Write (T, '<HTML><HEAD><META CHARSET="UTF-8"><META HTTP-EQUIV="REFRESH" CONTENT="', HTML_RefreshRate, '"><TITLE>', ProgName, ' ', ProgVer,
            '</TITLE><LINK REL="icon" TYPE="image/png" HREF="data:image/x-icon;base64,', TVListPNGB64_1, TVListPNGB64_2, TVListPNGB64_3, TVListPNGB64_4);
  WriteLn (T, '" REL="icon" TYPE="image/x-icon" />');

  IF DisplayHighlight THEN
    BEGIN
	  WriteLn (T);
	  WriteLn (T, '<style>');
	  WriteLn (T, '.myTable {}');
	  WriteLn (T, '.myTable thead th {}');
	  WriteLn (T, '.myTable tbody td {}');
	  WriteLn (T);
	  WriteLn (T, '.myTable-highlight-all {');
	  WriteLn (T, '    overflow: hidden;');
	  WriteLn (T, '    z-index: 1;');
	  WriteLn (T, '}');
	  WriteLn (T);
	  WriteLn (T, '.myTable-highlight-all tbody td, .myTable-highlight-all thead th {');
	  WriteLn (T, '    position: relative;');
	  WriteLn (T, '}');
	  WriteLn (T);
	  WriteLn (T, '.myTable-highlight-all tbody td:hover::before {');
	  WriteLn (T, '    background-color: ', Highlight_BGColor, ';');
	  WriteLn (T, '    content:''\00a0'';');
	  WriteLn (T, '    height: 100%;');
	  WriteLn (T, '    left: -5000px;');
	  WriteLn (T, '    position: absolute;');
	  WriteLn (T, '    top: 0;');
	  WriteLn (T, '    width: 10000px;');
	  WriteLn (T, '    z-index: -1;');
	  WriteLn (T, '}');
	  WriteLn (T);
	  WriteLn (T, 'a:link {');
      WriteLn (T, '    color: ', CSS_Link_Color, ';');
	  WriteLn (T, '}');
	  WriteLn (T);
	  WriteLn (T, 'a:visited {');
      WriteLn (T, '    color: ', CSS_VLink_Color, ';');
	  WriteLn (T, '}');
	  WriteLn (T, '</style>');
	  WriteLn (T);
	END;

  Write   (T, '</HEAD>');
  Write   (T, '<STYLE>A {text-decoration: none;} </STYLE>');
  Write   (T, '<BODY>');
END;

PROCEDURE Write_Headers;
BEGIN
  WriteLn (T, '<FONT FACE="', HTML_FontName, '">');
  WriteLn (T, '<FONT SIZE=+1>', L1, '<BR>');
  WriteLn (T, '&copy;' + L2 + '<P></FONT>');
{ 
  WriteLn (T, '<FONT SIZE=-1><I>' + L3 + '</I><BR>');
}

Write   (T, '<P STYLE="text-align:left;">');
Write   (T, '<FONT SIZE=-1><I>', L3, '</I>');
Write   (T, '<SPAN STYLE="float:right;">');

{$IFDEF DNSHELP8888}
Write   (T, '<A HREF="', URL_HOWTO_DNS, '" TARGET=_BLANK TITLE="', Desc_DNS8888, '">');
Write   (T, '<B>Website blocked? Use DNS 8.8.8.8 or 8.8.4.4</B></A>');
{$ENDIF}

WriteLn (T, '</SPAN></P></FONT>');

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

PROCEDURE Write_Bookmarks;
VAR
  J,
  K : Word;
  FUNCTION RepeatStr (S: String; N: Word):String;
  VAR
    I : Word;
	X : String;
  BEGIN
    X := '';
	FOR I := 1 TO N DO
	  X := X + S;
	RepeatStr := X;
  END;
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
  Write (T, '" HREF="', EZTVPage[EZTVPageCount], '" TARGET="_BLANK">All(',EZTVPageCount,')</A>,&nbsp;');

  _Pull('0', K);
  _Gen('Sun');
  Write (T, ',&nbsp;');
  _Pull('1', K);
  _Gen('Mon');
  Write (T, ',&nbsp;');
  _Pull('2', K);
  _Gen('Tue');
  Write (T, ',&nbsp;');
  _Pull('3', K);
  _Gen('Wed');
  Write (T, ',&nbsp;');
  _Pull('4', K);
  _Gen('Thu');
  Write (T, ',&nbsp;');
  _Pull('5', K);
  _Gen('Fri');
  Write (T, ',&nbsp;');
  _Pull('6', K);
  _Gen('Sat');
  Write (T, ',&nbsp;and&nbsp;');

  _Pull2(K);
  _Gen('Others');
  Write (T, '.');
  Write (T, '</CENTER></TD></TR></TABLE>');

  Write (T, '<P><TT><CENTER>Homepages for&nbsp;');

  Write (T, '<A HREF="', URL[ 1], '" TARGET="_BLANK">EZTV</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 2], '" TARGET="_BLANK">The Pirate Bay</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 9], '" TARGET="_BLANK">Lime Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL[16], '" TARGET="_BLANK">Torrent Galaxy</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 8], '/home " TARGET="_BLANK">Extra Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL[12], '" TARGET="_BLANK">Torrentz2</A>,&nbsp;');
  Write (T, '<A HREF="', URL[13], '" TARGET="_BLANK">1337x</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 3], '" TARGET="_BLANK">TV</A>,&nbsp;');
  Write (T, '<A HREF="', URL[10], '" TARGET="_BLANK">Next Episode</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 4], '" TARGET="_BLANK">Variety</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 5], '" TARGET="_BLANK">TV Line</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 7], '" TARGET="_BLANK">TV Series Finale</A>,&nbsp;');
  Write (T, '<A HREF="', URL[15], '" TARGET="_BLANK">Return Dates</A>,&nbsp;');

  Write (T, 'and&nbsp;');

  Write (T, '<A HREF="', URL[ 6], '" TARGET="_BLANK">Yes Movies</A>');

  WriteLn (T, '</CENTER></TT>');
END;

PROCEDURE Write_Footer;
{$IFDEF EASTEREGG1}
CONST
  SQMax = 43;
VAR
  SQ : String;
  R  : Real;
  I  : Word;
  SQS : Array [0..SQMax] of String;
{$ENDIF}
  
BEGIN
  WriteLn (T, '</TABLE><P>');
  Write_Bookmarks;

{$IFDEF EASTEREGG1}
  SQS[ 0] := 'If you can read this, you don''t need glasses.'; 
  SQS[ 1] := 'If you notice this notice, you will notice that this notice is not worth noticing.';
  SQS[ 2] := 'Sometimes when I close my eyes, I can''t see.';
  SQS[ 3] := 'Dear Math, please grow up and solve your own problems, I''m tired of solving them for you.';
  SQS[ 4] := 'An apple a day keeps anyone away, if you throw it hard enough.';
  SQS[ 5] := 'I did not trip and fall. I attacked the floor and I believe I am winning.';
  SQS[ 6] := 'There are no stupid questions, just stupid people.';
  SQS[ 7] := 'Did you just fall? No, I was checking if gravity still works.';
  SQS[ 8] := 'I''m glad I don''t have to hunt my own food, I don''t even know where sandwiches live.';
  SQS[ 9] := 'No matter how smart you are you can never convince someone stupid that they are stupid.';
  SQS[10] := 'I put my phone in airplane mode, but it''s not flying!';
  SQS[11] := 'If you think nothing is impossible, try slamming a revolving door.';
  SQS[12] := 'I''m trying to think how I can think of what I want to think.';
  SQS[13] := 'I know that I am stupid but when I look around me I feel a lot better.';
  SQS[14] := 'Doing nothing is hard, you never know when you''re done.';
  SQS[15] := 'When life closes a door, just open it again. It''s a door, that''s how they work.';
  SQS[16] := 'You''re born free, then you''re taxed to death.'; 
  SQS[17] := 'It''s true that we don''t know what we''ve got until we lose it, but it''s also true that we don''t know what we''ve been missing until it arrives.';
  SQS[18] := 'Are you free tomorrow? No, tomorrow I''m still expensive.';
  SQS[19] := 'I think, therefore I am... I think!';
  SQS[20] := 'Only Amiga makes it possible!';
  SQS[21] := 'Apple // Forever!';
  SQS[22] := 'People say you can''t live without love, but I think oxygen is more important.';
  SQS[23] := 'What do I do for a living? I breathe in and out.';
  SQS[24] := 'I love you forever... but I can''t live that long.';
  SQS[25] := 'Retirement is when you stop living at work, and start working at living.';
  SQS[26] := 'Living on earth may be tough, but it includes a free ride around the sun every year.';
  SQS[27] := 'The best things in life are free. The rest are too expensive.';
  SQS[28] := 'The best revenge is massive success.';
  SQS[29] := 'My wife told me the other day that I don''t take her to expensive places any more, so I took her to the gas station.';
  SQS[30] := 'The richer you get, the more expensive happiness becomes.';
  SQS[31] := 'If you want your wife to listen to you, then talk to another woman; she will be all ears.';
  SQS[32] := 'Marriage is like a walk in the park... Jurrasic Park.';
  SQS[33] := 'I had an extremely busy day, converting oxygen into carbon dioxide.';
  SQS[34] := 'Dear life, when I said "can this day get any worse" it was a rhetorical question, not a challenge.';
  SQS[35] := 'My bed is a magical place where I suddenly remember everything I forgot to do.';
  SQS[36] := 'We all have baggage, find someone who loves you enough to help you unpack.';
  SQS[37] := 'Why must I prove that I am me when I pay bills over the phone? Did some else call to pay my bills, and if they did, why don''t you let them?';
  SQS[38] := 'Never take life seriously. Nobody gets out alive anyway.';
  SQS[39] := 'My mind not only wanders, sometimes it leaves completely!';
  SQS[40] := 'What type of exercise do lazy people do? Diddly squats.';
  SQS[41] := 'If every day is a gift, then today I got socks.';
  SQS[42] := 'I remember years ago when all I wanted is to be older. I was wrong!';
  SQS[43] := 'I''m on that new diet where you eat anything you want and you pray for a miracle.';  
  
  Randomize;
  R := Random * SqMax;
  I := Round (R);
  
  Write (T, '<P><CENTER><FONT SIZE=-2>');

  SQ := SQS[I];
  Write (T, SQ);  
  Write (T, '</FONT></CENTER></P>');
{$ENDIF}
  
  xEnd := getTickCount64;
  xDiff := (xEnd - xStart) / 1000;
  Write (T, '<P/><HR><I><FONT SIZE=-1>', LL1, OSVersion, LL2, xDiff:3:2, LL3);
  Write (T, '<BR/>$Program compiled at ' + CTime + ' (local time) on ' + CDate + '<BR>');
  Write (T, '$Get the source code from <A HREF="', URL_TVList_Source, '" TARGET="_BLANK">github.com</A><BR>');
  Write (T, '$BitCoin Donate&nbsp;<A HREF="bitcoin:', MyBitCoin, '">', MyBitCoin, '</A></I>');
  WriteLn (T, '</FONT></FONT>');

{$IFDEF EASTEREGG2}
  WriteLn (T, '<P/ ALIGN="RIGHT"><A HREF="https://www.cultdeadcow.com/" TARGET=_BLANK>&pi;</A>');
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

PROCEDURE Prog_Message;
BEGIN
  L1 := ProgName + ' ' + ProgVer + ' - ' + ProgDesc + ' - Created by ' + ProgAuthor + '. Build ' + ProgDate;
  L2 := ' Copyright ' + ProgAuthor + ', 2015-20' + ProgDate[3] + ProgDate[4] + '. All Rights Reserved. Distributed under an MIT license.';
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
  PROCEDURE _Showday(SS: String; C: Char);
  BEGIN
    Inc (EZTVPageCount);
    ShowDay := SS;
	EZTVDay[EZTVPageCount] := C;
  END;
BEGIN
  WHILE NOT Eof (S) DO
    BEGIN
      REPEAT
        ReadLn (S, W);
		ExtractComments;
      UNTIL (W[1] <> '#') OR Eof(S);
      ShowDay := '<B><FONT COLOR=' + StatusUnknown + '>&#91;UNKWN&#93;</FONT></B>';
      IF W[2] = '|' THEN
        BEGIN
          CASE UpCase(W[1]) OF
            '0' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>S------</FONT></B>', '0');
            '1' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>-M-----</FONT></B>', '1');
            '2' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>--T----</FONT></B>', '2');
            '3' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>---W---</FONT></B>', '3');
            '4' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>----T--</FONT></B>', '4');
            '5' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>-----F-</FONT></B>', '5');
            '6' : _ShowDay('<B><FONT COLOR=' + StatusRunning + '>------S</FONT></B>', '6');
            'Y' : _ShowDay('<B><FONT COLOR=' + StatusBreak + '>&#91;BREAK&#93;</FONT></B>', 'Y');
            'Z' : _ShowDay('<B><FONT COLOR=' + StatusEnded + '>&#91;ENDED&#93;</FONT></B>', 'Z');
          END;
          Delete (W, 1, 2);
        END;
      V := Pos (',', W);
      IF V > 1 THEN
        BEGIN
          XN := '';
          FOR I := 1 TO (V - 1) DO
            XN := XN + W[I];
          Write (T, '<TR');

          IF NOT DisplayHighlight THEN
		    BEGIN
    		  IF (LineCount MOD 2) = 0 THEN
	    	    Write (T, ' BGCOLOR=', Line1_BGColor)
		      ELSE
		        Write (T, ' BGCOLOR=', Line2_BGColor);
			END;

		  Write (T, '><TD>');
		  IF ComText <> '' THEN
		    Write (T, '<DIV TITLE="', ComText, '"><FONT COLOR=', ComText_Color, '>');
          Write (T, XN);
		  IF ComText <> '' THEN
		    Write (T, '</FONT></DIV>');
		  Write (T, '</TD>');

          XL := '';
          FOR I := (V + 1) TO Length (W) DO
            XL := XL + W[I];


          Write (T, TDStr + '<TT>', ShowDay, '</TT></TD>');

		  Write (T, TDStr);
		  IF XL <> '0//' THEN
		    BEGIN
              Write (T, '<A HREF="', LinkURL[ 1], '/shows/', XL, '" TARGET="_BLANK">Info</A>,&nbsp;');
			  IF EZTVPageCount < EZTVPageMax THEN
                BEGIN
	              EZTVPage[EZTVPageCount] := LinkURL[1] + '/shows/' + XL;
	            END;
			END;
		  Write (T, '<A HREF="', LinkURL[ 2], RepSpaceStr('-', XN), '" TARGET="_BLANK">Search</A></TD>');

		  Write (T,  TDStr + '<A HREF="', LinkURL[15], RepSpaceStr('+', XN), '+%2BTV+%2BShow" TARGET="_BLANK">Google</A>');

          Write (T, TDStr + '<A HREF="', LinkURL[ 3], RepSpaceStr('+', XN), '" TARGET="_BLANK">PirateBay</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[10], XN, '/" TARGET="_BLANK">LimeTor</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 9], RepSpaceStr('+', XN), '" TARGET="_BLANK">ExtraTor</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[16], RepSpaceStr('+', XN), '" TARGET="_BLANK">TorGalaxy</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[13], RepSpaceStr('+', XN), '&safe=1" TARGET="_BLANK">Torz2</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[14], RepSpaceStr('+', XN), '/1/" TARGET="_BLANK">1337x</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[11], RepSpaceStr('-', XN), '" TARGET="_BLANK">NextEpisode</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 4], XN, '" TARGET="_BLANK">TVcom</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 8], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVfinale</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 5], XN, '" TARGET="_BLANK">Variety</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 6], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVLine</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 7], RepSpaceStr('+', XN), '.html" TARGET="_BLANK">YesMovies</A>&nbsp;');
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
  Write_Footer;
  Close (S);
  Close (T);
END;

BEGIN
  GetDateTime;
  VARInit;
  Prog_Message;
  ProcessFilesOpen;
  IF DisplayHighlight THEN
    WriteLn (T, '<TBODY>');
  ProcessData;
  IF DisplayHighlight THEN
    WriteLn (T, '</TBODY>');
  ProcessFilesClose;
END.
