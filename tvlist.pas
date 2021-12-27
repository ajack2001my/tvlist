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
{$IFDEF MSWINDOWS}
  {$R tvlist.rc}
{$ENDIF}

{$DEFINE EASTEREGG1}
{$DEFINE EASTEREGG2}
{$DEFINE DNSHELP8888}
{$DEFINE BROWSERHELP}
{$DEFINE ANIMESEARCH}
{$DEFINE xCUSTOMSEARCH}


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
  ProgVer         = 'v0.9.9';
  ProgDate        = '20211227';
  ProgAuthor      = 'Adrian Chiang';
  ProgDesc        = 'An EZTV Series Manager';

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
  Desc_Airs       = 'Day show airs, between seasons, mid-season break, ended or unknown.';
  Desc_General    = 'Search in Google for your TV dramas.';
  Desc_DNS8888    = 'Click to learn how to change the DNS address to your own choosing.';
  Desc_Firefox2   = 'In ''about:config'', change ''dom.block_multiple_popups'' to ''false''';
  Desc_Chrome2    = 'Chrome will alert you with a ''Pop-ups were blocked on this page'' icon, click the icon ' +
                    'and select ''Always allow pop-ups and redirects...''';
  Desc_Opera2     = 'Opera will alert you with a ''Pop-up blocked'' icon, click the icon and select ''Always allow pop-ups from...''';
  
  URL_TVList_Source  = 'https://www.github.com/ajack2001my/tvlist';
  URL_HOWTO_DNS      = 'https://www.howtogeek.com/167533/the-ultimate-guide-to-changing-your-dns-server/';


  TDStr         = '<TD ALIGN="CENTER">';
  HTMLSpace     = '&nbsp;';
  
  AnimeHiragana = '&#x30a2;&#x30cb;&#x30e1;';
  AnimeFlag     = '^';

  TVListString  = 'tvlist';
  TVList_Data   = TVListString + '.txt';
  TVList_HTML   = TVListString + '.htm';
  TVList_Config = TVListString + '.cfg';

  TVListLnkSize = 16;
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
  AnimeXlateGroup,
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
  Base64New         : Array [1..63] of String;

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

    {* Allow SPACE in names by replacing the '\' character *}
	FOR I := 1 TO Length(P) DO 
      IF P[I] = '\' THEN
        P[I] := ' ';	  

    N := P;
  END;
BEGIN
  Base64New[01] := 'iVBORw0KGgoAAAANSUhEUgAAAD8AAAAQCAYAAAChpac8AAARa3pUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHjarZlpchy5koT/4xRzBOxAHAer2bvBHH8+R5VaLXX3LM9GFFmsZCaW8Ah3D5Q';
  Base64New[02] := '7//mv6/6Dfznm6nJpvVqtnn/ZssXBL91//n1eg8/v5/uX7vdv4dfr7vvqfeRS0p2ft/V87x9cLz8faPl7ff563bX1Had/B/ox8nfApJkjv+zvIr8Dpfi5Hr7vncXPL6P+aTvf79TeEH/c/Pv73A';
  Base64New[03] := 'jGLlxM0cWTQvKfn5+Zkr5DGrw2foYUuTGkyu+Za/qZ/xo/90fo/iaAOfx9/Pz63pF+huMz0I9t1d/i9L0eyt/H70XpzysK8XtL/PmHh9DxP8D+S/zu3f3e89ndUB5Zrt9N/dji+40bJ5tL77HKV';
  Base64New[04] := '+O78Ht7X8ZX98MvAr/Z6nR+8sZCJNY35LDDCDec97rCYok5nth4jXGBga711KLFlQRB1le4sblkaacOTgvkEpfjH2sJb17TfEzWmXkH7oyBwcDy1y/3+4V/9+uXge5VmoegYOZP1FhXVBKyDCGn';
  Base64New[05] := 'n9wFIOF+Y1pefIP7vPjf/wnYBILlhbmzweHnZ4hZws/cSg/n5Ivj1uw/KR/a/g6gBTEXiwkJBHwNqYQafIuxhUAcO/gMVh5TjhMEQnElblYZc0oVcHrU3DzTwrs3lvi5DL0ARKFQGtBYGoCVc8m';
  Base64New[06] := 'Veuuk0HAllVxKqaWVXqyMmmqupdbaqnhqtNRyK6221nqzNnrquZdee+u9Wx8WLUFjxVm1Zt3MxmDSkQdjDe4fXJhxpplnmXW22afNsUiflVdZdbXVl62x404bCnC77rb7tj1OOKTSyaecetrpx8';
  Base64New[07] := '645NpNN99y6223X7vjD9S+qP6K2u/I/feohS9q8QGl+9pP1Ljc2o8hguikCDMQizmAeBMCIidh5nvIOQo5YeYtJpdSiayyCJwdhBgI5hNiueEP7H4i94+4OaL7f8Ut/h1yTtD9fyDnBN2fkPsrb';
  Base64New[08] := 'n+D2h6PbtMDSFVITN1H8rhpxGnAXVuf6R7icyf1Oaib0c4OQHbKOGvP2Sp/Wnefu+Ncs60yT3L13p65dbV7Rbr6OVPbNrmwZt1XT+57CVw6555JJDMzEr/NSqcn8AfUQlsz5rF9a7vlm461eVgI';
  Base64New[09] := 'z5Q+T4Q3fbtAv409cfe9abbGHHnPvmqCusduy52RT+3jNKspzDJi2muUFZlyUUU7z3E2gT5EHxbuUGXQqiFfVmxTv58Vzem32d/bQbh45XFJRGmRUKXp78wV8EYztksFMPq0e2IZNxv03m8auzr';
  Base64New[10] := 'GzWvVkt88pZx9WVaIY6fCVjV3SqugFIMZgdTKi+OykZEThOH2TjilaxarzaAY1HJ5qXnFovD2fW1RI4QC0tpnnJTtptLtGOsepzNFYMBbm1s7TbLjVBIgz0ha13Qn0B7yK1+kJ6+bNrE7gLf26I';
  Base64New[11] := 'CvrR3uqlKeYcpY19IGz7pSRXTGaIBcwWHeTU7asH7D1lYyl3wlJtDtbEbU35Cmv+02rssHXazGhtrGaVSBS52RrESWbNpnjrg933O0MsJWCKjTs8GKvRKfNtY2t6zMtCuFNRBhdvQSk1xn79ezR';
  Base64New[12] := 'eU9ubVaeLOX9l1Dm7dTONGzLgrcJaH2smFcINstcEdtZenpeeqet81QjGQf+/BcOlQHFfOeYaSxSYHj3Ry2UOWbQklNAIRyT4YuKLGeJ+MhH1dVslcaF6p4CTKZ8fh+I9dZ+tnOL8zaatTLS8pb';
  Base64New[13] := 'oA+qKBLo65Oy3SCydfMhImeEUM+Efg4cojhx1Wogti55A53eC3K45zmfFDwNPMAhThgONhArwj6sjERj1EVdpsqaqOlSbLXksB63Hva9JkTE8y/zNsNzaZG1Cxoj9YFw3mOdMJdj8CmkZdffc5M';
  Base64New[14] := 'WXN1tCX6NUGMmCoeH0dyBdBpWKDAkNdD2XR0Id5mZCLIwuJO0zSq/lzEpOFs9APot9TISmOxSkfKlYP9YaXkrhYk2S1zwasvCv8GmpLuC0So+ezF4bAvJuMnYw8tjAljOKoSVNVxxGDGVtswJwY';
  Base64New[15] := 'N3b4GU4tFt1LYFB8B7k8QXojknkcjURa7bcmcJk+QnAyDUDo9x52nkUZy0LZT/iq1OhpzoEyaCGFP9cy9AP6nCwBRuo7BPHZVtFK+wsGMiOCGTpJREayaMjMjVjRYHSgQ4yIUS2MbuDJ9Pihkym';
  Base64New[16] := 'khIeeUi3vuw3uM8CqR/OQmf+mqi++uuQCcKATwtF2i+GHm77kcG8FafapMYUUpkRI0gKULjOmtGm9G86+DuU6AFSTC1BTtNwKIUG41UbfD6IKqIDpNQSmUZ8kNuJNgtDDQ8ZtvBmovxZhBMsAjG';
  Base64New[17] := 'S48cGHNHD2Uh8cLcVOYnyoVG6rEuq0rw9ig0MQjvhhMjRhiJosqfjJhIPpvfiixFuHvX1BtjQVLHg2wNlkWx3QpxAigZH7A1KEaW9Yms60VlwBehvRVQmXY/wjmVa2M/8kCrgIya0/3oFxWJGT2';
  Base64New[18] := 'ITBUvU91w9B4FOjWcwtxknKE9O2RAneGoSg1Q0Txts1ClD4qMZCFH8ClYXHscVo9qc0lCq+R54c/UP4s6IHmIAJ4JeCySG69SUCe2x97cHb0kCw3/YwsbZQUHA+9ZKmB2IbdLkbAcNHLZR6Joi8';
  Base64New[19] := '5Tmw7/Eei5PXxU9qRfe/v1nbxdF9mbj0NJLciROsY6km2NhNOjPEhZU/HCkB6MGIzg6kFF7wJHnp3aWLNJmrSOGl6oYtN+Y5fQJKzGvg39krZYWjhLqLcRhXWaIzLo3h0HtFrZ2iLSRV1Lx6cQ8';
  Base64New[20] := 'ZAQu42tnCktTSQjnHbQKFKiUuMwRXKrNDgzErWbA5B8PADa/zEW82BqTo+sHp9GekFHni2yD0sX0wzjBTIePmJ9F3+jfPKoQ6VNCYZWbnzb3PvdTS2JcxFitBXOK58c6nNmKoyyqjJarLLIO7Il';
  Base64New[21] := '6ANuCDjKM6GjfdFDC0AYZSkI1MJTJPxnTZ3tE2WycMhpyo0gC9QSS0xJgaZWaGrhuwxwh45osXa4rVJolzqGsRA1uAn4sZQVY40vP25T2GkHGCJgXwrfGHOwOeXiIGBXmbIZWzeVDuW3IR5rXbk';
  Base64New[22] := 'LL/u+pCKlOaoRBwrTZ3EgurmJOFWPfvuC5UO3F8wLqbDUUSzAMjAA2nM23J0oi4Mq0WaZDC8eaSrd9tPNgmdAJ9JdkgUQY5sE+OH4qS5M51TuYa1Vx3kNtP9iXjMEwKxIY2AfR/0J9ubKIELiuW';
  Base64New[23] := 'Et9kGu0BSJEzpBQzHxhvCPYrMyWyugRC1gg2hJMDibREVzkBb2SN9A54DpJbik7umkTb2yAggPGghxYFLwzq6T4mQ21gDIPUNXCSJVHPGPlOZ9CUqjQO8ToyzVJH/Hms+lLDyNzORojnbH9opEr';
  Base64New[24] := '4PJ0wYPPQMqiYSHQoI1IDlKLAbBWWRNklDSolAtb5qRmoN7Yh/8hzf8eL/6v76qMpm5Qk4eXaOBiix8Dro9ChkLfBy6D4cCCB3VYzt059L13f5hclUq+vZUgzyUjVkSALDGZVKELJzUng5ygK5h';
  Base64New[25] := 'A5AwCDENNYtUMibamyGFoDbkpo96HLpaVFQrXQuFnzozoAhTcbRynY0Gsl1NVdw4xpShKzMyzzcYk1osROn4WuASHlA1f7qQrEYC3c4yWiYj3vE8H0sqx0oPdZFhKv5SLwPBN/jdz9VPnbSgjN4';
  Base64New[26] := 'RC1DITc1xHMVl2t8Ik+uYlDLA4NELLXiHGqkTwYjIPmpajwKcew+QOg0SfuZDunVBimU7aj/EiHekxCQ/ZHqkyNDDOmRu+5QyeUjndBj1LqhGrVEJH78tItNpp4PLKKWYPrx4JLdoB4ZXxzCgXm';
  Base64New[27] := 'l2dUpJQyg/kmEnnWwxXerk98wLnoo+u8CQNWR4cyN9JH69nhKHu3NAbclcVuo7LJTZpr0SJDRIg29b1dBR7ctAmKBTk9qUaj0+BnhBh38oaiPZCBx1dGnYADGwWt1D6qN5feKmAtW3o+vI56Whf';
  Base64New[28] := '4YUtxW8sXhIu5NAFQ0Yp3SamLQq7UfGciKftcj2ppC77AA57BtbQ4OhEq9dN9QH/SeLNvZ8wdGwR1Vt0XRhRatoq2b1/KTjO82A7aTHzZGqOWVuSB3mN1w/djvjliDg9DzxYnZ8WVIDnvyi5oM6';
  Base64New[29] := '9qnzH6wYBbTzGM7E8DhPqNx2s8zGW4mdt6GWdUrN4hJKlf0nER/aEuhjBo0orhVrSe4hpa5Lz8a0PMEA19YKCVqJRVnLaM7h+Eb9Nwl2hRNLZGzsl0GVMNQ7G9EBhSMHcRoFH48zW4civDnT7oi';
  Base64New[30] := 'EUBcgUi9D9yqMFhmO+NNtIHAWljSmHsxWX45oelVFVLcQ6cggl469ZjIWR7dLA5Ikszw1u1JHp+hDY/MGdzlVBlQ/xiFRKnAkvgJPTIu1sYSNXmOwuCH7Tc8bmbnSxXjrUCltEKRdztHZiRWkYL';
  Base64New[31] := 'gTWC/tDQ2g10xbJ0hUApkVEqU+40OGJdKaosZhfQ4xDJ2oPR0vaqIXcK/k6ADh0b0gvk9et0oKi8extlQAmRoCfRsmUwqNQcffdZYLs4DKpmFwXd3DzXTdRCgN4NkY/by/MtA/rULX4VBtuE4EQ';
  Base64New[32] := 'AcXvCfa/EQbLt6xOZ283V37ePVPgCjeDpvgHIjSyksnhhnrpenqZ1hN+CEPyPQ7pfsxp1KRxKPeUdOtc4E95YewqrgJXHm3i799gk2BU5kZS1LVxvbm84D8sS00u118x1oS0d9400JvT1Jf4M0f';
  Base64New[33] := '7cpve1OW7uf2Bu6KZNvQCNDTPGb6NoznJamYB/5PSUedpPjS6c8IpHeCOoIvHR+HrV90UcoLjBBx3q6HpQ8naklLxyfb+meL9Fdvj/PFrpw3dVGbBynA0ylRcTTLSbPRTjmZbFy0bC3uypfCn6g';
  Base64New[34] := 'DdeEEhSTbhC9uHeLgDbF5b+DrpczfTm7SZl4pLYYWMnlsjpf95c8//4q5JE8GRhTFWzKqgYSCS6Zs7fOQcAu9wsMO6D/C1258IT4xPlT/h3uIiINLMQWIgbIpLooMMsbMqg3SBz7PpUGUHe4LGE';
  Base64New[35] := 'iabWzclHDh5igbyQFl4FR9AcoSA7BSihOhw0+aQWrAWRgTL4b+Ux5JDoSY4T6xB4jpGXTT8Acrkk+Fo7RfOkCi21ReRbnAH6acR8EU06YCmjia5l8nmPgQWmgdnUZS42BGkQ1SYegInBqHo0enA';
  Base64New[36] := 'uis2hZVZV8rW6N5xoSg1gZh34AGGQa1jiGbtrEerqLheB6IiMKlsLiGuiGj0A6hQZRZmnql6CdZ3qPO1WnZRgbips9PTHGfDsdC5sZEI1wMk93pFKOoKqqdX/A9dI+qZQYjjNBfoIUB/GDZyOgO';
  Base64New[37] := 'CfkeujteLSxW01OZpi6mrawP6OgPZDqhsEZjqVSi8+50ppjRgIFtFTX+6DfGrrv0JFZn4Kx9YzYNt70PzlGf/ACQPviDj+0ooShmJHQOaoxUpYc6cAqbC9npMMDouQW60GhqikPH95AJ3WLe4eo';
  Base64New[38] := 'UJhTyCZebYlg6CoMrWslVSYExOzqqB0OPzHYdix7otEtJY6FxgPjNkN4s+wCQxADomRge8EhAZG2mc9dLC1FGii3xgD7ggDImhDVoMIOXz595zJCfltLvyIxYiTAjlsSfsqolEhAGnA3HZoyE7g';
  Base64New[39] := 'wMMkQIsNiikW3OgvrrSLLqBNajIwgy9gmnsTcOhQYUj05ygLlFB2ssqAncF402nlhJQwavGVGm0OndUHO6fFQdiTnq32lYW5RPzjQpg9Yd0XSRViaM1QJJSql7Xsb7bHfrM+tDxxIgcr8789K2T';
  Base64New[40] := 'rQ7oNmIP0vtGCXWWulLHZmPpEEok55JjOQ/DKnjiRGP4QypmqcCdTxGgiKIJ1D08Q6m6JvIb6ePVbBmAyuF8GH0KYwMCevTQ1yskKTFS2CHjSQluj6KwovMCPOM3GHYXklQR07hOqLatqzDFWxy';
  Base64New[41] := 'oT2cXYcryIv9c6fzy6v7yx+SYFX704cymb7Sf8ZUN6WTMmooQpFwRq2f42sdPald91tDTOydfCCs9z1i4mXT9u43AzZGZ7//uC73v1v4P76iKbDjfwELsQ9JE0HOqwAAAYRpQ0NQSUNDIFBST0Z';
  Base64New[42] := 'JTEUAAHicfZE9SMNAHMVfU6VFKg52UHEIUp0siIo4ShWLYKG0FVp1MLn0C5o0JCkujoJrwcGPxaqDi7OuDq6CIPgB4ubmpOgiJf4vKbSI8eC4H+/uPe7eAUKjwlSzawJQNctIxWNiNrcqBl4RQA';
  Base64New[43] := 'hBDGJEYqaeSC9m4Dm+7uHj612UZ3mf+3P0KnmTAT6ReI7phkW8QTyzaemc94nDrCQpxOfE4wZdkPiR67LLb5yLDgs8M2xkUvPEYWKx2MFyB7OSoRJPE0cUVaN8IeuywnmLs1qpsdY9+QtDeW0lz';
  Base64New[44] := 'XWaw4hjCQkkIUJGDWVUYCFKq0aKiRTtxzz8Q44/SS6ZXGUwciygChWS4wf/g9/dmoWpSTcpFAO6X2z7YxQI7ALNum1/H9t28wTwPwNXWttfbQCzn6TX21rkCOjbBi6u25q8B1zuAANPumRIjuSn';
  Base64New[45] := 'KRQKwPsZfVMO6L8Fetbc3lr7OH0AMtTV8g1wcAiMFSl73ePdwc7e/j3T6u8HY4dyoVarwTQAAAAGYktHRAD/AP8A/6C9p5MAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQflBwwIKC79M7H';
  Base64New[46] := 'kAAAHaUlEQVRIx9WXW4xV1RnHf2vtvc8+N2bOHBguM8xwGWEGdZAWqoZiFRXT1pSmaeqDIL289MlesDFtTEONNaZJH/rW1KSEYltrsGm01kBbRLFIKgZSYAa5CQwzZzjMnMNczpxz9tl7ra8P7K';
  Base64New[47] := 'GiYrw0pv2SlZV1yVrr//2/21IiwocSES7dfidSKCoakUbEB1JABpgDtAKdQB6wuE4rKd+gnRGCYJJ6Yy5azyWTasd1EoxXJhGp09LUTMIdV/mWC3J2sJ9qfQTFLubPa1AeB2tU/sTRD/nY9xf3/';
  Base64New[48] := 'RbHv/8Q5i+7FEGoEOsjZIEc0IHrdJBJLUWkB2s7VO+yVtXcNENlMj5NMxLKTzpSKkVqZt5zV65EoWx46JCNfv2Uo1d/Rifu+5pCQbBtu8ipM3jf2ABRGEnQqEaXXpygWj+JkOL88JtAHaiXO5ZU';
  Base64New[49] := 'gQaKAJTB0Ua1z5WWV/eAUh8PfHnlrTBadrCSAVqAdlL+Aveb91+nOzuutxeK3dFzL8yhcDGrP3er763/koe1OvzzC6Qf2ozb2QmOc/khYglPn3Z0Ko3b0YGEocZPEP1+B+5ta0isWI5KpTEnTja';
  Base64New[50] := 'iWi1KrFmTaby02zP79jdTutQMzAduBqpABEwBJWASYRhklMicknNDh8udSy8CQzhOHT9h1awWWva98sHAl29eDRdGUgi9wBeA1cASIKfyuZR32xrPX7lSi4nUlAjRk79B9/SQvP12JKgT7XsN1d';
  Base64New[51] := 'wMjoMpjRK9dQapTGGHhkis+Sw4Dtr30fk8al4r7o034LTPB2vRHe1aL1ggKpUUqdWUFIrQiAAUkI2bxOzPi92LeK4INOK1fRizn2qtLAO1wXLHkhNoPYFWQjol/o9+QGbjhvdgfnikCXgE2AjMv';
  Base64New[52] := 'jKvFMxpxV24EJXNoJXGX3c3ZudfQSl0NotV8T5j0Jk0jb4i9R//BImMpVKV6F+HnRmPbsFpnYXO5VBdi3Ha26HRAK1wl3Z79kLRs6OjyKVLEATXIsqPFRICNu4HgdOAAY4AM4HmuK3A2jNYkkxU';
  Base64New[53] := 'jgZbHj+b2bjhqpjhljuXOsANMfC2q67Lpkl89Ss4+TzK9cBanLZ5OHfewRXloEBrlO+DUjgzZ5LY/F3c+fMlePkVif7wLI2DB0nedRc6l8O5fhlOrhkJQ1TCw1u4EDsyAokEuq0N894hLb7oCmH';
  Base64New[54] := 'Tu66LA2w1Zl8Dh4EkMBRbRRug8Vx5t9mL3APcF2srfNvhiihS0gjB90EERFBegsTn7yF8bT8SBEgU/ScRNEKceXNJtbWBMU54/ARMVAgPHCC5di06lcJbtQqVySK1GhJFKN/H6+nBTkwg9QDCK+';
  Base64New[55] := 'fJO8BPj3XcOzHIlnjcE++pAAOxQs4Bk8BbTNXCcscSByhdDphoFxgGdgK9sWmlYm151AI3/OOfMGvvQHd1IdbizJqFSqcxZwfAcVCOc8UKVCJBePYswXPPY88PYvv6IYywx09iKxWcfB5vWQ9oT';
  Base64New[56] := 'ePIUVQ6RWJ5LyqTQVuLlMoQGXlbkJsG7sXNxKCjmKjp9Ysx85m47wfKsXvMB74T7z8CjCCMAcYFlsWXPR4HkC7gQeBGwJXCMKZQwFu8GDNcQGVn4ORyeJ9egdIa0frqNBME2EIB29ePTFXB0cjA';
  Base64New[57] := 'eYnOn1e6uRmnJU9UKFDfuhXd1YXb3k40OIBMVrBH+wWRBhDEj6/GTJ6OgRlgBHgdGAdqMVm1aUcFJoADKFWN6xL/bcobi5XnTIP/B4oRtG5gbBOwKj7EA2Cqhi2XkTDEjk9g+vpJrluHt3ARmAi';
  Base64New[58] := 'MuWxs1iImwl20iMzm72HKZWzxoq3/9ImKFC5Wo77+fKK725MowgwOIn1vhmZoeLiaSY+b/mMJKZUm5dxQH3AQ6APOxuktRFFF0IBCqRDPDfFcUbPyyKUxaIQKkctpVkB1tknL33dN09G4ZqpTNy';
  Base64New[59] := 'w5n3hgA8FjP4Op2i1x4FtyxfeFEKU0UeSiFMGOZ9GzZ5Po7UWMBWvBmsunWUGn06hkEt06m0g7Cq0VYRSEe14+Ukslz9lisWZOnkLKY69THN0TFraPMF5xEAFFCa0banGn9b71dbIPbPzAdedHq';
  Base64New[60] := 'vBadr542Vqf+DmxTzwJ/CI2uaO4zjHl+/eqZHKu8n2RgcGp+m9/l3J/+LDjzGolGhuDMMQUCpjRUeyFopihwVAqU5N2eLhfymPPALvt3v2l+huHqoxNWkRA60B1ttmWV/dQ2b6d6G+7yW3f9pEq';
  Base64New[61] := 'tY9d3uaPHKTcvbxArX4YeAbYA4xh7GN2fDwvYSjK8xTNTSnz0l5dX7USt7vbmDNnavbY8Wp1y6MBjVBkpHSQerCXeuMgcAalhvQX7za5X/3ymo/IbtoEmzbxSYu66mMjQnlBt4tIJ3ArcC+eu95';
  Base64New[62] := '78Nu+e9Nyz/Qfo7HtKaFYCpiZG1G5pudlYnIX5fEBPLdKJikqlSo6X15fjZ7eYfSneslt28r/qqh3/urKnUuTiNwP3BKnh1U0Z7tRyqNSLRKZc8DTwD+Bk2TTNf+Rh99VOv4/yLvBL+pRRCYb5/';
  Base64New[63] := 'x24KY4YiaAN4ALaDWm2ufYln17P1Ef/W/LvwFiwmLimmIyEQAAAABJRU5ErkJggg==';

  EZTVPageCount := 0;

  URL[ 1] := 'https://eztv.re';                            {URL_EZTV}
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

    			IF Pos ('URL_Nyaa=', X) > 0 THEN
	    		  _UpdateVAR (URL[8], 'URL_Nyaa', X);
    			IF Pos ('AnimeXlateGroup=', X) > 0 THEN
	    		  _UpdateVAR (AnimeXlateGroup, 'AnimeXlateGroup', X);

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
  LinkURL[ 9] := URL[ 8] + '/?f=0&c=0_0&q=';
  LinkURL[10] := URL[ 9] + '/search/all/';
  LinkURL[11] := URL[10] + '/search/?name=';
  LinkURL[12] := URL[11] + '/?s=';
  LinkURL[13] := URL[12] + '/kick.php?q=';
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
  WriteLn (T, '&copy;' + L2 + '</FONT>');

  WriteLn (T, '<SPAN STYLE="float:right;"><A HREF="' + URL[11] + '" TARGET=_BLANK><B>&#91;EZTV STATUS&#93;</B></A></SPAN>');
  
  Write   (T, '<P STYLE="text-align:left;">');
  Write   (T, '<FONT SIZE=-1><I>', L3, '</I>');
  Write   (T, '<SPAN STYLE="float:right;">');

{$IFDEF DNSHELP8888}
  Write   (T, '<A HREF="', URL_HOWTO_DNS, '" TARGET=_BLANK TITLE="', Desc_DNS8888, '">');
  WriteLn (T, '<B>Website blocked? Use DNS 8.8.8.8 or 8.8.4.4</B></A>');
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
  Write (T, '<A HREF="', URL[16], '" TARGET="_BLANK">Torrent Galaxy</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[12], '" TARGET="_BLANK">Torrentz2</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[13], '" TARGET="_BLANK">1337x</A>,', HTMLSpace);
  Write (T, '<A HREF="', URL[10], '" TARGET="_BLANK">Next Episode</A>,', HTMLSpace);

  Write (T, 'and', HTMLSpace);

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
  Write (T, '<P/><TT><HR><I><FONT SIZE=-1>', LL1, OSVersion, LL2, xDiff:3:2, LL3);
  Write (T, '<BR/>$Program compiled at ' + CTime + ' (local time) on ' + CDate + '<BR>');
  Write (T, '$Get the source code from <A HREF="', URL_TVList_Source, '" TARGET="_BLANK">github.com</A><BR>');
  Write (T, '$BitCoin Donate', HTMLSpace, '<A HREF="bitcoin:', MyBitCoin, '">', MyBitCoin, '</A></I>');
  WriteLn (T, '</FONT></FONT></TT>');

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
VAR
  IsAnime : Boolean;
  AS      : String;
  _I      : Word;
  
  PROCEDURE _Showday(SS: String; C: Char);
  BEGIN
    Inc (EZTVPageCount);
    ShowDay := SS;
	EZTVDay[EZTVPageCount] := C;
  END;
BEGIN

  WHILE NOT Eof (S) DO
    BEGIN
      IsAnime := False;
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
              Write (T, '<A HREF="', LinkURL[ 1], '/shows/', XL, '" TARGET="_BLANK">Info</A>,', HTMLSpace);
			  IF EZTVPageCount < EZTVPageMax THEN
                BEGIN
	              EZTVPage[EZTVPageCount] := LinkURL[1] + '/shows/' + XL;
	            END;
			END;
		  Write (T, '<A HREF="', LinkURL[ 2], RepSpaceStr('-', XN), '" TARGET="_BLANK">Search</A></TD>');

		  Write (T,  TDStr + '<A HREF="', LinkURL[15], RepSpaceStr('+', XN), '+%2BTV+%2BShow" TARGET="_BLANK">Google</A>');

          Write (T, TDStr);

{$IFDEF ANIMESEARCH}
          IF IsAnime THEN
		    BEGIN
  		      Write (T, '<A HREF="', LinkURL[ 9]);
			  IF AnimeXlateGroup = '' THEN ELSE
			    Write (T, AnimeXlateGroup + '+');
			  Write (T, RepSpaceStr('+', XN), '" TARGET="_BLANK">' + AnimeHiragana + '</A>,', HTMLSpace);
            END;
{$ENDIF}

          Write (T, '<A HREF="', LinkURL[ 3], RepSpaceStr('+', XN), '" TARGET="_BLANK">PirateBay</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[10], XN, '/" TARGET="_BLANK">LimeTor</A>,', HTMLSpace);
		  Write (T, '<A HREF="', LinkURL[16], RepSpaceStr('+', XN), '" TARGET="_BLANK">TorGalaxy</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[13], RepSpaceStr('+', XN), '" TARGET="_BLANK">Torz2</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[14], RepSpaceStr('+', XN), '/1/" TARGET="_BLANK">1337x</A>');
{$IFDEF CUSTOMSEARCH}
          Write (T, ',', HTMLSpace, '<A HREF="', LinkURL[14], RepSpaceStr('+', XN), '+MiNX/1/" TARGET="_BLANK">MiNX</A>');
{$ENDIF}		  
		  Write (T, '</TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[11], RepSpaceStr('-', XN), '" TARGET="_BLANK">NextEpisode</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[ 8], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVfinale</A></TD>');
          Write (T, TDStr + '<A HREF="', LinkURL[ 5], XN, '" TARGET="_BLANK">Variety</A>,', HTMLSpace);
          Write (T, '<A HREF="', LinkURL[ 6], RepSpaceStr('-', XN), '" TARGET="_BLANK">TVLine</A></TD>');
		
          Write (T, TDStr + '<A HREF="', LinkURL[ 7], RepSpaceStr('+', XN), '.html" TARGET="_BLANK">YesMovies</A>', HTMLSpace);
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
