%{
open Syntax

%}
%token LPAREN RPAREN LBRAKET RBRAKET
%token RARROW DOT EQ COMMA SEMI
%token LET IN PRINT
%token EOL

%token <int> INTV
%token <Syntax.id> ID
%token <(int * Syntax.Arity.t)> PROJECTOR

%start toplevel
%type <Syntax.program> toplevel
%%

toplevel : Program { $1 }

Program :
  Stmt EOL { [$1] }
| Stmt Program { $1::$2 }

Stmt :
  LetDecl SEMI { $1 }
| PrintStmt SEMI { $1 }

Expr :
  RExpr { $1 }
| LetExpr { $1 }

RExpr :
  DExpr RARROW RExpr { (PRec ($1, $3)) }
| DExpr { $1 }

DExpr :
  AExpr DOT DExpr { Comp($1, [$3]) }
| AExpr { $1 }

AExpr :
  CExpr LPAREN RPAREN { App ($1, []) }
| CExpr LPAREN Composee RPAREN { App ($1, $3) }
| CExpr { $1 }

CExpr :
  IExpr LBRAKET RBRAKET { (Comp ($1, [])) }
| IExpr LBRAKET Composee RBRAKET { (Comp ($1, $3)) }
| IExpr { $1 }

Composee :
  Expr { [$1] }
| Expr COMMA Composee { $1::$3 }

IExpr :
  INTV { Int $1 }
| ID   { Var $1 }
| Projection { $1 }
| LPAREN Expr RPAREN { $2 }

Projection :
  PROJECTOR { Proj $1 }

LetExpr :
  LET ID EQ Expr IN Expr { LetExp($2, $4, $6) }

LetDecl :
  LET ID EQ Expr { LetDecl($2, $4) }

PrintStmt :
  PRINT Expr { PrintStmt($2) }
