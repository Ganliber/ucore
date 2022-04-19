{
  Delphi Yacc & Lex
  Copyright (c) 2003,2004 by Michiel Rook
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92  Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996     Berend de Boer <berend@pobox.com>
  Copyright (c) 1998     Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  
  ## $Id: yaccmsgs.pas 11962 2005-10-27 14:47:09Z dpollard $

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

unit yaccmsgs;

interface


var
  errors, warnings: integer;

(* - current error and warning count *)
procedure error(msg: string);
  (* - print current input line and error message (pos denotes position to
       mark in source file line) *)
procedure warning(msg: string);
(* - print warning message *)
procedure fatal(msg: string);
(* - writes a fatal error message, erases Yacc output file and terminates
     the program with errorlevel 1 *)

const

  (* sign-on and usage message: *)

  sign_on = 'Delphi Yacc - Copyright (c) 2003,2004 by Michiel Rook'#13#10'Based on Turbo Pascal Yacc 4.1, Copyright (c) 1990-2000 Albert Graef';
  usage   = 'Usage: dyacc [options] yacc-file[.y] [output-file[.pas]]';
  options = 'Options: -v verbose, -d debug, -r readonly output';

  (* command line error messages: *)

  invalid_option  = 'invalid option ';
  illegal_no_args = 'illegal number of parameters';

  (* syntax errors: *)

  open_comment_at_eof = '101: open comment at end of file';
  missing_string_terminator = '102: missing string terminator';
  rcurl_expected = '103: %} expected';
  rbrace_expected = '104: } expected';
  rangle_expected = '105: > expected';
  ident_expected = '106: identifier expected';
  error_in_def   = '110: error in definition';
  error_in_rule  = '111: error in rule';
  syntax_error   = '112: syntax error';
  unexpected_eof = '113: unexpected end of file';

  (* semantic errors: *)

  nonterm_expected = '201: nonterminal expected';
  literal_expected = '202: literal expected';
  double_tokennum_def = '203: literal already defined';
  unknown_identifier = '204: unknown identifier';
  type_error    = '205: type error';
  range_error   = '206: range error';
  empty_grammar = '207: empty grammar?';

  (* fatal errors: *)

  cannot_open_file = 'FATAL: cannot open file ';
  write_error      = 'FATAL: write error';
  mem_overflow     = 'FATAL: memory overflow';
  intset_overflow  = 'FATAL: integer set overflow';
  sym_table_overflow = 'FATAL: symbol table overflow';
  nt_table_overflow = 'FATAL: nonterminal table overflow';
  lit_table_overflow = 'FATAL: literal table overflow';
  type_table_overflow = 'FATAL: type table overflow';
  prec_table_overflow = 'FATAL: precedence table overflow';
  rule_table_overflow = 'FATAL: rule table overflow';
  state_table_overflow = 'FATAL: state table overflow';
  item_table_overflow = 'FATAL: item table overflow';
  trans_table_overflow = 'FATAL: transition table overflow';
  redn_table_overflow = 'FATAL: reduction table overflow';

implementation

uses
  yaccbase;

procedure position(var f: Text; lineNo: integer;
  line: string; pos: integer);
  (* writes a position mark of the form
     lineno: line
               ^
     on f with the caret ^ positioned at pos in line
     a subsequent write starts at the next line, indented with tab *)
var
  line1, line2: string;
begin
  (* this hack handles tab characters in line: *)
  line1 := intStr(lineNo) + ': ' + line;
  line2 := blankStr(intStr(lineNo) + ': ' + copy(line, 1, pos - 1));
  writeln(f, line1);
  writeln(f, line2, '^');
  Write(f, tab)
end(*position*);

procedure error(msg: string);
begin
  Inc(errors);
  writeln;
  position(output, lno, line, cno - tokleng);
  writeln(msg);
  writeln(yylst);
  position(yylst, lno, line, cno - tokleng);
  writeln(yylst, msg);
  if ioresult <> 0 then
  ;
end(*error*);

procedure warning(msg: string);
begin
  Inc(warnings);
  writeln;
  position(output, lno, line, cno - tokleng);
  writeln(msg);
  writeln(yylst);
  position(yylst, lno, line, cno - tokleng);
  writeln(yylst, msg);
  if ioresult <> 0 then
  ;
end(*warning*);

procedure fatal(msg: string);
begin
  writeln;
  writeln(msg);
  Close(yyin);
  Close(yyout);
  Close(yylst);
  erase(yyout);
  halt(1)
end(*fatal*);

begin
  errors   := 0;
  warnings := 0;
end(*YaccMsgs*).
