require 'regex'
relrequire '../md/md.ijs'

extensions =: <;.1~ ((1) 0}  '.' = ])

ensure =: {{ if. -. fexist y do. 1 !: 5 <y else. 0 end. }}

join =: ('//';'/') stringreplace [ , '/' , ]

fmrx =: rxcomp '^\/\/ ?(.+): ?(.+)$'

parseFrontMatter =: {{
  mask =. ([: *./\ [: ; {.@E.~&'//'&.>) y
  extract =. fmrx 1 2 rxextract ]
  fm =. ; extract &.> y #~ mask
  rest =. LF joinstring y #~ -. mask
  fm ; rest
}}

processFile =: {{
  NB. destination filename
  name =. 1 {:: fpathname y
  ensure x
  name =. ; (<'.html') _1} extensions name
  dest =. x join name

  NB. read input file
  'fm contents' =. parseFrontMatter 'b' freads y
  body =. markdown contents

  NB. todo use front matter

  NB. write output file
  body fwrite dest
}}

processDir =: {{
  in =. y join 'md'
  out =. y join '_html'
  files =. 1 dir in join '*.md'
  out&processFile&.> files
}}
