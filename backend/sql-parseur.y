%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int erreur_detectee = 0;
int column_count = 0;
int value_count = 0;
char output_buffer[4096] = "";

int yylex(void);
int yyerror(const char *s);

void append_output(const char *str) {
    strcat(output_buffer, str);
}

%}

%union {
    int num;
    char *str;
}

%token <str> ID STRING
%token <num> NUM
%token SELECT FROM WHERE GROUP BY HAVING ORDER ASC DESC
%token INSERT INTO VALUES DELETE DROP AS
%token SUM AVG MAX MIN
%token OR AND
%token INNER LEFT RIGHT FULL JOIN ON
%token EQ LE NE GE
%left OR
%left AND
%nonassoc EQ LE NE GE '<' '>'
%left '+' '-'
%left '*' '/'

%%

manyline : manyline S
         | error '\n' { yyerrok; }
         | S
         ;

S : ST1 ';' {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
        erreur_detectee = 0;
    }
  | ST7 ';' {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
        erreur_detectee = 0;
    }
  | ST8 ';' {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
        erreur_detectee = 0;
    }
  | ST9 ';' { 
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
        column_count = 0;
        value_count = 0;
        erreur_detectee = 0; 
    }
  | error ';' {
        yyerrok;
        erreur_detectee = 0;
        column_count = 0;
        value_count = 0;
    }
  ;

ST1 : SELECT colonne FROM table_expr ST2
    | SELECT error { 
        append_output("Erreur: Syntaxe incorrecte dans la liste des colonnes après SELECT. Vérifiez noms de colonnes, virgules et fonctions.\n"); 
        erreur_detectee = 1; 
    }
    | SELECT colonne FROM error { 
        append_output("Erreur: Nom de table incorrect ou manquant après FROM. Vérifiez l'orthographe des tables.\n"); 
        erreur_detectee = 1; 
    }
    ;

table_expr : table_with_alias
          | table_with_alias join_clause
          ;

join_clause : join_type alias_table ON join_condition
            | join_clause join_type alias_table ON join_condition
            | error {
                erreur_detectee = 1;
                append_output("Erreur: Clause JOIN mal formée. Assurez-vous d'utiliser la syntaxe: [INNER/LEFT/RIGHT/FULL] JOIN table ON condition\n");
              }
            ;

alias_table : ID
            | ID ID
            | ID AS ID
            ;

join_type : INNER JOIN
          | LEFT JOIN
          | RIGHT JOIN
          | FULL JOIN
          | JOIN
          | error JOIN {
              erreur_detectee = 1;
              append_output("Erreur: Type de JOIN invalide. Utilisez INNER, LEFT, RIGHT, FULL ou aucun qualificateur avant JOIN.\n");
            }
          ;

join_condition : ID '.' ID EQ ID '.' ID
               | ID '.' ID EQ STRING
               | ID '.' ID EQ NUM
               | ID EQ ID
               | ID EQ STRING
               | ID EQ NUM
               | COND
               | error {
                   append_output("Erreur: Condition de jointure incorrecte après ON. Format attendu: table1.colonne = table2.colonne\n");
                   erreur_detectee = 1;
               }
               ;

colonne : colonne ',' element
        | element
        ;

element : ID
        | ID '.' ID
        | '*'
        | ID '.' '*'
        | appel_fonc
        ;

appel_fonc : nom_fonc '(' expr ')'
           | nom_fonc '(' '*' ')'
           | nom_fonc '(' ID '.' '*' ')'
           ;

nom_fonc : SUM
         | AVG
         | MAX
         | MIN
         ;

expr : ID
     | ID '.' ID
     | NUM
     | expr '+' expr
     | expr '-' expr
     | expr '*' expr
     | expr '/' expr
     ;

table : table ',' ID 
      | ID
      ;

table_with_alias : table
                 | ID ID
                 | ID AS ID
                 ;

ST2 : WHERE COND ST3
    | WHERE error {
        append_output("Erreur: Condition WHERE incorrecte ou manquante. Vérifiez la syntaxe des conditions (colonne = valeur, etc.)\n"); 
        erreur_detectee = 1;
    }
    | ST3
    ;

ST3 : GROUP BY grouplist ST4
    | GROUP error {
        append_output("Erreur: Syntaxe GROUP BY incorrecte. Assurez-vous d'utiliser 'GROUP BY nom_colonne'\n"); 
        erreur_detectee = 1;
    }
    | ST4
    ;

grouplist : grouplist ',' ID
          | ID
          ;

ST4 : HAVING COND ST5
    | HAVING error {
        append_output("Erreur: Condition HAVING incorrecte. Vérifiez la syntaxe des conditions après HAVING.\n"); 
        erreur_detectee = 1;
    }
    | ST5
    ;

ST5 : ORDER BY orderlist 
    | ORDER error {
        append_output("Erreur: Syntaxe ORDER BY incorrecte. Format attendu: ORDER BY colonne [ASC|DESC]\n"); 
        erreur_detectee = 1;
    }
    | 
    ;

orderlist : orderlist ',' ID order_dir
          | ID order_dir
          ;

order_dir : DESC
          | ASC
          |
          ;

ST7 : DELETE FROM ID WHERE COND {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
      }
    | DELETE FROM ID {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
      }
    | DELETE FROM error {
        erreur_detectee = 1;
        append_output("Erreur: Nom de table manquant ou invalide après le mot clé 'FROM'\n");
      }
    | DELETE error {
        erreur_detectee = 1;
        append_output("Erreur: Mot-clé 'FROM' manquant dans la requête DELETE. Syntaxe: DELETE FROM table [WHERE condition]\n");
      }
    | DELETE FROM ID WHERE error {
        erreur_detectee = 1;
        append_output("Erreur: Condition WHERE invalide dans la requête DELETE. Vérifiez la syntaxe: colonne = valeur\n");
      }
    ;

ST8 : DROP FROM ID {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
      }
    | DROP error {
        erreur_detectee = 1;
        append_output("Erreur: Syntaxe DROP incorrecte. Format attendu: DROP FROM nom_table\n");
      }
    ;

ST9 : INSERT INTO ID VALUES '(' valuelist ')' {
        if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
      }
    | INSERT INTO ID '(' columnlist ')' VALUES '(' valuelist ')' {
        if (column_count != value_count) {
            erreur_detectee = 1;
            char error_msg[200];
            sprintf(error_msg, "Erreur: Le nombre de colonnes (%d) ne correspond pas au nombre de valeurs (%d). Vérifiez la correspondance.\n", 
                   column_count, value_count);
            append_output(error_msg);
        } else if (!erreur_detectee) {
            append_output("Requête correcte\n");
        }
        column_count = 0;
        value_count = 0;
      }
    | INSERT INTO ID '(' columnlist ')' error {
        erreur_detectee = 1;
        append_output("Erreur: Mot-clé VALUES manquant ou liste de valeurs incorrecte. Syntaxe attendue: ... VALUES (val1, val2, ...)\n");
        column_count = 0;
        value_count = 0;
      }
    | INSERT INTO ID error {
        erreur_detectee = 1;
        append_output("Erreur: Mauvaise syntaxe après le nom de la table. Utilisez VALUES (val1, val2) ou (col1, col2) VALUES (val1, val2)\n");
        column_count = 0;
        value_count = 0;
      }
    | INSERT INTO error {
        erreur_detectee = 1;
        append_output("Erreur: Nom de table manquant ou invalide après 'INTO'\n");
        column_count = 0;
        value_count = 0;
      }
    | INSERT error {
        erreur_detectee = 1;
        append_output("Erreur: Mot-clé 'INTO' manquant. Syntaxe correcte: INSERT INTO table VALUES (...)\n");
        column_count = 0;
        value_count = 0;
      }
    ;

COND : COND OR COND
     | COND AND COND
     | '(' COND ')'
     | E
     ;

E : F EQ F
  | F NE F
  | F LE F
  | F GE F
  | F '<' F
  | F '>' F
  ;

F : ID 
  | ID '.' ID
  | NUM  
  | STRING
  | appel_fonc
  ;

valuelist : valuelist ',' valeur {
             value_count++;
           }
          | valeur {
             value_count = 1;
           }
          ;

columnlist : columnlist ',' ID {
              column_count++;
            }
           | ID {
              column_count = 1;
            }
           ;

valeur : NUM
       | ID
       | STRING
       ;

%%

/* Error handling function */
int yyerror(const char *s) {
    return 1;
}

extern FILE *yyin;

int main(int argc, char **argv) {
    // Clear output buffer
    output_buffer[0] = '\0';

    // If a file path is provided as an argument
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Cannot open input file: %s\n", argv[1]);
            return 1;
        }
    } else {
        // Use stdin if no file path provided
        yyin = stdin;
    }

    // Parse the input
    yyparse();

    // Close file if opened
    if (argc > 1 && yyin != NULL) {
        fclose(yyin);
    }

    // Print the buffered output
    printf("%s", output_buffer);
    
    return 0;
}

