PROGRAM TVList;

USES
  CRT,
  DOS,
  SysUtils;

CONST
  ProgName = 'TV List';
  ProgVer = 'v0.5';
  ProgDate = '20171025';

  LinkEZTV = 'https://eztv.ag';
  LinkEZTV_Search = 'https://eztv.ag/search/';
  LinkTPB = 'https://thepiratebay.org/search/';
  LinkTVcom = 'http://www.tv.com/search?q=';

VAR
  S,
  T         : Text;
  V,
  I         : Word;
  ShowDay,
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

PROCEDURE Write_Headers;
BEGIN
  WriteLn (T, '<HTML><HEAD><TITLE>', ProgName, ' ', ProgVer, 
           '</TITLE><LINK REL="icon" TYPE="image/png" HREF="tvlist.png" /></HEAD><BODY>');
END;

PROCEDURE Write_Headers2;
BEGIN
  WriteLn (T, '<TABLE BORDER=1>');
  WriteLn (T, '<TR><TH ALIGN="LEFT">Show</TH><TH ALIGN="LEFT">EZTV Link</TH><TH ALIGN="LEFT">' +
              'EZTV Search</TH><TH ALIGN="LEFT">The Pirate Bay</TH><TH>TV.com</TH><TH>Airs</TH></TR>');
END;

PROCEDURE Write_Footer;
BEGIN
  WriteLn (T, '</BODY></HTML>');
END;

FUNCTION Num2Day (N: Word): String;
VAR
  X : String;
BEGIN
  CASE N OF
    0 : X := 'Sunday';
	1 : X := 'Monday';
	2 : X := 'Tuesday';
	3 : X := 'Wednesday';
	4 : X := 'Thursday';
	5 : X := 'Friday';
	6 : X := 'Saturday';
  END;
  Num2Day := X;
END;

FUNCTION Num2Month (N: Word): String;
VAR
  X : String;
BEGIN
  CASE N OF
    1 : X := 'Jan';
	2 : X := 'Feb';
	3 : X := 'Mar';
	4 : X := 'Apr';
	5 : X := 'May';
	6 : X := 'Jun';
	7 : X := 'Jul';
	8 : X := 'Aug';
	9 : X := 'Sep';
	10 : X := 'Oct';
	11 : X := 'Nov';
	12 : X := 'Dec';
  END;
  Num2Month := X;
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

FUNCTION I2S (I:Integer):String;
VAR
  X : String;
  J : Integer;
BEGIN
  J := I;
  IF J < 0 THEN
    J := J * -1;
  Str (J, X);
  IF I < 0 THEN
    X := '+' + X
  ELSE
    X := '-' + X;
  I2S := X;
END;


PROCEDURE Prog_Message;
VAR
  L1,
  L2,
  L3 : String;
BEGIN
  L1 := ProgName + ' ' + ProgVer + ' - Created by Adrian Chiang. Date: ' + ProgDate;
  L2 := '&copy; Copyright Adrian Chiang, 2015-2017. All Rights Reserved.';
  L3 := 'List generated on ' + Num2Day(xuDa) + ', ' + Num2Str(xDa) + '-' + Num2Month(xMo) + '-' +
        Num2Str(xYe) + ', ' + Num2Str(xHo) + ':' + Num2Str(xMi) + ':' + Num2Str(xSe) + ' UTC' + 
		I2S(GetLocalTimeOffset Div 60);

  WriteLn (L1);
  WriteLn (L2);
  WriteLn;
  WriteLn (L3);

  WriteLn (T, '<FONT SIZE=+1>', L1, '<BR>');
  WriteLn (T, L2 + '<P></FONT>');
  WriteLn (T, '<FONT SIZE=-1><I>' + L3 + '</I><P></FONT>');
  WriteLn;
END;

PROCEDURE GetDateTime;
BEGIN
  GetDate (xYe, xMo, xDa, xuDa);
  GetTime (xHo, xMi, xSe, xuSe);
END;

FUNCTION DashSpace (X: String): String;
VAR
  I : Word;
BEGIN
  FOR I := 1 TO Length(X) DO
    IF X[I] = ' ' THEN
      X[I] := '-';
  DashSpace := X;
END;

PROCEDURE ProcessFilesOpen;
BEGIN
  Assign (S, 'tvlist.txt');
  Assign (T, 'tvlist.htm');
  Reset (S);
  ReWrite (T);
  Write_Headers;
  Prog_Message;
  Write_Headers2;
END;

PROCEDURE ProcessData;
BEGIN
  WHILE NOT Eof (S) DO
    BEGIN
      REPEAT
        ReadLn (S, W);
      UNTIL (W[1] <> '#') OR Eof(S);
  ShowDay := '.......';
  IF W[2] = '|' THEN
    BEGIN
      CASE W[1] OF
        '0' : ShowDay := '<B>S</B>......';
        '1' : ShowDay := '.<B>M</B>.....';
        '2' : ShowDay := '..<B>T</B>....';
        '3' : ShowDay := '...<B>W</B>...';
        '4' : ShowDay := '....<B>T</B>..';
        '5' : ShowDay := '.....<B>F</B>.';
        '6' : ShowDay := '......<B>S</B>';
      END;
      Delete (W, 1, 2);
    END;
    V := Pos (',', W);
    IF V > 1 THEN
      BEGIN
        XN := '';
        FOR I := 1 TO (V - 1) DO
          XN := XN + W[I];
        Write (T, '<TR><TD>', XN, '</TD>');
        XL := '';
        FOR I := (V + 1) TO Length (W) DO
          XL := XL + W[I];
        IF XL <> '0//' THEN
          Write (T, '<TD><A HREF="', LinkEZTV, '/shows/', XL, '" TARGET="_BLANK">EZTV</A></TD>')
        ELSE
          Write (T, '<TD></TD>');
        Write (T, '<TD><A HREF="', LinkEZTV_Search, DashSpace(XN), '" TARGET="_BLANK">Search</A></TD>');
        Write (T, '<TD><A HREF="', LinkTPB, XN, '/" TARGET="_BLANK">TPB</A></TD>');
        Write (T, '<TD><A HREF="', LinkTVcom, XN, '" TARGET="_BLANK">TV</A></TD>');
        Write (T, '<TD><TT>', ShowDay, '</TT></TD>');
        WriteLn (T, '</TR>');
        Write ('.');
      END
    ELSE
      Write ('X');
    END;
END;

PROCEDURE ProcessFilesClose;
BEGIN
  Write_Footer;
  Close (S);
  Close (T);
END;

BEGIN
  GetDateTime;
  ProcessFilesOpen;
  ProcessData;
  ProcessFilesClose;
END.

