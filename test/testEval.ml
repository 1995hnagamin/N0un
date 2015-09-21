open OUnit
open Util
open TestUtil
open Syntax
open Eval

let eval_eql_test (title, result, expr) =
  title >:: 
    (fun test_ctxt -> assert_equal result (eval Environment.empty expr))
;;

let prim_eql_tests =
  List.map (fun (x, y) -> eval_eql_test (x, y, y)) [
    "0", Int 0;
    "zero", Zero;
    "succ", Succ;
    "@1/2", Proj(1,2);
    "succ.zero", comp Succ Zero;
    "@1/2->zero", PRec(Proj(1,2), Zero);
  ]
;;

let eval_eql_tests =
  List.map eval_eql_test [
    "zero()", Int 0, App(Zero, []);
    "succ(0)", Int 1, app Succ 0;
    "@3/3(1,2,succ(3))", Int 4,
      App(Proj(3,3), [Int 1; Int 2; App(Succ, [Int 3])]);
    "(@1/2->zero)(43)", Int 42, app (PRec(Proj(1,2), Zero)) 43;
    "(succ.@3/3->@1/1)(10, 5)", Int 15,
      app (PRec(comp Succ Proj(3,3), Proj(1,1))) 15;
  ]
;;

let eval_tests = prim_eql_tests @ eval_eql_tests

let suite = "test eval" >::: eval_tests

let _ = run_throwable_tests suite
