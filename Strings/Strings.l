%{
#include <cstdio>
#include <iostream>
#include "Strings.h"
#include "Strings.tab.h"
using namespace std;

extern "C" {
	int yylex(void);
}

int lineNum = 1;

%}
%x COMMENT
%x LOGCAT_STRING

%%
<INITIAL>{
"#" {BEGIN(COMMENT);}
"logcat " {BEGIN(LOGCAT_STRING);}
}

<COMMENT>{
[\n] {++lineNum; BEGIN(INITIAL);}
[^\n]* {}/* Eat anything that's not a '\n' */ 
}

<LOGCAT_STRING>{
[\n] {++lineNum; printf("%s",yytext); BEGIN(INITIAL);}
[^\n]* {printf("%s",yytext);}
}

set {return SET;}
modify {return MODIFY;}
append {return APPEND;}
reverse {return REVERSE;}
delete {return DELETE;}
print {return PRINT;}
printlength {return PRINT_LENGTH;}
printwordcount {return PRINT_WORD_COUNT;}
printwords {return PRINT_WORDS;}
search {return SEARCH;}
list {return LIST;}
exit {return EXIT;}

[ ] {yylval.strVal = strdup(yytext); return SPACE;}
[\t] {yylval.strVal = strdup(yytext); return TAB;}
[\n] {++lineNum; return NEW_LINE;}
[\"] {return DOUBLE_QUOTATION;}
[\+] {return PLUS;}
[\*] {return ASTERISK;}

[0-9]+ {yylval.strVal = strdup(yytext); return DIGIT;}
[a-zA-Z]+ {yylval.strVal = strdup(yytext); return LETTER;}

[\,] {yylval.strVal = strdup(yytext); return MARK_COMMA;}
[\.] {yylval.strVal = strdup(yytext); return MARK_FULL_STOP;}
[\:] {yylval.strVal = strdup(yytext); return MARK_COLON;}
[\;] {yylval.strVal = strdup(yytext); return MARK_SEMICOLON;}
[\?] {yylval.strVal = strdup(yytext); return MARK_QUESTION;}
[\!] {yylval.strVal = strdup(yytext); return MARK_EXCLAMATORY;}

%%