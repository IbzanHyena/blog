require 'regex'
require 'general/dirtrees'
require 'general/dirutils'
require '~Projects/relimport/relimport.ijs'
relrequire 'md/md.ijs'

NB. split a file name into a boxed array of extensions
extensions =: '.' <;._1 @ , ]

NB. ensure that a directory exists
ensure =: {{ if. -. direxist y do. dircreate <y else. 0 end. }}

NB. join together two parts of a path
join =: ('//';'/') stringreplace [ , '/' , ]

NB. front matter regex
fmrx =: rxcomp '^\/\/ ?(.+?): ?(.+?)$'

NB. retrieve a cell from a boxed associative array
NB. the AA should have two columns: first is the key, second is the value
NB. x: AA
NB. y: key
aaget =: {{ ({:"1 x) {::~ ({."1 x) i. <y }}

parseFrontMatter =: {{
  NB. separate the input into frontmatter and rest
  mask =. *./\ {.@E.~&'//'@> y
  extract =. [: , fmrx 1 2 rxextract ]
  fm =. extract@> y #~ mask
  rest =. LF joinstring y #~ -. mask

  NB. prepare the title-header frontmatter
  title =. fm aaget 'title'
  id =. sanitise LF -.~ tolower title
  anchor =. ('a'; <'id' ; id ; 'href' ; '#',id) htmlElementA inlineFormatting title
  titleHeader =. ('h1' ; <'class';'header') htmlElementA anchor
  fm =. fm , 'title-header' ; titleHeader

  NB. return the frontmatter and the rest of the article
  fm ; rest
}}

mustacherx =: rxcomp '\{\{([^{}]+)\}\}'

NB. x: values to fill with
NB. y: mustache to replace
fillMustache =: {{
  NB. remove leading {{ and trailing }}
  y =. ({.~ -&2 @ #) 2 }. y
  NB. look up and retrieve from x
  x aaget y
}}

NB. Replace template fields present with their
NB. provided values.
NB. x: the value to fill, as a boxed matrix
NB. y: the template
NB. returns: the modified template
fillTemplate =: {{ mustacherx x&fillMustache rxapply y }}

processBlogPost =: {{
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

  NB. return the frontmatter
  fm
}}

processDir =: {{
  NB. Create articles
  in =. y join 'articles'
  out =. y join '_site'
  templates =. y join 'templates'
  getTemplate =. templates {{ fread 0 {:: 1 dir m join y }}
  articleTemplate =. getTemplate 'article.html'
  files =. 1 dir in join '*.md'
  fms =. out (articleTemplate processBlogPost)&.(a:`>) files
  NB. Sort by date, descending
  dates =. (getdate @ aaget&'date')@> fms
  fms =. fms \: dates
  NB. Create index file
  intro =. markdown fread 'index.md'
  contentsTemplate =. getTemplate 'contents.html'
  contents =. LF joinstring (fillTemplate&contentsTemplate)&.> fms
  indexTemplate =. getTemplate 'index.html'
  index =. indexTemplate fillTemplate~ ('intro' ; intro) ,: 'contents' ; contents
  index fwrite out join 'index.html'
  NB. Create 404 file
  p404 =. markdown fread '404.md'
  p404Template =. getTemplate '404.html'
  p404 =. p404Template fillTemplate~ 'body' ; p404
  p404 fwrite out join '404.html'
  NB. Copy _assets into _site
  ensure '_site/assets'
  '_site/assets' copytree '_assets'
}}
