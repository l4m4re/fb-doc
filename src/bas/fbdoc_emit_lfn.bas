/'* \file fbdoc_emit_lfn.bas
\brief Emitter to generate the file `fb-doc.lfn`.

This file contains the emitter \ref SecEmmList, which is the default
emitter in mode \ref SecModList. It's used to generate the file \ref
SubInLfn for the Doxygen back-end filter feature.

The emitter writes the names of all functions (`SUB` / `FUNCTION` /
`PROPERTY`) to the output stream, one in a line, separated by a new
line character `CHR(10)`.

'/

#INCLUDE ONCE "fbdoc_options.bi"
#INCLUDE ONCE "fbdoc_emit_lfn.bi"



FUNCTION startLFN(BYREF Path AS STRING) AS INTEGER
  VAR fnr = FREEFILE
  IF OPEN(Path & LFN_FILE FOR OUTPUT AS #fnr) THEN RETURN 0
  PRINT #fnr, "+++ List of Function Names +++"
  RETURN fnr
END FUNCTION


'SUB lfn_CTOR CDECL(BYVAL P AS Parser PTR)
      'IF 0 = Ocha THEN
        'MSG_LINE(OutPath & LFN_FILE)
        'Ocha = startLFN(OutPath)
        'IF 0 = Ocha THEN MSG_END("error (couldn't write)") : EXIT SUB
        'MSG_END("opened")
      'END IF
'END SUB


'SUB lfn_DTOR CDECL(BYVAL P AS Parser PTR)
'END SUB


/'* \brief Emitter to generate a declaration line
\param P the parser calling this emitter

This emitter gets called when the parser is in a declaration (VAR /
DIM / CONST / COMMON / EXTERN / STATIC / DECLARE). It generates a line for
each variable name and sends it (them) to the output stream.

'/
SUB lfn_decl_ CDECL(BYVAL P AS Parser PTR)
  WITH *P '&Parser* P;
    SELECT CASE AS CONST *.StaTok
    CASE .TOK_SUB, .TOK_FUNC, .TOK_PROP
    CASE ELSE : EXIT SUB
    END SELECT : IF 0 = .NamTok ORELSE 0 = .FunTok THEN EXIT SUB
    .PtrCount = 0
    cNam(P)
    Code(LFN_SEP)
  END WITH
END SUB


/'* \brief Emitter to start parsing of blocks
\param P the parser calling this emitter

This emitter gets called when the parser finds a block (`TYPE  UNION
ENUM`). It starts the scanning process in the block.

'/
SUB lfn_class_ CDECL(BYVAL P AS Parser PTR)
  WITH *P '&Parser* P;
    IF OPT->AllCallees THEN .parseBlockTyUn(@lfn_decl_())
  END WITH
END SUB


/'* \brief Emitter to generate a line for a function name
\param P the parser calling this emitter

This emitter gets called when the parser finds a function (`SUB
FUNCTION  PROPERTY`). It generates a line with the name of the
function and sends it to the output stream.

'/
SUB lfn_func_ CDECL(BYVAL P AS Parser PTR) ' !!! ToDo member functions
  WITH *P '&Parser* P;
    SELECT CASE AS CONST *.StaTok
    CASE .TOK_SUB, .TOK_FUNC, .TOK_PROP
    CASE .TOK_CTOR : Code(.SubStr(.NamTok) & ".")
    CASE ELSE : EXIT SUB
    END SELECT
    .PtrCount = 0
    cNam(P)
    Code(LFN_SEP)
  END WITH
END SUB


/'* \brief Emitter to import a source file
\param P the parser calling this emitter

This emitter gets called when the parser finds an #`INCLUDE` statement
and option \ref SecOptRecursiv is given. It checks if the file has been
done already. If not, it creates a new #Parser and starts the scanning
process.

'/
SUB lfn_include CDECL(BYVAL P AS Parser PTR)
  WITH *P '&Parser* P;
    IF OPT->InTree THEN .Include(TRIM(.SubStr(.NamTok), """"))
  END WITH
END SUB



/'* \brief Initialize the `FunctionNames` EmitterIF
\param Emi The EmitterIF to initialize

FIXME

\since 0.4.0
'/
SUB init_lfn(BYVAL Emi AS EmitterIF PTR)
  WITH *Emi
    .Clas_ = @lfn_class_()
    .Unio_ = @lfn_class_()
    .Func_ = @lfn_func_()
    .Decl_ = @lfn_decl_()
    .Incl_ = @lfn_include()
  END WITH
END SUB

