# vim-css-toc

A vim 7.4+ plugin to generate table of contents for CSS files.

This is a straight rip-off of the code used for ['mzlogin/vim-markdown-toc']('https://github.com/mzlogin/vim-markdown-toc'), except that it doesn't not provide links within the document and it's for `.css` files instead of markdown.*

Auto-generates a Table of Contents in `.css` files based on section-headings (comments). It will search through a stylesheet and find `/* # Section Headers */`. Use the hashtag (#) character to specify indentation level:

```
/* # Main Level */
.class {
...
}
/* ## Secondary Level */
.class-2 {
...
}
/* ### Tertiary Level */
.class-3 {
...
}
```

This would create a ToC similar to the following:

```
/* BEGIN - Table of Contents =============================== *

+ Main Level
   * Secondary Level
      - Tertiary Level

 * END   - Table of Contents =============================== */
```

## Table of Contents

* [Features](#features)
* [TODO](#todo)
* [Installation](#installation)
* [Usage](#usage)
    * [Generate table of contents](#generate-table-of-contents)
    * [Update existing table of contents](#update-existing-table-of-contents)
    * [Remove table of contents](#remove-table-of-contents)
* [Options](#options)
* [Screenshots](#screenshots)
* [References](#references)

## Features

* Generate table of contents for CSS files.

* Update existing table of contents.

* Auto update existing table of contents on save.

## TODO

- [ ] Screenshots
- [ ] Tests

## Installation

Suggest to manage your vim plugins via [Vundle][4] so you can install it simply three steps:

1. add the following line to your vimrc file

    ```
    Plugin 'l00sed/vim-css-toc'
    ```

2. `:so $MYVIMRC`

3. `:PluginInstall`

Installation with [vim-plug][8] is likeness.

## Usage

### Generate table of contents

Move the cursor to the line you want to append table of contents, then type a command below suit you. The command will generate **headings after the cursor** into table of contents.

`:GenToc`

    Generate table of contents.


### Update existing table of contents

Generally you don't need to do this manually, existing table of contents will auto update on save by default.

The `:UpdateToc` command, which is designed to update toc manually, can only work when `g:vct_auto_update_on_save` turned off, and keep insert fence.

### Remove table of contents

`:RemoveToc` command will do this for you, just remember keep insert fence option by default.

## Options

1. `g:vct_auto_update_on_save`

   default: 1

   This plugin will update existing table of contents on save automatic.

   You can close this feature by add the following line to your vimrc file:

   ```~/.vimrc
   let g:vct_auto_update_on_save = 0
   ```

2. `g:vct_dont_insert_fence`

   default: 0

   By default, the `:GenToc` commands will add `/* BEGIN - Table of Contents` fence to the table of contents, it is designed for feature of auto update table of contents on save and `:UpdateToc` command, it won't effect what your CSS file looks like after parse.

   If you don't like this, you can remove the fence by add the following line to your vimrc file:

   ```~/.vimrc
   let g:vct_dont_insert_fence = 1
   ```

   But then you will lose the convenience of auto update tables of contents on save and `:UpdateToc` command. When you want to update toc, you need to remove existing toc manually and rerun `:GenToc` commands.

3. `g:vct_fence_text`

   default: `BEGIN - Table of Contents`

   Inner text of the fence marker for the table of contents, see `g:vct_dont_insert_fence`.

4. `g:vct_fence_closing_text`

   default: `g:vct_fence_text`

   Inner text of the closing fence marker. E.g., you could `let g:vct_fence_text = 'TOC'` and `let g:vct_fence_closing_text = '/TOC'` to get

   ```
   /* TOC =================================== *
      ...TOC
    * TOD =================================== */
   ```
5. `g:vct_cycle_list_item_markers`

   default: 0

   By default, `*` is used to denote every level of a list:

   ```
   * Level 1
       * Level 1-1
       * Level 1-2
           * Level 1-2-1
   * Level 2
   ```

   If you set:

   ```~/.vimrc
   let g:vct_cycle_list_item_markers = 1
   ```

   every level will instead cycle between the valid list item markers `*`, `-` and `+`:

   ```
   * Level 1
       - Level 1-1
       - Level 1-2
           + Level 1-2-1
   * Level 2
   ```

   Might appeal to those who care about readability of the source.

7. `g:vct_list_item_char`

    default: `*`

    The list item marker, it can be `*`, `-` or `+`.

8. `g:vct_include_headings_before`

    default: `0`

    Include headings before the position you are inserting Table of Contents.

## Screenshots

- [ ] Coming soon...

## References

* <https://github.com/mzlogin/vim-markdown-toc>

