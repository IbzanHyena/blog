require 'regex'
relrequire '../md/md.ijs'

extensions =: <;.1~ ((1) 0}  '.' = ])

ensure =: {{ if. -. fexist y do. 1 !: 5 <y else. 0 end. }}

join =: ('//';'/') stringreplace [ , '/' , ]

fmrx =: rxcomp '^\/\/ ?(.+?): ?(.+?)$'

parseFrontMatter =: {{
  mask =. ([: *./\ [: ; {.@E.~&'//'&.>) y
  extract =. fmrx 1 2 rxextract ]
  fm =. ; extract &.> y #~ mask
  rest =. LF joinstring y #~ -. mask
  fm ; rest
}}

mustacherx =: rxcomp '\{\{(.+?)\}\}'

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
  name =. ; (<'.html') _1} extensions name
  dest =. x join name

  NB. read input file
  'fm contents' =. parseFrontMatter 'b' freads y
  body =. markdown contents
  fm =. ('body' ; body) , fm

  NB. todo use front matter
  template =. fm fillTemplate template

  NB. write output file
  template fwrite dest

  NB. return the frontmatter
  fm
}}

processDir =: {{
  in =. y join 'md'
  out =. y join '_html'
  articleTemplate =. fread 0 {:: 1 dir ('article.html' ,~ y join 'templates')
  files =. 1 dir in join '*.md'
  fms =. out (articleTemplate processFile)&.(a:`>) files
}}
