open Syntax
open Util

exception Typing_error of string

let arity = function
  TyPFun n -> n
| TyRFun n -> n
| _ -> raise ( Typing_error "Not a function" )

let rec is_primitive = function
  Zero -> true
| Succ -> true
| Proj(_,_) -> true
| Comp(g, fs) -> List.for_all is_primitive (g::fs)
| PRec(g, f)  -> is_primitive g && is_primitive f
| _ -> raise ( Typing_error "Not a function" )

let arity_comp t_g t_fs =
  let k = arity t_g in
  if not ( is_same_as arity t_fs )
  then raise ( Typing_error "Arities of functions don't match" )
  else
    if not ( k = List.length t_fs )
    then raise ( Typing_error "arity doesn't match" )
    else k

let ty_fun f k = if is_primitive f then TyPFun k else TyRFun k

let rec eval_ty env = function
  Int _ -> TyInt
| App (f, xs) ->
    let k = arity (eval_ty env f) in
    (match () with
      _ when not (List.for_all (fun x -> eval_ty env x = TyInt) xs) ->
        raise (Typing_error "Non-integer object is applied")
    | _ when k != List.length xs ->
        raise (Typing_error "Arity doesn't match")
    | _ -> TyInt
      )
| Zero -> TyPFun 0
| Succ -> TyPFun 1
| Proj(x, y) -> TyPFun y
| Comp(g, fs) ->
    let t_g  = eval_ty env g
    and t_fs = List.map (eval_ty env) fs in
    (match t_fs with
      _ when arity t_g != List.length t_fs -> raise (Typing_error "Arity doesn't match")
    | _ when is_different arity t_fs -> raise (Typing_error "Arities of functions don't match")
    | [] -> t_g
    | t_f::_ -> ty_fun (Comp(g, fs)) (arity t_f))
| PRec(g, f) ->
    let y = arity (eval_ty env g)
    and x = arity (eval_ty env f) in
    (match () with
      _ when x + 2 != y -> raise (Typing_error "Arity doesn't match")
    | _ -> ty_fun (PRec (g, f)) (x + 1))
;;