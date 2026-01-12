open Hardcaml
open Signal

module Safe_dial = struct

  module I = struct
    type 'a t =
      { clk         : 'a
      ; reset       : 'a
      ; dir         : 'a
      ; instr_valid : 'a
      ; instr_dist  : 'a [@bits 16]
      }
    [@@deriving hardcaml]
  end

  module O = struct
    type 'a t =
      { pos        : 'a [@bits 7]
      ; zero_count : 'a [@bits 32]
      }
    [@@deriving hardcaml]
  end

  let create (_scope : Scope.t) (i : _ I.t) =
    let open Always in

    (* Remaining steps counter *)
    let remaining_steps =
      reg_fb
        ~width:16
        ~clock:i.clk
        ~reset:i.reset
        ~reset_value:(Signal.of_int ~width:16 0)
        (fun _ ->
           let load_instr =
             i.instr_valid &: (remaining_steps ==:. 0)
           in
           mux2 load_instr
             i.instr_dist
             (mux2 (remaining_steps >:. 0)
                (remaining_steps -:. 1)
                remaining_steps))
    in

    let moving = remaining_steps >:. 0 in

    (* Position register *)
    let pos =
      reg_fb
        ~width:7
        ~clock:i.clk
        ~reset:i.reset
        ~reset_value:(Signal.of_int ~width:7 50)
        (fun _ ->
           mux2 moving
             (mux2 i.dir
                (mux2 (pos ==:. 99)
                   (Signal.of_int ~width:7 0)
                   (pos +:. 1))
                (mux2 (pos ==:. 0)
                   (Signal.of_int ~width:7 99)
                   (pos -:. 1)))
             pos)
    in

    (* Zero hit detection *)
    let zero_hit =
      moving &: (pos ==:. 0)
    in

    (* Zero counter *)
    let zero_count =
      reg_fb
        ~width:32
        ~clock:i.clk
        ~reset:i.reset
        ~reset_value:(Signal.of_int ~width:32 0)
        (fun d ->
           mux2 zero_hit
             (d +:. 1)
             d)
    in

    { O.pos = pos
    ; zero_count = zero_count
    }

end
