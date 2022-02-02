%{
#include <stdlib.h>
#include "mpl.h"
#include "y.tab.h"
char buf[100];
char *s;
void extern yyerror(char*);
%}
%x xxSTR

whitespace      [ \t\r\v\f]
linefeed        \n
digit [0-9]
letter [A-Za-z]

%%
    /*MATCH DATA TYPE */
"int"   |
"float" |
"char"  |
"string"                               {yylval.value = strdup(yytext);return DATA_TYPE;} /*SAVE THE DATA TYPE AND RETURN A TOKEN REFERES WHICH TYPE IT IS */

    /*MATCH 1 CHAR */
[\']({letter}|{digit})[\']                     {yytext[2] = '\0'; yylval.value = strdup(yytext+1); return CHARACTER_VALUE;} /*SAVE THE VALUE OF THE CHAR AND RETURN A TOEKN REFERS THAT ITS CHAR */


    /*MATCH NUMBERS */
[-+]?{digit}+                        {yylval.value = strdup(yytext);  return INTEGER_VALUE;} /*SAVE THE VALUE OF THE INT AND RETURN A TOKEN REFERS THAT ITS INT */
[-+]?{digit}*\.?{digit}+             {yylval.value = strdup(yytext); return FLOAT_VALUE;}

 /* MATCH  COMPARISON OPERATORS  */
">="                                 return GE; /* RETURN A TOKEN REFERS TO IT  */
"<="                                 return LE;
"=="                                 return EQ;
"!="                                 return NE;

 /* MATCH  LOGICAL OPERATORS  */
"AND"                                return AND;
"OR"                                 return OR;

 /* MATCH  KEYWORDS  */
"while"                              return WHILE;
"if"                                 return IF;
"else"                               return ELSE;
"print"                              return PRINT;
"HI-TERMINATE"                       return XXEXIT;
"break"                              return BREAK;

    /* MATCH  IDENTIFIERS  MUST START WITH LETTER OR _ AND CAN CONTAIN LETTER DIGIT OR _ */
({letter}|_)({letter}|{digit}|_)*        {yylval.value = strdup(yytext); return IDENTIFIER;}

 /* MATCH  CHAR STRING (Exclusive start) THE STRING IS SIMIALR TO C STRING */
\" { BEGIN xxSTR; s = buf; }
<xxSTR>\\n { *s++ = '\n'; }
<xxSTR>\\t { *s++ = '\t'; }
<xxSTR>\\\" { *s++ = '\"'; }
<xxSTR>\" {
                *s = 0;
                BEGIN 0;
                yylval.value = strdup(buf);
                return STRING_VALUE;
                }
<xxSTR>\n { printf("invalid string. it must end with \" in same line"); exit(1); }
<xxSTR>. {*s++ = *yytext; }

    /* MATCH  1 CHAR OPERATORS*/
[-()<>=+*/;{}]                       {return *yytext;}


    /* KEEPS TRACK OF THE LINE NUMBER*/
\n                                   {yylineno++;}
 /* IGNORE WHITE SPACE*/
[ \t\r\v\f]                          ;
    /* NOT RECOGNIZED TOKEN*/
.                                    {yyerror("Invalid Token");}



%%
/* CALLED BY LES WHEN THE INPUT REACHES THE END*/
int yywrap(void) {
    return 1;
}
