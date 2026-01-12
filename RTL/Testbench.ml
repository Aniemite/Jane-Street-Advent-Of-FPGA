open Hardcaml
open Hardcaml_waveterm

module Sim = Cyclesim.With_interface
  (Safe_dial.I)
  (Safe_dial.O)

let () =
  let sim = Sim.create Safe_dial.create in
  let i = Sim.inputs sim in
  let o = Sim.outputs sim in

  (* One clock cycle *)
  let cycle () =
    i.clk := Bits.vdd;
    Sim.cycle sim;
    i.clk := Bits.gnd;
    Sim.cycle sim
  in

  (* Reset *)
  i.reset := Bits.vdd;
  cycle ();
  i.reset := Bits.gnd;

  (* Instruction loader *)
  let load_instr ~dir ~dist =
    i.dir := if dir then Bits.vdd else Bits.gnd;
    i.instr_dist := Bits.of_int ~width:16 dist;
    i.instr_valid := Bits.vdd;
    cycle ();
    i.instr_valid := Bits.gnd
  in

  (* Official Advent of Code example input *)
  load_instr ~dir:false ~dist:68; cycle ();
  load_instr ~dir:false ~dist:30; cycle ();
  load_instr ~dir:true  ~dist:48; cycle ();
  load_instr ~dir:false ~dist:5;  cycle ();
  load_instr ~dir:true  ~dist:60; cycle ();
  load_instr ~dir:false ~dist:55; cycle ();
  load_instr ~dir:false ~dist:1;  cycle ();
  load_instr ~dir:false ~dist:99; cycle ();
  load_instr ~dir:true  ~dist:14; cycle ();
  load_instr ~dir:false ~dist:82;

  (* Run simulation long enough to finish *)
  for _ = 0 to 300 do
    cycle ()
  done;

  let result = Bits.to_int !(o.zero_count) in
  Printf.printf "Final zero_count = %d\n" result
