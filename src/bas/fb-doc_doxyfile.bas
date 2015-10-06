/'* \file fb-doc_doxyfile.bas
\brief The source code for the \ref Doxyfile class

This file contains the source code for a class used to read parameters
from a Doxyfile, a file that contain settings to control the operations
of Doxygen. \Proj reads this files to operate on the same folders and
files as Doxygen.

This is used in modes `--list-mode` and `--syntax-mode`.

'/

#INCLUDE ONCE "fb-doc_doxyfile.bi"

'* transfer a tag from a subfile to the current level
#DEFINE PULL_TAG(_N_) IF LEN(d->Tags(_N_)) THEN Tags(_N_) = MKI(aa) & d->Tag(_N_)
'* search for a tag in current file add if non-existent or newer
#DEFINE GET_TAG(_N_) t = Search(#_N_, a) : IF LEN(t) ANDALSO a > CVI(LEFT(Tags(_N_), LEN(INTEGER))) THEN Tags(_N_) = MKI(a) & t

/'* \brief constructor loading and parsing a Doxyfile
\param Fnam The (path and) file name

The constructor tries to find, load and parse the Doxyfile. In case of
failure the variable Errr contains an error message. Otherwise Errr is
empty and the following tags get parsed from the Doxyfile by the
function \ref Search().

- GENERATE_HTML
- SOURCE_BROWSER
- GENERATE_LATEX
- LATEX_SOURCE_CODE
- GENERATE_XML
- XML_PROGRAMLISTING
- INPUT
- RECURSIVE
- OUTPUT_DIRECTORY
- HTML_OUTPUT
- HTML_FILE_EXTENSION
- CREATE_SUBDIRS
- LATEX_OUTPUT
- XML_OUTPUT

\note As in Doxygen, a second tag overrides the first.

\note \Proj doesn't read tag lists, only the first entry of a list.

\note Only the first parameter of the Doxyfile INPUT tag gets used as
      source code path. So make sure that this tag contains the path to
      the FB source code at first place.

'/
CONSTRUCTOR Doxyfile(BYREF Fnam AS STRING)
  VAR fnr = FREEFILE
  IF OPEN(Fnam FOR INPUT AS fnr) THEN Errr = "error (couldn't open)" : EXIT CONSTRUCTOR

  Length = LOF(fnr)
  Buffer = ALLOCATE(Length + 1)
  IF 0 = Buffer THEN Errr = "error (out of memory)" : CLOSE #fnr : Length = 0 : EXIT CONSTRUCTOR

  VAR bytes_red = 0
  GET #fnr, 1, *Buffer, Length, bytes_red
  IF Length <> bytes_red THEN
    Errr = "read error (red " & bytes_red & " of " & Length & " bytes)" : CLOSE #fnr : Length = 0 : EXIT CONSTRUCTOR
  END IF

  Buffer[bytes_red] = 0
  Doxy = CAST(ZSTRING PTR, Buffer)
  CLOSE #fnr

  VAR aa = INSTR(*Doxy, "@INCLUDE"), a = aa, t = ""
  WHILE a
    a += 9
    VAR e = INSTR(a, *Doxy, !"\n")
    VAR d = NEW Doxyfile(TRIM(MID(*Doxy, a, e - a), ANY !"= \v\t\\"))
    PULL_TAG(GENERATE_HTML)
    PULL_TAG(SOURCE_BROWSER)
    PULL_TAG(GENERATE_LATEX)
    PULL_TAG(LATEX_SOURCE_CODE)
    PULL_TAG(GENERATE_XML)
    PULL_TAG(XML_PROGRAMLISTING)
    PULL_TAG(INPUT_TAG)
    PULL_TAG(RECURSIVE)
    PULL_TAG(OUTPUT_DIRECTORY)
    PULL_TAG(HTML_OUTPUT)
    PULL_TAG(HTML_FILE_EXTENSION)
    PULL_TAG(CREATE_SUBDIRS)
    PULL_TAG(LATEX_OUTPUT)
    PULL_TAG(XML_OUTPUT)
    DELETE d
    a = INSTR(e + 1, *Doxy, "@INCLUDE")
  WEND

  GET_TAG(GENERATE_HTML)
  GET_TAG(SOURCE_BROWSER)
  GET_TAG(GENERATE_LATEX)
  GET_TAG(LATEX_SOURCE_CODE)
  GET_TAG(GENERATE_XML)
  GET_TAG(XML_PROGRAMLISTING)
  t = Search("INPUT", a) : IF LEN(t) ANDALSO a > CVI(LEFT(Tags(INPUT_TAG), LEN(INTEGER))) THEN Tags(INPUT_TAG) = MKI(a) & t
  GET_TAG(RECURSIVE)
  GET_TAG(OUTPUT_DIRECTORY)
  GET_TAG(HTML_OUTPUT)
  GET_TAG(HTML_FILE_EXTENSION)
  GET_TAG(CREATE_SUBDIRS)
  GET_TAG(LATEX_OUTPUT)
  GET_TAG(XML_OUTPUT)
END CONSTRUCTOR

/'* \brief destructor freeing the memory used

The destructor frees the memory allocated in the constructor, if any.

'/
DESTRUCTOR Doxyfile()
  IF Buffer THEN DEALLOCATE(Buffer)
END DESTRUCTOR


/'* \brief return a tag value
\param I the index of the tag to get
\returns the tags value (if any)

This property is designed to find the value of a Doxyfile tag. It
return the tags context (or an empty string if the tag has no value).
The position information gets dropped (if any).

'/
PROPERTY Doxyfile.Tag(BYVAL I AS INTEGER) AS STRING
  RETURN MID(Tags(I), LEN(INTEGER) + 1)
END PROPERTY


/'* \brief find a single line tag in the Doxyfile and return its value
\param Su the tag to search for
\param Fl the position of the tag
\returns the tags value (if any))

This function is designed to find the value of a Doxyfile tag. It
return the tags context or an empty string if the tag has no value
or cannot be found.

The Doxyfile is searched in reverse direction (from end to start), in
order to find overrides first.

\note In case of multi line values (ie. a list of paths) only the first
      entry gets returned.

'/
FUNCTION Doxyfile.Search(BYREF Su AS STRING, BYREF Fl AS INTEGER) AS STRING
  VAR i = Length - 1 _
    , l = 0 _
    , p = 0 _
  , lsu = LEN(Su)
  Fl = 0
  FOR i = i TO 0 STEP -1
    SELECT CASE AS CONST Doxy[i]
    CASE ASC(!"\n") :        IF 0 = l THEN Fl = 0 : p = i : CONTINUE FOR
    CASE ASC(!"\r"), ASC(!"\t"), ASC(!"\v"), ASC(" ")
                                              IF 0 = l THEN CONTINUE FOR
    CASE ASC("=") : Fl = i :                                CONTINUE FOR
    CASE ASC("A") TO ASC("Z"), ASC("a") TO ASC("z"), ASC("0") TO ASC("9"), ASC("_"), ASC("@")
      l += IIF(Fl, 1, 0) :                                  CONTINUE FOR
    CASE ELSE :                                             CONTINUE FOR
    END SELECT
    IF l = lsu ANDALSO MID(*Doxy, i + 2, lsu) = Su         THEN EXIT FOR
    l = 0 : Fl = 0 : IF Doxy[i] = ASC(!"\n") THEN p = i
  NEXT
  IF Fl = 0 ORELSE l = 0 THEN RETURN ""
  IF i < 0 ANDALSO (l <> lsu ORELSE MID(*Doxy, i + 2, lsu) <> Su) THEN RETURN ""
  RETURN TRIM(MID(*Doxy, Fl + 2, p - Fl - 1), ANY !" \t\v\\")
END FUNCTION

