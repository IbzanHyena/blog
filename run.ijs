require '~Projects/relimport/relimport.ijs'
relrequire 'blog.ijs'

input =. _1 {:: ARGV

processDir input

exit''
