{
open Syntax

let proj_of_string str =
  Scanf.sscanf str "@%d/%d" (fun x y -> (x, Arity.exact y))

let maybe_assoc default key alist =
  try 
    List.assoc key alist
  with
    Not_found -> default

let keywords = [
  "Let", Parser.LET;
  "In", Parser.IN;
  "Print", Parser.PRINT;
]

}

rule main = parse
  [' ' '\009' '\012' '\n']+ { main lexbuf }
| ['0'-'9']+ 
  { Parser.INTV (int_of_string (Lexing.lexeme lexbuf)) }
| "("  { Parser.LPAREN }
| ")"  { Parser.RPAREN }
| "["  { Parser.LBRAKET }
| "]"  { Parser.RBRAKET }
| "->" { Parser.RARROW }
| "."  { Parser.DOT }
| "="  { Parser.EQ }
| ";" { Parser.SEMI }
| ","  { Parser.COMMA }
| "@" ['0'-'9']+ "/" ['0'-'9']+
  { Parser.PROJECTOR (proj_of_string (Lexing.lexeme lexbuf)) }
| "@" ['0'-'9']+
  {
    let proj_of_string str = Scanf.sscanf str "@%d" (fun x -> (x, Arity.at_least x)) in 
    Parser.PROJECTOR (proj_of_string (Lexing.lexeme lexbuf))
  }
| ['a'-'z']['a'-'z' '0'-'9' '_']*
  { let id = Lexing.lexeme lexbuf in Parser.ID id }
| ['A'-'Z']['A'-'Z' 'a'-'z' '0'-'9']*
  {
    let keyword = Lexing.lexeme lexbuf in
    List.assoc keyword keywords
  }
| eof { Parser.EOL }
