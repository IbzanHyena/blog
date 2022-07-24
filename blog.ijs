require 'regex'
relrequire '../md/md.ijs'

NB. split a file name into a boxed array of extensions
extensions =: '.' <;._1 @ , ]

NB. ensure that a directory exists
ensure =: {{ if. -. fexist y do. 1 !: 5 <y else. 0 end. }}

NB. join together two parts of a path
join =: ('//';'/') stringreplace [ , '/' , ]

NB. front matter regex
fmrx =: rxcomp '^\/\/ ?(.+?): ?(.+?)$'

NB. current unused as dircopy causes a segfault in the interpreter
NB. copy the file on the right to the file on the left
NB. boxed filenames or file numbers for both arguments
NB. fcopy =: [ 1!:2~ [: 1!:1 ]
NB.
NB. NB. copy directory y to x
NB. dircopy =: {{
NB.   ensure x
NB.   contents =. |: 0 _1 {"1 (2 1) dir y
NB.   filepaths =. {. contents
NB.   NB. unbox here to get a matrix
NB.   permissions =. > {: contents
NB.   isSubdir =. 'd' = {."1 permissions
NB.   NB. copy files across
NB.   cp =. {{ (< m join y) fcopy (< n join y) }}
NB.   echo 'copying files'
NB.   (x cp y)&.> filepaths #~ -. isSubdir
NB.   NB. recurse for subdirectories
NB.   rec =: {{ (m join y) dircopy (n join y) }}
NB.   echo 'recursing'
NB.   (x rec y) &.> filepaths #~ isSubdir
NB. }}

parseFrontMatter =: {{
  mask =. ([: *./\ [: ; {.@E.~&'//'&.>) y
  extract =. fmrx 1 2 rxextract ]
  fm =. ; extract &.> y #~ mask
  rest =. LF joinstring y #~ -. mask
  fm ; rest
}}

mustacherx =: rxcomp '\{\{([^{}]+)\}\}'

NB. x: values to fill with
NB. y: mustache to replace
fillMustache =: {{
  NB. remove leading {{ and trailing }}
  y =. ({.~ -&2 @ #) 2 }. y
  NB. look up and retrieve from x
  ({:"1 x) {::~ ({."1 x) i. <y
}}

NB. Replace template fields present with their
NB. provided values.
NB. x: the value to fill, as a boxed matrix
NB. y: the template
NB. returns: the modified template
fillTemplate =: {{ mustacherx x&fillMustache rxapply y }}

processFile =: {{
  template =. m
  NB. destination filename
  name =. 1 {:: fpathname y
  ensure x
  name =. '.' joinstring (<'html') _1} extensions name
  dest =. x join name

  NB. read input file
  'fm contents' =. parseFrontMatter 'b' freads y
  body =. markdown contents
  fm =. fm ,~ 'body' ; body
  fm =. fm ,~ 'link' ; name

  NB. todo use front matter
  template =. fm fillTemplate template

  NB. write output file
  template fwrite dest

  NB. Get size
  size =. ": fsize dest

  NB. return the frontmatter
  fm ,~ 'size' ; size
}}

processDir =: {{
  NB. Create articles
  in =. y join 'md'
  out =. y join '_site'
  templates =. y join 'templates'
  getTemplate =. templates {{ fread 0 {:: 1 dir m join y }}
  articleTemplate =. getTemplate 'article.html'
  files =. 1 dir in join '*.md'
  fms =. out (articleTemplate processFile)&.(a:`>) files
  NB. Create contents
  contentsTemplate =. getTemplate 'contents.html'
  contents =. LF joinstring (fillTemplate&contentsTemplate)&.> fms
  indexTemplate =. getTemplate 'index.html'
  index =. indexTemplate fillTemplate~ 'contents' ; contents
  index fwrite out join 'index.html'
  NB. Copy _assets into _site
  NB. assuming we're on a unix system
  2!:0 'cp -r _assets _site/assets'
}}
