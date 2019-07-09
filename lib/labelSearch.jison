
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"if"                  return 'IF'
"is"                  return 'IS'
'in'                  return 'IN'
"<="                  return '<='
">="                  return '>='
'<'                   return '<'
'>'                   return '>'
'range'               return 'RANGE'
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

%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS
%left ','
%left IS '<' '>' '<=' '>=' IN
%left IF

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
            const val = Math.round(Math.random() * 
                        (max - min)) + 
                        min;
            $$ = {
                min: min,
                max: max,
                valueOf: () => val
            };
        }
    ;

round
    : ROUND '(' e ')'
        {
            $$ = Math.round($e);
        }
    ;

range
    : RANGE '(' e ')'
        %{
            $$ = function () {
                let start = 0;
                let end = $e;
                let step = 1;
                let result = [];
                if (start < end) {
                    for (let i = start; i <= end; i += step) {
                        result.push(i);
                    }
                } else if (start > end) {
                    for (let i = start; i >= end; i -= step) {
                        result.push(i);
                    }
                } else {
                    return [end];
                }
                return result;
            }();
        %}
    | RANGE '(' e ',' e ')'
        %{
            $$ = function () {
                let start = $e1;
                let end = $e2;
                let step = 1;
                let result = [];
                if (start < end) {
                    for (let i = start; i <= end; i += step) {
                        result.push(i);
                    }
                } else if (start > end) {
                    for (let i = start; i >= end; i -= step) {
                        result.push(i);
                    }
                } else {
                    return [end];
                }
                return result;
            }();       %}
    | RANGE '(' e ',' e ',' e ')'
        %{
            $$ = function () {
                let start = $e1;
                let end = $e2;
                let step = $e3;
                let result = [];
                if (start < end) {
                    for (let i = start; i <= end; i += step) {
                        result.push(i);
                    }
                } else if (start > end) {
                    for (let i = start; i >= end; i -= step) {
                        result.push(i);
                    }
                } else {
                    return [end];
                }
                return result;
            }();
        %}
    ;

if
    : REF IF cond
        {$$ = $cond && yy.getRef($REF);}
    | REF IF IS e
        {$$ = yy.evalRef($REF) == $e;}
    | REF IF '<=' e
        {$$ = yy.evalRef($REF) <= $e;}
    | REF IF '>=' e
        {$$ = yy.evalRef($REF) >= $e;}
    | REF IF '<' e
        {$$ = yy.evalRef($REF) < $e;}
    | REF IF '>' e
        {$$ = yy.evalRef($REF) > $e;}
    | REF IF IN e
        {
            $$ = function () {
                let target = $e;
                let val = yy.evalRef($REF);
                while (typeof target === "object" && target.value !== undefined) {
                    target = target.value;
                }
                return target.indexOf && (target.indexOf(val) !== -1);
            }();
        }
    ;

cond
    : e IS e
        {$$ = $e1 == $e2;}
    | e '<=' e
        {$$ = $e1 <= $e2;}
    | e '>=' e
        {$$ = $e1 >= $e2;}
    | e '<' e
        {$$ = $e1 < $e2;}
    | e '>' e
        {$$ = $e1 > $e2;}
    | e IN e
        {
            let target = $e2;
            while (typeof target === "object" && target.value !== undefined) {
                target = target.value;
            }
            $$ = target.indexOf && 
                    (target.indexOf($e1) !== -1) || 
                    (target.indexOf(+$e1) !== -1) || 
                    (target.indexOf("" + $e1) !== -1);
        }
    ;

expressions
    : e EOF
        {return $e;}
    ;

id
    : REF 
        {$$ = yy.getRef($REF);}
    | if
        {$$ = $if;}
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
    | rand
        {$$ = $rand;}
    | round
        {$$ = $round;}
    | range
        {$$ = $range;}
    ;

