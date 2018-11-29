{

CSS Highlight code adapted from 

  URL http://www.java2s.com/Tutorials/HTML_CSS/Table/Style/Highlight_both_column_and_row_on_hover_in_CSS_only_in_HTML_and_CSS.htm

}

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
  ProgVer              = 'v0.9.2';
  ProgDate             = '20181129';
  ProgAuthor           = 'Adrian Chiang';
  ProgDesc             = 'An EZTV Series Manager';
  
  MyBitCoin            = '1FSMJRMk65o25frAsBoMYoZEZMkqncQ4Jm';
    
  CTime                = {$I %TIME%};
  CDate                = {$I %DATE%};

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


  URL_TVList_Source  = 'https://www.github.com/ajack2001my/tvlist';
  
 
  TDStr = '<TD ALIGN="CENTER">';

  TVListString  = 'tvlist';
  TVList_Data   = TVListString + '.txt';
  TVList_HTML   = TVListString + '.htm';
  TVList_Config = TVListString + '.cfg';
  TVListLnkName = TVListString + '.urk';
  TVListLnkSize = 16;
  
  TVListPNGSize = 279;
  TVListPNGName = TVListString + '.png';
  TVListPNG: Array [1..TVListPNGSize] of Byte = (137,  80,  78,  71,  13,  10,  26,  10,   0,   0, 
                                                   0,  13,  73,  72,  68,  82,   0,   0,   0,  16, 
                                                   0,   0,   0,  16,   8,   6,   0,   0,   0,  31, 
                                                 243, 255,  97,   0,   0,   0,   6,  98,  75,  71, 
                                                  68,   0, 255,   0, 255,   0, 255, 160, 189, 167, 
                                                 147,   0,   0,   0,   9, 112,  72,  89, 115,   0, 
                                                   0,  11,  19,   0,   0,  11,  19,   1,   0, 154, 
                                                 156,  24,   0,   0,   0,   7, 116,  73,  77,  69,
                                                   7, 225,  10,  25,  10,  41,  25,  91, 215, 208, 
                                                 206,   0,   0,   0, 164,  73,  68,  65,  84,  56, 
                                                 203, 173, 146, 209,  13, 195,  32,  12,  68, 239, 
                                                  60, 107,   6,  65, 140, 145,  17, 146,   5, 186, 
                                                 221, 245, 163,  49, 114, 138,  67, 136,  90,  36, 
                                                 139,   4, 124, 167, 103,  99,   2, 194, 179,  69, 
                                                   1, 162, 255, 217,  47, 226, 129,   1,  53,  35,
                                                  30,  24, 136, 103, 147,  92,  12,   0,  28, 247, 
                                                 192,  77, 114, 113,  48, 224, 211,  78,  54,  82, 
                                                 115, 241, 182,  97, 149, 132, 171,  88,  22, 188, 
                                                  50,  66, 226, 168,  65, 186, 135,  32, 251,  74, 
                                                  44, 138,  73, 182, 136,   2, 223,  61, 207, 169, 
                                                 186,  87, 136,   9, 179, 107,  56,  72, 146,  64, 
                                                 178,  51, 220, 119, 174, 141, 238, 147,  39, 100, 
                                                  36,  89, 205, 209, 144, 228, 153, 192,   5, 102, 
                                                 134,  90, 107, 215, 147, 152,  23, 207, 116,  80, 
                                                 200, 191,  61,  74,  41, 237,  46, 187, 247,   9, 
                                                 211,  55, 250, 236,  19, 254, 101,  18, 223,  20, 
                                                  96, 119,  93, 183,   5, 255,  27,   0,   0,   0,
                                                   0,  73,  69,  78,  68, 174,  66,  96, 130);
  
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
  DHighlight,
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
  DisplayHighlight  : Boolean;

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
	WHILE (P[1] = ' ') AND (Length(P) > 1) DO 
	  Delete (P, 1, 1);
    Delete (P, 1, Length(S) + 1);
	I := Pos(' ', P);
	IF I > 1 THEN
	  Delete (P, I, (Length(P) - I) + 1);
    N := P;	
  END;
BEGIN
  URL[ 1] := 'https://eztv.io';                            {URL_EZTV}
  URL[ 2] := 'https://thepiratebay.org';                   {URL_ThePirateBay}
  URL[ 3] := 'http://www.tv.com';
  URL[ 4] := 'http://variety.com';
  URL[ 5] := 'http://tvline.com';
  URL[ 6] := 'https://yesmovies.to';                       {URL_YesMovies}
  URL[ 7] := 'https://tvseriesfinale.com';
  URL[ 8] := 'https://extratorrent.ag';                    {URL_ExtraTorrent}
  URL[ 9] := 'https://cachetorrent.com';                   {URL_LimeTorrent}
  URL[10] := 'http://www1.123movies.cc';                   {URL_123Movies}
  URL[11] := 'http://openloadmovies.tv';                   {URL_Openload}
  URL[12] := 'https://torrentz2.eu';                       {URL_TorrentZ2}
  URL[13] := 'http://1337x.to';                            {URL_1337x}
  URL[14] := 'https://www.google.com';                     {URL_Google}
  URL[15] := 'https://www.returndates.com';
  URL[16] := 'https://torrentgalaxy.org';                  {URL_TorGalaxy}

  HTML_FontName     := 'Calibri';  
  Header_Color      := '"#FFFFFF"';
  Header_BGColor    := '"#000000"';
  CSS_Link_Color   := '#000';
  CSS_VLink_Color  := '#666';
  Line1_BGColor     := '"#FFFFFF"';
  Line2_BGColor     := '"#D0D0D0"';
  ComText_Color     := '"#FF0000"';
  Highlight_BGColor := '#FF0';
  
  DHighlight := '';
  DisplayHighlight := True;

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
 	    		    _UpdateVAR (DHighlight, 'Highlight', X);
					IF UpCase(DHighlight[1]) = 'Y' THEN
					  DisplayHighlight := True
					ELSE  
					  DisplayHighlight := False;
				  END;
				  
    			IF Pos ('URL_YesMovies=', X) > 0 THEN
	    		  _UpdateVAR (URL[6], 'URL_YesMovies', X);
    			IF Pos ('URL_123Movies=', X) > 0 THEN
	    		  _UpdateVAR (URL[10], 'URL_123Movies', X);
    			IF Pos ('URL_Openload=', X) > 0 THEN
	    		  _UpdateVAR (URL[11], 'URL_Openload', X);
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
			  END;
		  END;
		Close (C);  
	END;
  LinkURL[ 1] := URL[ 1];
  LinkURL[ 2] := URL[ 1] + '/search/';
  LinkURL[ 3] := URL[ 2] + '/search/';
  LinkURL[ 4] := URL[ 3] + '/search?q=';
  LinkURL[ 5] := URL[ 4] + '/results/#?q=';
  LinkURL[ 6] := URL[ 5] + '/tag/'; 
  LinkURL[ 7] := URL[ 6] + '/search/';
  LinkURL[ 8] := URL[ 7] + '/tv-show/';
  LinkURL[ 9] := URL[ 8] + '/search/?search=';
  LinkURL[10] := URL[ 9] + '/search/all/';
  LinkURL[11] := URL[10] + '/?s=';
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
  WriteLn (T, '<HTML><HEAD><META CHARSET="UTF-8"/><TITLE>', ProgName, ' ', ProgVer, 
           '</TITLE><LINK REL="icon" TYPE="image/png" HREF="', TVListPNGName, '" />');

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
	
  Write   (T, '</HEAD><BODY>');
END;

PROCEDURE Write_Headers;
BEGIN
  WriteLn (T, '<FONT FACE="', HTML_FontName, '">');
  WriteLn (T, '<FONT SIZE=+1>', L1, '<BR>');
  WriteLn (T, '&copy;' + L2 + '<P></FONT>');
  WriteLn (T, '<FONT SIZE=-1><I>' + L3 + '</I><BR>');
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
BEGIN
  Write (T, '<TT>Homepages for&nbsp;');

  Write (T, '<A HREF="', URL[ 1], '" TARGET="_BLANK">EZTV</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 2], '" TARGET="_BLANK">The Pirate Bay</A>,&nbsp;');
{  
  Write (T, '<A HREF="', URL[10], '" TARGET="_BLANK">MKVTV</A>,&nbsp;');
}
  Write (T, '<A HREF="', URL[ 9], '" TARGET="_BLANK">Lime Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL[16], '" TARGET="_BLANK">Torrent Galaxy</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 8], '" TARGET="_BLANK">Extra Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL[12], '" TARGET="_BLANK">Torrentz2</A>,&nbsp;');
  Write (T, '<A HREF="', URL[13], '" TARGET="_BLANK">1337x</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 3], '" TARGET="_BLANK">TV</A>,&nbsp;');
{
  Write (T, '<BR>', RepeatStr ('&nbsp;', 13));
}
  Write (T, '<A HREF="', URL[ 4], '" TARGET="_BLANK">Variety</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 5], '" TARGET="_BLANK">TV Line</A>,&nbsp;');
  Write (T, '<A HREF="', URL[ 7], '" TARGET="_BLANK">TV Series Finale</A>,&nbsp;');
  Write (T, '<A HREF="', URL[11], '" TARGET="_BLANK">Openload</A>,&nbsp;');
  Write (T, '<A HREF="', URL[15], '" TARGET="_BLANK">Return Dates</A>,&nbsp;');
  
  Write (T, 'and&nbsp;');
  
  Write (T, '<A HREF="', URL[ 6], '" TARGET="_BLANK">Yes Movies</A>');

  WriteLn (T, '</TT>');
END;

PROCEDURE Write_Footer;
BEGIN
  WriteLn (T, '</TABLE><P>');
  Write_Bookmarks;
  xEnd := getTickCount64;
  xDiff := (xEnd - xStart) / 1000;
  Write (T, '<P><I><BR><FONT SIZE=-1>', LL1, OSVersion, LL2, xDiff:3:2, LL3);
  Write (T, '<BR/>$Program compiled at ' + CTime + ' (local time) on ' + CDate + '<BR>');
  Write (T, '$Get the source code from <A HREF="', URL_TVList_Source, '" TARGET="_BLANK">github.com</A><BR>');
  Write (T, '$BitCoin Donate&nbsp;<A HREF="bitcoin:', MyBitCoin, '">', MyBitCoin, '</A></I>');
  WriteLn (T, '</FONT></FONT>');
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
BEGIN
  WHILE NOT Eof (S) DO
    BEGIN
      REPEAT
        ReadLn (S, W);
		ExtractComments;
      UNTIL (W[1] <> '#') OR Eof(S);
      ShowDay := '<B>&#91;UNKWN&#93;</B>';
      IF W[2] = '|' THEN
        BEGIN
          CASE UpCase(W[1]) OF
            '0' : ShowDay := '<B>S------</B>';
            '1' : ShowDay := '<B>-M-----</B>';
            '2' : ShowDay := '<B>--T----</B>';
            '3' : ShowDay := '<B>---W---</B>';
            '4' : ShowDay := '<B>----T--</B>';
            '5' : ShowDay := '<B>-----F-</B>';
            '6' : ShowDay := '<B>------S</B>';
            'Y' : ShowDay := '<B>&#91;BREAK&#93;</B>';
            'Z' : ShowDay := '<B>&#91;ENDED&#93;</B>';
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
            Write (T, '<A HREF="', LinkURL[ 1], '/shows/', XL, '" TARGET="_BLANK">Info</A>,&nbsp;');
		  Write (T, '<A HREF="', LinkURL[ 2], RepSpaceStr('-', XN), '" TARGET="_BLANK">Search</A></TD>');

		  Write (T,  TDStr + '<A HREF="', LinkURL[15], RepSpaceStr('+', XN), '+%2BTV+%2BShow" TARGET="_BLANK">Google</A>');

          Write (T, TDStr + '<A HREF="', LinkURL[ 3], XN, '/" TARGET="_BLANK">PirateBay</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[10], XN, '/" TARGET="_BLANK">LimeTor</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 9], RepSpaceStr('+', XN), '" TARGET="_BLANK">ExtraTor</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[16], RepSpaceStr('+', XN), '" TARGET="_BLANK">TorGalaxy</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[13], RepSpaceStr('+', XN), '&safe=1" TARGET="_BLANK">Torz2</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[14], RepSpaceStr('+', XN), '/1/" TARGET="_BLANK">1337x</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 4], XN, '" TARGET="_BLANK">TVcom</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 8], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVfinale</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 5], XN, '" TARGET="_BLANK">Variety</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[ 6], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVLine</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 7], RepSpaceStr('+', XN), '.html" TARGET="_BLANK">YesMovies</A>,&nbsp;');
          Write (T, '<A HREF="', LinkURL[12], RepSpaceStr('+', XN), '" TARGET="_BLANK">Openload</A></TD>');

          WriteLn (T, '</TR>');
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

PROCEDURE CheckForProgIcon;
VAR 
  F : File;
BEGIN
  Write ('Checking for file ', TVListPNGName, '... ');
  IF NOT FileExists (TVListPNGName) THEN
    BEGIN
	  Write ('Creatings... ');
	  Assign (F, TVListPNGName);
	  ReWrite (F, 1);
	  BlockWrite (F, TVListPNG, TVListPNGSize);
	  Close (F);
	  WriteLn ('Done!');
	END
  ELSE 
    WriteLn ('Found, skipped!');
  WriteLn;	
END;

BEGIN
  GetDateTime;
  VARInit;
  Prog_Message;
  ProcessFilesOpen;
  CheckForProgIcon;
  IF DisplayHighlight THEN
    WriteLn (T, '<TBODY>');
  ProcessData;
  IF DisplayHighlight THEN
    WriteLn (T, '</TBODY>');
  ProcessFilesClose;
END.
