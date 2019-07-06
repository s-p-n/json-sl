
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"rand"                return 'RAND'
"round"               return 'ROUND'
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
    : STR EOF {return $STR.substr(1);}
    | expressions {return $expressions;}
    ;
round
    : ROUND '(' e ')'
        {
            $$ = Math.round($e);
        }
    ;
rand
    : RAND '(' e ',' e')'
        {
            const min = $e1;
            const max = $e2;
            const val = Math.floor(Math.random() * 
                        (max - min)) + 
                        min;
            $$ = {
                min: min,
                max: max,
                valueOf: () => val
            };
        }
    ;

expressions
    : e EOF
        {return $1;}
    ;

id
    : REF 
        {$$ = yy.getRef($REF);}
    | rand
        {$$ = $rand;}
    | round
        {$$ = $round;}
    | id '[' e ',' e ']'
    | id '[' e ']'
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

