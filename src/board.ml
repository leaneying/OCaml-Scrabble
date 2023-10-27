open Helper

(** The signature of the scrabble board. *)
module type BoardType = sig
  type tile
  type board_type
  type letter_bank

  val init_board : int -> board_type
  val show_board : board_type -> unit
  val sample : int -> letter_bank -> char list

  val add_word :
    string -> (char * int) * (char * int) -> board_type -> int -> unit

  val init_letter_bank : char list -> letter_bank
  val update_bank : letter_bank -> char list -> letter_bank
  val to_list_bank : letter_bank -> char list
end

(** Module representing a Scrabble board. *)
module ScrabbleBoard : BoardType = struct
  (* Each tile in a board can either be Empty or contain a single char *)
  type tile =
    | Empty
    | Letter of char

  type board_type = tile array array

  (* Letter_bank is a multiset of the Scrabble letters *)
  type letter_bank = char list

  (** Initializes a 2D array which represents the board, of type board_type. *)
  let init_board (n : int) : board_type = Array.make_matrix n n Empty

  (* TODO implement the ASCII representation of the board!! *)
  let tile_to_string (currTile : tile) : string =
    match currTile with
    | Empty -> " - "
    | Letter char -> " " ^ String.make 1 char ^ " "

  (*helper function to convert a letter to a number coordinate BUT ONLY UP TO
    7X7*)
  let position_of_char (letter : char) : int =
    match letter with
    | 'A' -> 1
    | 'B' -> 2
    | 'C' -> 3
    | 'D' -> 4
    | 'E' -> 5
    | 'F' -> 6
    | 'G' -> 7
    | _ -> failwith "invalid coordinate"

  (*helper function to convert a number coordinate to a letter BUT ONLY UP TO
    7X7*)
  let char_of_position (number : int) : char =
    match number with
    | 1 -> 'A'
    | 2 -> 'B'
    | 3 -> 'C'
    | 4 -> 'D'
    | 5 -> 'E'
    | 6 -> 'F'
    | 7 -> 'G'
    | _ -> failwith "invalid coordinate"

  let rec show_coordinates (board : board_type) (index : int) : string =
    if index < Array.length board - 2 then
      (" " ^ String.make 1 (char_of_position (index + 1)) ^ " ")
      ^ show_coordinates board (index + 1)
    else " " ^ String.make 1 (char_of_position (index + 1)) ^ " "

  let rec show_board_helper board (n : int) (m : int) : unit =
    if n >= Array.length board || m >= Array.length board then ()
    else if n = 0 then print_string (string_of_int (m + 1) ^ " ")
    else if n + 1 = Array.length board then
      print_endline (tile_to_string board.(n).(m))
    else print_string (tile_to_string board.(n).(m));

    if n >= Array.length board then
      if m >= Array.length board then () else show_board_helper board 0 (m + 1)
    else show_board_helper board (n + 1) m

  let show_board (board : board_type) : unit =
    print_endline ("  " ^ show_coordinates board 0);
    show_board_helper board 0 0

  (** Given an integer, and the letter bank, returns a list of letters from the
      bank of length [count]. *)
  let rec sample_helper (count : int) (bank : char list) : char list =
    if count == 0 then []
    else
      let n = Random.int (List.length bank) in
      let elem = List.nth bank n in
      elem :: sample_helper (count - 1) (Helper.list_without_elem bank elem)

  let sample (n : int) (bank : char list) : char list =
    match bank with
    | [] -> []
    | h :: t -> sample_helper n bank

  (*helper function to convert a letter to a number coordinate*)
  let position_of_char (letter : char) : int =
    match letter with
    | 'A' -> 1
    | 'B' -> 2
    | 'C' -> 3
    | 'D' -> 4
    | 'E' -> 5
    | 'F' -> 6
    | 'G' -> 7
    | _ -> failwith "invalid coordinate"

  (*helper function to convert a number coordinate to a letter*)
  let char_of_position (number : int) : char =
    match number with
    | 1 -> 'A'
    | 2 -> 'B'
    | 3 -> 'C'
    | 4 -> 'D'
    | 5 -> 'E'
    | 6 -> 'F'
    | 7 -> 'G'
    | _ -> failwith "invalid coordinate"

  (* TODO: write documentation for this *)
  let update_location (location : (char * int) * (char * int)) :
      (char * int) * (char * int) =
    let starting = fst location in
    let ending = snd location in
    if fst starting = fst ending then ((fst starting, snd starting + 1), ending)
    else
      ( (char_of_position (position_of_char (fst starting) + 1), snd starting),
        ending )

  (** Given list of chars representing the word, and a tuple of the starting and
      ending location of word on the board. Requires check_word_fit returns
      true. *)
  let rec add_word (word : string) (location : (char * int) * (char * int))
      (board : board_type) (index : int) =
    board.(position_of_char (fst (fst location))).(snd (fst location) - 1) <-
      Letter word.[index];
    if index + 1 >= String.length word then ()
    else add_word word (update_location location) board (index + 1)

  (* Letter Bank functions *)

  (** Returns a char list representing the letter bank of Scrabble (the letter
      bank is a multiset of English alphabet letters). If the input char list is
      [], then the official Scrabble letter bank is created. Otherwise, the
      letter bank contains exactly the char list which is inputted. Only called
      once per game, at the very beginning. *)
  let init_letter_bank (input : char list) : letter_bank =
    match input with
    | [] ->
        "run/scrabble_letter_bank.txt" |> In_channel.open_text
        |> In_channel.input_all |> Helper.char_list_of_string
    | _ -> input

  (** Given a [letter_bank] and a list of sampled letters [sampled], returns a
      new letter bank without the sampled input. Returns unchanged letter_bank
      if sampled is empty list. Requires that the length of sampled is greater
      than or equal to the size of the letter bank. *)
  let rec update_bank (bank : letter_bank) (sampled : char list) : letter_bank =
    match sampled with
    | [] -> bank
    | h :: t ->
        let x = List.find_opt (fun x -> if x = h then true else false) bank in
        if x = None then h :: update_bank bank t
        else update_bank (Helper.list_without_elem bank (Option.get x)) t

  (** Given [bank] of type letter_bank, returns char list representation of the
      letter bank. *)
  let to_list_bank (bank : letter_bank) = bank
end
