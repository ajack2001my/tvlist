{$DEFINE MASKLINKS}
{$DEFINE ALTCOLORROWS}

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
  ProgVer              = 'v0.8';
  ProgDate             = '20180107';
  ProgAuthor           = 'Adrian Chiang';
  ProgDesc             = 'A Torrent TV Series Manager';

  HTML_FontName        = 'Calibri';
  
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

  URL_EZTV           = 'https://eztv.ag';
  URL_TPB            = 'https://thepiratebay.org';
  URL_TV             = 'http://www.tv.com';
  URL_Variety        = 'http://variety.com';
  URL_TVLine         = 'http://tvline.com';
  URL_YesMovies      = 'https://yesmovies.to';
  URL_TVSeriesFinale = 'https://tvseriesfinale.com';
  URL_ExtraTorrent   = 'https://extratorrent.ag';
  URL_LimeTorrent    = 'https://nntorrent.com';
  URL_MKVTV          = 'http://mkvtv.net';
  URL_Openload       = 'http://openloadmovies.tv';
  URL_Torz2          = 'https://torrentz2.eu';
  URL_Leetx          = 'http://1337x.to';
  URL_Google         = 'https://www.google.com';
  URL_ReturnDates    = 'https://www.returndates.com';
  
  URL_TVList_Source  = 'https://www.github.com/ajack2001my/tvlist';
  
  Link_EZTV             = URL_EZTV;
  Link_EZTV_Search      = URL_EZTV + '/search/';
  Link_TPB              = URL_TPB + '/search/';
  Link_TVcom            = URL_TV + '/search?q=';
  Link_Variety_Search   = URL_Variety + '/results/#?q=';
  Link_TVLine           = URL_TVLine + '/tag/'; 
  Link_YesMovies_Search = URL_YesMovies + '/search/';
  Link_TVSF             = URL_TVSeriesFinale + '/tv-show/';
  Link_ExtraTorrent     = URL_ExtraTorrent + '/search/?search=';
  Link_LimeTorrent      = URL_LimeTorrent + '/search/all/';
  Link_MKVTV            = URL_MKVTV + '/?s=';
  Link_Openload         = URL_Openload + '/?s=';
  Link_Torz2            = URL_Torz2 + '/verified?f=';
  Link_Leetx            = URL_Leetx + '/search/';
  Link_Google           = URL_Google + '/search?&q=';
  
  TDStr = '<TD ALIGN="CENTER">';

  TVListString = 'tvlist';
  TVList_Data  = TVListString + '.txt';
  TVList_HTML  = TVListString + '.htm';
  
  Header_Color   = '"#FFFFFF"';
  Header_BGColor = '"#000000"';
  Link_Color     = '"#5F5F5F"';
  VLink_Color    = '"#000000"';
  Line1_BGColor  = '"#BBBBBB"';
  Line2_BGColor  = '"#DDDDDD"';
  
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
  T         : Text;
  LineCount,
  V,
  I         : Word;
  ShowDay,
  L1,
  L2,
  L3,
  W,
  XN,
  XL        : String;
  xHo,
  xMi,
  xSe,
  xuSe,
  xYe,
  xMo,
  xDa,
  xuDa      : Word;
  xStart, 
  xEnd      : QWord;
  xDiff     : Real;

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
  WriteLn (T, '<HTML><HEAD><TITLE>', ProgName, ' ', ProgVer, 
           '</TITLE><LINK REL="icon" TYPE="image/png" HREF="', TVListPNGName, '" /></HEAD>');
  Write   (T, '<BODY');

{$IFDEF MASKLINKS}  
  Write   (T, ' LINK=', Link_Color, ' ALINK=', VLink_Color, ' VLINK=', VLink_Color);
{$ENDIF} 
 
  WriteLn (T, '>');
END;

PROCEDURE Write_Headers;
BEGIN
  WriteLn (T, '<FONT FACE="', HTML_FontName, '">');
  WriteLn (T, '<FONT SIZE=+1>', L1, '<BR>');
  WriteLn (T, '&copy;' + L2 + '<P></FONT>');
  WriteLn (T, '<FONT SIZE=-1><I>' + L3 + '</I><BR>');

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
  Write (T, 'Homepages for <TT>');

  Write (T, '<A HREF="', URL_EZTV, '" TARGET="_BLANK">EZTV</A>,&nbsp;');
  Write (T, '<A HREF="', URL_TPB, '" TARGET="_BLANK">The Pirate Bay</A>,&nbsp;');
  Write (T, '<A HREF="', URL_MKVTV, '" TARGET="_BLANK">MKVTV</A>,&nbsp;');
  Write (T, '<A HREF="', URL_LimeTorrent, '" TARGET="_BLANK">Lime Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL_ExtraTorrent, '" TARGET="_BLANK">Extra Torrent</A>,&nbsp;');
  Write (T, '<A HREF="', URL_Torz2, '" TARGET="_BLANK">Torrentz2</A>,&nbsp;');
  Write (T, '<A HREF="', URL_Leetx, '" TARGET="_BLANK">1337x</A>,&nbsp;');
  Write (T, '<A HREF="', URL_TV, '" TARGET="_BLANK">TV</A>,&nbsp;');
{
  Write (T, '<BR>', RepeatStr ('&nbsp;', 13));
}
  Write (T, '<A HREF="', URL_Variety, '" TARGET="_BLANK">Variety</A>,&nbsp;');
  Write (T, '<A HREF="', URL_TVLine, '" TARGET="_BLANK">TV Line</A>,&nbsp;');
  Write (T, '<A HREF="', URL_TVSeriesFinale, '" TARGET="_BLANK">TV Series Finale</A>,&nbsp;');
  Write (T, '<A HREF="', URL_Openload, '" TARGET="_BLANK">Openload</A>,&nbsp;');
  Write (T, '<A HREF="', URL_ReturnDates, '" TARGET="_BLANK">Return Dates</A>,&nbsp;');
  
  Write (T, 'and&nbsp;');
  
  Write (T, '<A HREF="', URL_YesMovies, '" TARGET="_BLANK">Yes Movies</A>');

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
  L2 := ' Copyright ' + ProgAuthor + ', 2015-20' + ProgDate[3] + ProgDate[4] + '. All Rights Reserved.';
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

PROCEDURE ProcessData;
BEGIN
  WHILE NOT Eof (S) DO
    BEGIN
      REPEAT
        ReadLn (S, W);
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

{$IFDEF ALTCOLORROWS}
		  IF (LineCount MOD 2) = 0 THEN
		    Write (T, ' BGCOLOR=', Line1_BGColor)
		  ELSE	
		    Write (T, ' BGCOLOR=', Line2_BGColor);
{$ENDIF}

		  Write (T, '><TD>', XN, '</TD>');
		
          XL := '';
          FOR I := (V + 1) TO Length (W) DO
            XL := XL + W[I];


          Write (T, TDStr + '<TT>', ShowDay, '</TT></TD>');
        
		  Write (T, TDStr);
		  IF XL <> '0//' THEN
            Write (T, '<A HREF="', Link_EZTV, '/shows/', XL, '" TARGET="_BLANK">Info</A>,&nbsp;');
          
		  Write (T, '<A HREF="', Link_EZTV_Search, RepSpaceStr('-', XN), '" TARGET="_BLANK">Search</A></TD>');
		
		  Write (T,  TDStr + '<A HREF="', Link_Google, RepSpaceStr('+', XN), '+%2BTV+%2BShow" TARGET="_BLANK">Google</A>');
		
          Write (T, TDStr + '<A HREF="', Link_TPB, XN, '/" TARGET="_BLANK">PirateBay</A>,&nbsp;');
          Write (T, '<A HREF="', Link_MKVTV, RepSpaceStr('+', XN), '" TARGET="_BLANK">MkvTV</A>,&nbsp;');
          Write (T, '<A HREF="', Link_LimeTorrent, XN, '/" TARGET="_BLANK">LimeTor</A>,&nbsp;');
          Write (T, '<A HREF="', Link_ExtraTorrent, RepSpaceStr('+', XN), '" TARGET="_BLANK">ExtraTor</A>,&nbsp;');
          Write (T, '<A HREF="', Link_Torz2, RepSpaceStr('+', XN), '&safe=1" TARGET="_BLANK">Torz2</A>,&nbsp;');
          Write (T, '<A HREF="', Link_Leetx, RepSpaceStr('+', XN), '/1/" TARGET="_BLANK">1337x</A></TD>');
		
          Write (T, TDStr + '<A HREF="', Link_TVcom, XN, '" TARGET="_BLANK">TVcom</A>,&nbsp;');
          Write (T, '<A HREF="', Link_TVSF, RepSpaceStr('-', XN), '" TARGET="_BLANK">TVfinale</A></TD>');
		
          Write (T, TDStr + '<A HREF="', Link_Variety_Search, XN, '" TARGET="_BLANK">Variety</A>,&nbsp;');
          Write (T, '<A HREF="', Link_TVLine, RepSpaceStr('-', XN), '" TARGET="_BLANK">TVLine</A></TD>');
		
          Write (T, TDStr + '<A HREF="', Link_YesMovies_Search, RepSpaceStr('+', XN), '.html" TARGET="_BLANK">YesMovies</A>,&nbsp;');
          Write (T, '<A HREF="', Link_Openload, RepSpaceStr('+', XN), '" TARGET="_BLANK">Openload</A></TD>');

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
  Prog_Message;
  ProcessFilesOpen;
  CheckForProgIcon;
  ProcessData;
  ProcessFilesClose;
END.
