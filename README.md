# blog

A static blog generator written in J using [md][md].

## Installation

Clone this repo, making sure to initialise submodules.

## Usage

Create a folder to contain the blog files.

Within this, create a Markdown source directory.

Process this source into HTML by running `jconsole /path/to/run.ijs blog` where
`blog` is the name of the markdown source directory.

This will create an output directory called `_site` and containing the HTML
files.

[md]: https://github.com/IbzanHyena/md/

