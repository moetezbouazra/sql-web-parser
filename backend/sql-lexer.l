%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sql-parseur.tab.h"

extern YYSTYPE yylval;
%}

%%

(?i:SELECT)     { return SELECT; }
(?i:FROM)       { return FROM; }
(?i:WHERE)      { return WHERE; }
(?i:GROUP)      { return GROUP; }
(?i:BY)         { return BY; }
(?i:HAVING)     { return HAVING; }
(?i:ORDER)      { return ORDER; }
(?i:ASC)        { return ASC; }
(?i:DESC)       { return DESC; }
(?i:INSERT)     { return INSERT; }
(?i:INTO)       { return INTO; }
(?i:VALUES)     { return VALUES; }
(?i:DELETE)     { return DELETE; }
(?i:DROP)       { return DROP; }
(?i:AS)         { return AS; }
(?i:SUM)        { return SUM; }
(?i:AVG)        { return AVG; }
(?i:MAX)        { return MAX; }
(?i:MIN)        { return MIN; }
(?i:OR)         { return OR; }
(?i:AND)        { return AND; }
(?i:INNER)      { return INNER; }
(?i:LEFT)       { return LEFT; }
(?i:RIGHT)      { return RIGHT; }
(?i:FULL)       { return FULL; }
(?i:JOIN)       { return JOIN; }
(?i:ON)         { return ON; }
"="             { return EQ; }
"<="            { return LE; }
">="            { return GE; }
"<>"            { return NE; }
"<"             { return '<'; }
">"             { return '>'; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"("             { return '('; }
")"             { return ')'; }
","             { return ','; }
";"             { return ';'; }
"."             { return '.'; }

[0-9]+          { 
                  yylval.num = atoi(yytext); 
                  return NUM; 
                }

[A-Za-z][A-Za-z0-9_]*  { 
                          yylval.str = strdup(yytext); 
                          return ID; 
                        }

\'[^\']*\'      { 
                  /* Remove quotes and copy string value */
                  yytext[yyleng-1] = '\0';
                  yylval.str = strdup(yytext+1); 
                  return STRING; 
                }

\"[^\"]*\"      { 
                  /* Remove quotes and copy string value */
                  yytext[yyleng-1] = '\0';
                  yylval.str = strdup(yytext+1); 
                  return STRING; 
                }

[ \t\n\r]      

.               { printf("Caractère non reconnu: '%s' "); }

%%

int yywrap(void) {
    return 1;
}
