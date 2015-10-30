Changelog & Credits {#PagChangeLog}
===================
\tableofcontents


Further Development  {#SecToDo}
===================

In combination with Doxygen \Proj is a powerful documentation
system for FreeBASIC source code. The Doxygen support for FreeBasic
is much better than for any other BASIC dialect (ie. like VB6). But
there's still some room for optimization, for Doxygen support as
well as for other features, like:

- additional emitters to support further documentation systems or other tools
- extended SUB / FUNCTION detection for caller / callee graph when using operators `.` or `->`
- implementation of NAMESPACE, SCOPE
- a hash table for callees to speed up the execution
- currently \Proj only works with clean FB code. When one of the
  used standard keywords get #`UNDEF`ined, grazy things may happen.
- ...

Feel free to post your ideas, bug reports, wishes or patches, either
to the project page at

- \Webs

or to the

- [forum page](http://www.freebasic.net/forum/viewtopic.php?f=8&t=19810)

or feel free to send your ideas directly to the author (\Mail).


fb-doc-0.4 {#SecV-0-4}
==========

New:

- GIT repository
- CMake build scripts, modular compiling (in-source / out-of-source)
- separate doc building: doc_htm, doc_pdf
- Doxyfile parsing supports `@INCLUDE` tag now
- source listings: documentational comments get removed now (as in Doxygen listings)
- source listings: new option --doc-comments (-d) to force inclusion of documentational comments
- example plugin py_ctypes to create language bindings for python

Bugfixes:

- syntax highlighter: finds FB source files in subfolders now (TEX, XML)
- syntax highlighter: suppressed #`INCLUDE` statements work now (HTM, TEX, XML)
- fixed interface for external emitter plugins
- plugin example fixed
- parsing problem `REDIM PRESERVE "..."` fixed
- parsing problem `EXTERN "..."` fixed
- parsing problem `DECLARE ...` after bitfields fixed
- better caller / callee graphs (with manual interaction in case of WITH blocks)

Released on 2015 October, ??.


fb-doc-0.2 {#SecV-0-2}
==========

New:

- completely renewed code base
- help and version information
- complete translation of all blocks (TYPE / UNION)
- support for non-case-sensitive FB keywords
- operating on files or pipes (input and output)
- walking through FB source trees
- variable target path
- recursiv scanning of subfolders
- fully Doxygen support, inclusive syntac highlighting in listings
- Geany mode for generating customized templates
- four inbuild emitters (C source, Templates for gtk-doc or Doxygen, Function names)
- interface for external emitter plugins
- self-hosted documentation and tutorial (including caller / callee graphs)

Released on 2013 June, 1.


fb-doc-0.0 {#SecV-0-0}
==========

Initial release on 2012 April, 29.



Credits {#SecCredits}
=======

Thanks go to:

- The FreeBASIC developer team for creating a great compiler.

- Dimitri van Heesch for creating the Doxygen tool, which is used to
  generate this documentation.

- Chris Lyttle, Dan Mueth, Stefan Kost (authors of gtk-doc).

- AGS (from http://www.freebasic.net/forum) for testing and bug reporting.

- All others I forgot to mention.
