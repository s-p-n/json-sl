
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"rand"                return 'RAND'
[a-zA-Z\_][a-zA-Z0-9\_\.]* return 'REF'
".".*                 return 'STR'
","                   return ','
"*"                   return '*'
"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
"^"                   return '^'
"!"                   return '!'
"%"                   return '%'
"("                   return '('
")"                   return ')'
'['                   return '['
']'                   return ']'
"PI"                  return 'PI'
"E"                   return 'E'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */
%left ','
%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS

%start program

%% /* language grammar */

program
    : id EOF {return $id;}
    ;

rand
    : RAND '(' e ',' e')'
        {
            const min = $e1;
            const max = $e2;
            const val = Math.floor(Math.random() * 
                        (max - min)) + 
                        min;
            return {
                min: min,
                max: max,
                valueOf: () => val
            };
        }
    ;

expressions
    : e EOF
        {return $e;}
    ;

id
    : REF 
        {$$ = yy.getRef($REF);}
    | rand
        {$$ = $rand;}
    | id '[' e ',' e ']'
        {
            if ($id >= $e1 && $id < $e2) {
                $$ = $id;
            } else {
                $$ = undefined;
            }
        }
    | id '[' e ',' ']'
        {
            if ($id >= $e) {
                $$ = $id;
            } else {
                $$ = undefined;
            }
        }
    | id '[' ',' e ']'
        {
            if ($id < $e) {
                $$ = $id;
            } else {
                $$ = undefined;
            }
        }
    | id '[' e ']'
        {
            if ($id === $e) {
                $$ = $id;
            } else {
                $$ = undefined;
            }
        }
    ;

e
    : e '+' e
        {$$ = $1+$3;}
    | e '-' e
        {$$ = $1-$3;}
    | e '*' e
        {$$ = $1*$3;}
    | e '/' e
        {$$ = $1/$3;}
    | e '^' e
        {$$ = Math.pow($1, $3);}
    | e '!'
        {{
          $$ = (function fact (n) { return n==0 ? 1 : fact(n-1) * n })($1);
        }}
    | e '%'
        {$$ = $1/100;}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    | '(' e ')'
        {$$ = $2;}
    | NUMBER
        {$$ = Number(yytext);}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    | id
        {$$ = $id;}
    ;

