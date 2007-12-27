" Vim syntax file
" Language:	SPIM assembler
" Maintainer:	Dan Hirsch <thequux@linux.ucla.edu>
" Last Change:	2007 Apr 30

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

syn match asmDirective		"\.[a-z][a-z]\+"
" storage types
syn match asmType "\.ascii"
syn match asmType "\.asciiz"
syn match asmType "\.byte"
syn match asmType "\.double"
syn match asmType "\.float"
syn match asmType "\.half"
syn match asmType "\.word"
syn match asmType "\.short"
syn match asmType "\.space"

syn match asmLabel		"[a-z_][a-z0-9_]*:"he=e-1
syn match asmIdentifier		"[a-z_][a-z0-9_]*"

" Various #'s as defined by GAS ref manual sec 3.6.2.1
" Technically, the first decNumber def is actually octal,
" since the value of 0-7 octal is the same as 0-7 decimal,
" I prefer to map it as decimal:
syn match decNumber		"0\+[1-7]\=[\t\n$,; ]\@="
syn match decNumber		"[1-9]\d*"
syn match octNumber		"0[0-7][0-7]\+"
syn match hexNumber		"0[xX][0-9a-fA-F]\+"
syn match binNumber		"0[bB][0-1]*"


syn match asmSpecialComment	"#\*\*\*.*"	contains=asmRegister
syn match asmComment		"#.*"		contains=asmRegister

syn match asmInclude		"\.include"
syn match asmCond		"\.if"
syn match asmCond		"\.else"
syn match asmCond		"\.endif"
syn match asmMacro		"\.macro"
syn match asmMacro		"\.endm"


syn match asmRegister		"\$\(zero\|a[t0-3]\|v[01]\|t[0-9]\|s[0-7]\|k[01]\|[gsf]p\|ra\|[12][0-9]\|3[01]\|[0-9]\)\>"

syn keyword asmIntOp		add addi addiu addu div divu mult multu sub subu
syn keyword asmBitOp		and andi or ori sll sllv sra srav srl srlv xor xori
syn keyword asmCondOp		slt slti sltiu sltu
syn keyword asmIntOp		mfc0 mfhi mflo mtc0 mthi mtlo 
syn keyword asmMemOp		lb lbu lh lhu lui lw lwl lwr sb sh sw swl swr la
syn keyword asmBranchOp		beq bgez bgezal bgtz blez bltzal bltz bne rfe
syn keyword asmJumpOp		j jr jal jalr syscall


"syn keyword asmPIntOp		abs
"syn keyword asmPBranchOp	beqz bge bgeu bgt bgtu ble bleu blt bltu bnez b
"syn keyword asmPMiscOp		li move  neg negu not rem remu rol ror seq sge sgeu 
syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_asm_syntax_inits")
  if version < 508
    let did_asm_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink asmSection	Special
  HiLink asmLabel	Label
  HiLink asmComment	Comment
  :hi! link asmDirective PreProc
"  HiLink asmDirective	PreProc

  HiLink asmIntOp	Statement
  HiLink asmBitOp	Statement
  HiLink asmCondOp	Statement
  HiLink asmMemOp	Statement
  HiLink asmBranchOp	Underlined
  HiLink asmJumpOp	Underlined

  HiLink asmInclude	Include
  HiLink asmCond	PreCondit
  HiLink asmMacro	Macro

  HiLink hexNumber	Number
  HiLink decNumber	Number
  HiLink octNumber	Number
  HiLink binNumber	Number

  HiLink asmRegister	Special

  HiLink asmSpecialComment Comment
  HiLink asmIdentifier Identifier
  HiLink asmType	Type

  " My default color overrides:
  " hi asmSpecialComment ctermfg=red
  " hi asmIdentifier ctermfg=lightcyan
  " hi asmType ctermbg=black ctermfg=brown

  delcommand HiLink
endif

let b:current_syntax = "spim"

" vim: ts=8
