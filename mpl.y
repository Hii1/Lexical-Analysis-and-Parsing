%{
#include <stdio.h>
#include <string.h>
#include "mpl.h"

  char Data_Type[50] = {'\0'}; /* SYMBOL TABLE*/
  int noOfIdentifiers = 0; /* KEEP TRACK OF THE VARAIBLES*/

  extern int yylex();
  extern int yylineno;

  node * create(char*  type, char* value, node* value2, node* value3, node* value4);
  char* operations(node* p);
  void freeNode(node* p);
  node *  storeIdentifier(char* identifier, char* identifier_data_type);
  void storeDataType(char* data_type);
  char* currentDataType();
  char isValidAssignment(node* first, node* sec);
  node *  isDup(char* identifier);
  char* itoa(int number);
  char* ftoa(float number);
  char* ctoa(char number);
  void dupError(char* identifier);
  void yyerror(char *s);
%}

%union {
    char* value;
    node* NODE;
};

%token <value>  CHARACTER_VALUE
%token <value>   INTEGER_VALUE
%token <value> FLOAT_VALUE
%token <value> STRING_VALUE

%token <value> INT
%token <value> FLOAT
%token <value> STRING
%token <value> DATA_TYPE
%token <value> IDENTIFIER

%token XXEXIT
%token BREAK
%token WHILE IF PRINT
%nonassoc IFX
%nonassoc ELSE

/* PRECEDENCE AND ASSOCIATIVITY*/
%left GE LE EQ NE '>' '<'
%left OR
%left AND
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <NODE> stmt expr stmt_list VVALUE

%%
function:
        function stmt         {   operations($2);  freeNode($2);}       /* EXECUTE THE OPERATIONS FROM STMT BY CALLING THE OPERATION FUNC AND AFTER IT FREE THE MEMORY WHICH IS NO LONGER NEEDED*/
        |
        ;

stmt:
        ';'                              {$$ = create(";", NULL, NULL, NULL, NULL);} /* EMPTY STATMENT, CREATE A NODE SO WE CAN USE IT LATER e.g if(1) ;*/
        | expr ';'                       {$$ = $1;} /* END OF THE STATMENT*/
        | expr  '='  expr ';'            {$$ = create("=", NULL, $1, $3, NULL);} /* ASSIGNMENT */

        | PRINT expr ';'                 {$$ = create("PRINT", NULL, $2, NULL, NULL);}
        | WHILE '(' expr ')' stmt        {$$ = create("WHILE", NULL, $3, $5, NULL); }
        | IF '(' expr ')' stmt %prec IFX {$$ = create("IF", NULL, $3, $5, NULL); }
        | IF '(' expr ')' stmt ELSE stmt {$$ = create("IF", NULL, $3, $5, $7); }
        | '{' stmt_list '}'              {$$ = $2;  }
        | XXEXIT ';'                     {$$ = create("EXIT", NULL, NULL, NULL, NULL);}
        | BREAK ';'                      {$$ = create("BREAK", NULL, NULL, NULL, NULL);}
        ;

stmt_list   : /* USED SO WE CAN EXCUTE MORE THAN 1 STATMENT INSIDE IF OR WHILE STATMENTS*/
                stmt                    {$$ = $1;}
            | stmt_list stmt            {$$ = create(";", NULL, $1, $2, NULL);}
        ;



expr    : /* EXPRESSIONS */
            DATA_TYPE IDENTIFIER     {    /* DECLARATION OF VARIABLE   */
                                            if(!isDup($2))
                                            {
                                            storeDataType($1);
                                            $$ = storeIdentifier($2,$1);
                                            }
                                            else
                                            {
                                                dupError($2);
                                            }
                                    }
        | IDENTIFIER            {      /* USING ALREADY DEFINED VARIABLE    */
                                        if(!isDup($1)) yyerror("VARIABLE ISN'T DEFINED.");
                                        $$ = isDup($1);
                                }

        | VVALUE                { /* CONSTANTS JUST VALUE*/
                                        storeDataType($1->data_type);
                                        $$ = $1;
                                }

        | expr '+' expr         {$$ = create("+", NULL, $1, $3, NULL);}
        | expr '-' expr         {$$ = create("-", NULL, $1, $3, NULL);}
        | expr '*' expr         {$$ = create("*", NULL, $1, $3, NULL);}
        | expr '/' expr         {$$ = create("/", NULL, $1, $3, NULL);}

        | expr OR expr          {$$ = create("OR", NULL, $1, $3, NULL);}
        | expr AND expr         {$$ = create("AND", NULL, $1, $3, NULL);}

        | expr '<' expr         {$$ = create("<", NULL, $1, $3, NULL);}
        | expr '>' expr         {$$ = create(">", NULL, $1, $3, NULL);}
        | expr GE expr          {$$ = create(">=", NULL, $1, $3, NULL);}
        | expr LE expr          {$$ = create("<=", NULL, $1, $3, NULL);}
        | expr NE expr          {$$ = create("!=", NULL, $1, $3, NULL);}
        | expr EQ expr          {$$ = create("==", NULL, $1, $3, NULL);}

        | '(' expr ')'          {$$ = $2;}

        ;


VVALUE        : INTEGER_VALUE   {$$ = create("int", $1, NULL, NULL, NULL);}
              | FLOAT_VALUE     {$$ = create("float", $1, NULL, NULL, NULL);}
              | CHARACTER_VALUE {$$ = create("char", $1, NULL, NULL, NULL);}
              | STRING_VALUE    {$$ = create("string", $1, NULL, NULL, NULL);}
              ;


%%

node* identifiers[100]; /* 100 VARIABLE MAX.;*/
extern int yylineno;

 /*PRINT ERROR MESSAGE SPECIFIED FOR DUPLICATED VARIABLES DECLARATION ND STOP EXECUTION OF THE CODE.*/
void dupError(char* identifier){
    printf("\nERROR ON LINE %d : \n '%s' is already defined.\n",yylineno,identifier);
    exit(0);
}
/* PRINT ERROR MESSAGE AND STOP EXECUTION OF THE CODE.*/
void yyerror(char *s){
    fprintf(stderr, "\nERROR ON LINE %d : \n%s\n", yylineno, s);
    exit(0);
}
/*CONVER INT TO A CHAR* */
char* itoa(int number){
   static char buffer[33];
  snprintf(buffer, sizeof(buffer), "%d", number);
  return buffer;
}
/*CONVER FLOAT TO A CHAR* */
char* ftoa(float number){
   static char buffer[33];
  snprintf(buffer, sizeof(buffer), "%f", number);
  return buffer;
}
/*CONVER CHAR TO A CHAR* */
char* ctoa(char number){
  static char buffer[33];
  snprintf(buffer, sizeof(buffer), "%c", number);
  return buffer;
}

/* CREATE A NODE (ALLOCATE MEMORY) SO WE CAN USE IT WHEN WE DO THE OPERATIONS
WE HAVE VALUE2 AND VALUE3 AND VALUE 4 SO WE CAN SAVE THE EXPRSION WHEN E.G: SUM(+)
OR IF ELSE NEEDS 3 VALUES TO HOLD SO IT CAN OPERATS CORRECTION*/
node * create(char*  type, char* value, node* value2, node* value3, node* value4){
    node* temp = (node*) malloc (sizeof(node));
    if (!temp)
        yyerror("out of memory");

    if(value2) {
        temp->value2 = (node*) malloc (sizeof(node));
        if (!temp->value2) yyerror("out of memory");
    }
    if(value3) {
        temp->value3 = (node*) malloc (sizeof(node));
        if (!temp->value3) yyerror("out of memory");
                }
    if(value4) {
        temp->value4 = (node*) malloc (sizeof(node));
        if (!temp->value4) yyerror("out of memory");
      }

    temp->data_type = strdup(type);
    temp->value = value;
    //if (!value) temp->value = strdup(value);
    temp->name = NULL;
    temp->value2 = value2;
    temp->value3 = value3;
    temp->value4 = value4;

    return temp;
}
/* EXCUTE ALL THE STATMENTS */
char* operations(node* p){
    if (!p) return 0; // empty statment

    /* CHECK IF ITS A VALUE (CONST OR VARIABLE), WHAT TYPE IT'S  AND RETURNS IT'S VALUE.*/
    if(!strcmp("int", p->data_type )) return p->value;
    if(!strcmp("float", p->data_type )) return p->value ;
    if(!strcmp("char", p->data_type )) return p->value ;
    if(!strcmp("string", p->data_type )) return p->value ;
    if(!strcmp("BREAK", p->data_type ))   return "BREAK";


    /* HI-TERMINATE WHILL INVOKE THIS IF*/
    if(!strcmp("EXIT", p->data_type ))
    {
        printf("~~This program has been terminated. Bye!~~\n");
        exit(0);
    }
    /* WHILE LOOP WHILE THE CONDITION IN VALUE2 IS CORRECT WHAT EVER IN VALUE3 WILL BE EXECUTED.*/
    /* IF VALUE3 WAS "BREAK" IT WILL TERMINATE THE LOOP*/
    if(!strcmp("WHILE", p->data_type )) {
        while(atoi(operations(p->value2)))
        {
            if (!strcmp(operations(p->value3), "BREAK")) break;
        }
        return 0;
    }
    /*IF & IF-ELSE STATMENT*/
    if(!strcmp("IF", p->data_type )) {
        if (atoi(operations(p->value2)))
        {
            char * temp = operations(p->value3);
            if(temp)
                 if (!strcmp(temp, "BREAK")) return "BREAK";

        }
        else if (p->value4)
        {
            char * temp = operations(p->value4);
            if(temp)
                 if (!strcmp(temp, "BREAK")) return "BREAK";
        }
        return 0;
    }
    /* PRINT STATMENT*/
    if(!strcmp("PRINT", p->data_type ))
    {
        printf("%s", operations(p->value2));
        return 0;
    }
    /* END OF STATMENT*/
    if(!strcmp(";", p->data_type ))
    {
        char *temp1  = operations(p->value2);
        if(temp1)
             if (!strcmp(temp1, "BREAK")) return "BREAK";
        char *temp2 = operations(p->value3);
         if(temp2)
                 if (!strcmp(temp2, "BREAK")) return "BREAK";
        return temp2;
    }
    /* ASSIGNMENT OPERATOR*/
    if(!strcmp("=", p->data_type ))
    {
        /* 1ST CHECK IF ITS VALID ASSIGNMENT*/
        if(!isValidAssignment(p->value2, p->value3)) yyerror("Invalid assignment(=).");
        if(!strcmp(p->value2->data_type, "int"))
            return p->value2->value = strdup(itoa(atoi(operations(p->value3))));
        return  p->value2->value = strdup(operations(p->value3)) ;
    }

    if(!strcmp("+", p->data_type ))
    {
        /* 1ST CHECK IF ITS VALID ASSIGNMENT AND ALSO RETURN WHICH DATA TYPE ITS SO INT + INT = INT BUT INT + FLOAT = FLOAT*/
        /* ALSO STRING CONCATENATION WORKS*/
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid sum(+)");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) + atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) + atof(operations(p->value3)));
        if(type == 's')
            {
                char *xstr1 = operations(p->value2) , *xstr2 = operations(p->value3);
                char *str1;
                str1 = malloc (sizeof (char) * (strlen(xstr1) + strlen(xstr2) + 1));
                strcpy(str1, xstr1);
                strcat(str1, xstr2);
                xstr1 = strdup(str1);
                free(str1);
                return xstr1;
            }
    }
    if(!strcmp("-", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid subtraction(-)");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) - atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) - atof(operations(p->value3)));
        if(type == 's') yyerror("you can't subtract(-) strings! Don't be fool!");

    }
    if(!strcmp("*", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid multiplication(*)");
        if(type == 'i')
            return itoa(atoi(operations(p->value2)) * atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) * atof(operations(p->value3)));
        if(type == 's') yyerror("you can't multiply(*) strings! Don't be fool!");
        if(type == 'c') yyerror("you can't multiply(*) characters!");
    }
    if(!strcmp("/", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid division(/)");
        if(type == 'i')
            return itoa(atoi(operations(p->value2)) / atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) / atof(operations(p->value3)));
        if(type == 's') yyerror("you can't divide(/) strings! Don't be fool!");
        if(type == 'c') yyerror("you can't divide(/) characters!");
    }
    /* || STATMENT */
    if(!strcmp("OR", p->data_type ))
    {
        /* CHECK IF BOTH NULL, THEN CHECK OF ONE OF THEM IS NOT 0 (IF FIRST != 0) IT WILL RETURN TRUE*/
        char * first = operations(p->value2), *sec = operations(p->value3);
        if( !(first || sec)) return "0";
        if(strcmp(first, "0")) return "1";
        if(strcmp(sec, "0")) return "1";
        return "0";
    }
        /* && STATMENT */
    if(!strcmp("AND", p->data_type ))
    {

        char * first = operations(p->value2), *sec = operations(p->value3);
        if(first == 0) return "0";
        if(!strcmp(first, "0")) return "0";

        if(sec == 0) return "0";
        if(!strcmp(sec, "0")) return "0";

        return "1";
    }
    /* LESS THAN OPERATOR WORKS FOR ALL DATA TYPES*/
    if(!strcmp("<", p->data_type ))
    {
        /* FIRST CHECK IF ITS VALIDD COMPARISION AND THEN RETURN ITS DATA TYPE*/
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) < atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) < atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) < 0)
                    return "1";
                return "0";
            }
    }

    if(!strcmp(">", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) > atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) > atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) > 0)
                    return "1";
                return "0";
            }
    }
    if(!strcmp(">=", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) >= atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) >= atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) >= 0)
                    return "1";
                return "0";
            }
    }
    if(!strcmp("<=", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) <= atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) <= atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) <= 0)
                    return "1";
                return "0";
            }
    }
    if(!strcmp("!=", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) != atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) != atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) != 0)
                    return "1";
                return "0";
            }
    }
    if(!strcmp("==", p->data_type ))
    {
        char type = 0;
        if(!(type = isValidAssignment(p->value2, p->value3))) yyerror("Invalid comparison");
        if(type == 'i' || type == 'c')
            return itoa(atoi(operations(p->value2)) == atoi(operations(p->value3)));
        if(type == 'f')
            return ftoa(atof(operations(p->value2)) == atof(operations(p->value3)));
        if(type == 's')
            {
                if (strcmp(operations(p->value2), operations(p->value3)) == 0)
                    return "1";
                return "0";
            }
    }
    return 0;
}

/*RELEASE THE MOMEY BACK WHICH WAS ALLOCATED BEFORE*/
void freeNode(node* p){
    if(!p) return;
    if(p->name) return;
    if(p->value2) freeNode(p->value2);
    if(p->value3) freeNode(p->value3);
    if(p->value4) freeNode(p->value4);
    free(p);
}

/* CREATE A VARIABLE AND SAVE IT ON THE SYMBOL TABLE (identifiers)*/
node *  storeIdentifier(char* identifier, char* identifier_data_type){

    identifiers[noOfIdentifiers] = (node*) malloc (sizeof(node));
    identifiers[noOfIdentifiers]->name = strdup(identifier);
    identifiers[noOfIdentifiers]->data_type = strdup(identifier_data_type);
    identifiers[noOfIdentifiers]->value  = 0;
    identifiers[noOfIdentifiers]->value2  = NULL;
    identifiers[noOfIdentifiers]->value3  = NULL;
    identifiers[noOfIdentifiers]->value4  = NULL;
    noOfIdentifiers++;
    return identifiers[noOfIdentifiers-1];
}
/* SAVE THE CURRENT DATA TYPE SO WE CAN USE IT WHILE WE DO OPERATIONS*/
void storeDataType(char* data_type){
    int i=0;
    while(data_type[i] != '\0'){
        Data_Type[i] = data_type[i];
        i++;
    }

}
/* CHECK FOR THE CURRENT DATA TYPE IN USE*/
char* currentDataType(){
    return Data_Type;
}
 /* CHECK IF ITS A VAILD ASSIGNMENT E.X: 5 + 4.3 WILL BE CORRECT BUT "43" + 4 WILL GIVE AN ERROR*/
char isValidAssignment(node* first, node* sec){
    char * d1 = first->data_type, *d2 = sec->data_type ;
    if(!strcmp(d2,"=") || !strcmp(d2,"+") || !strcmp(d2,"-") || !strcmp(d2,"*") ||
            !strcmp(d2,"/"))
            {
                d2 = sec->value2->data_type;
                node* temp = sec->value2;
                while(!strcmp(d2,"=") || !strcmp(d2,"+") || !strcmp(d2,"-") || !strcmp(d2,"*") ||
                        !strcmp(d2,"/"))
                        {
                            temp = temp->value2;
                            d2 = temp->data_type;
                        }

                if(strcmp(d1,d2) == 0) return d1[0];
                if(!strcmp(d2, "int") || !strcmp(d2, "float"))
                {
                    if(!strcmp(d1, "int") || !strcmp(d1, "float")) return 'f';
                }
             }

    if(!strcmp(d1,"=") || !strcmp(d1,"+") || !strcmp(d1,"-") || !strcmp(d1,"*") ||
            !strcmp(d1,"/"))
            {
                d1 = first->value2->data_type;
                node* temp = first->value2;
                while(!strcmp(d1,"=") || !strcmp(d1,"+") || !strcmp(d1,"-") || !strcmp(d1,"*") ||
                        !strcmp(d1,"/"))
                {
                    temp = temp->value2;
                    d1 = temp->data_type;
                }
                if(strcmp(d1,d2) == 0) return d1[0];
                if(!strcmp(d1, "int") || !strcmp(d1, "float"))
                {
                    if(!strcmp("int", d2) || !strcmp("float", d2)) return 'f';
                }
            }
    if(!strcmp(d1,d2)) return d1[0];
    if(!strcmp(d1, "int") || !strcmp(d1, "float"))
    {
        if(!strcmp("int", d2) || !strcmp("float", d2)) return 'f';
    }
    return 0;
}

/* CHECK IF THE VARIABLE IS ALREADY DEFINED*/
node *  isDup(char* identifier){
    int i;
    for(i=0;i<noOfIdentifiers;i++){
        if(strcmp(identifier,identifiers[i]->name) == 0){
            return identifiers[i];
        }
    }
    return 0;
}

/* EVERY C PROGRAM NEEDS MAIN FUNCTION.
WE USE YYPARSE TO RUN THE COMIPLER + CALL THE YYLEX TO GET THE Token/ */
int main(){
  yyparse();
  return 0;
}
