class Markdown

    marked.setOptions
        renderer: new marked.Renderer
        gfm: true
        tables: true
        breaks: false
        pedantic: false
        sanitize: true
        smartLists: true
        smartypants: false
    
    constructor: () ->

        file = """

        # blab heading

        Some *introductory* __text__.

        ## sub heading

        | Tables        | Are           | Cool  |
        | ------------- |:-------------:| -----:|
        | col 3 is      | right-aligned | $1600 |
        | col 2 is      | centered      |   $12 |
        | zebra stripes | are neat      |    $1 |

        1. First ordered list item
        2. Another item
          * Unordered sub-list.

        [I'm an inline-style link](https://www.google.com)

        `pos:6, comment`

        this is some canvas text asdkfh

        | Tables        | Are           | Cool  |
        | ------------- |:-------------:| -----:|
        | col 3 is      | right-aligned | $1600 |
        | col 2 is      | centered      |   $12 |
        | zebra stripes | are neat      |    $1 |


        `pos:7 blah`

        1. First ordered list item
        2. Another item
          * Unordered sub-list.
        
        `pos:2, ord:4`
        
        This is some canvas text.

        `p:5, order:1, another comment`
        123
        
        More canvas text.

        abc
        """

        RE = ///
            ^\s*`\s*                   # begin-line, space and quote
            (?:p|pos)\s*:\s*           # p: or pos:
            (\d+)\s*,?\s*              # digits and comma (optional)
            (?:                        # optional
                (?:o|ord|order)\s*:\s*   # o:, ord: or order:
                (\d+)\s*                 # digits
            )?                         # end optional
            .*`.*$                     # end quote, comment, end-line
            ///mg                      # multiline & globl

        md = []

        snippet = (found) ->
            start  = found.start ? 0
            source = file[start..found.end]
            start: start
            pos: found.pos ? 0 
            order: found.order ? 1
            source: source
            html: marked source
    
        # search file for "found" regex
        found = {}

        while (match = RE.exec(file)) is not null

            # snippet above match
            found.end = match.index-1
            md.push snippet(found)                

            # snippet below match
            found =
                start: match.index+match[0].length+1
                pos: match[1]
                order: match[2]

        # complete snippet below last match
        found.end = -1
        md.push snippet(found)

        # check stuff
        console.log "md", md    
        container = $("#app")
        for m in md 
            container.append("<p>pos:#{m.pos}, order:#{m.order}</p>")
            container.append(m.html)
            container.append("<hr>")

new Markdown
