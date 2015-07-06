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

        container = $("#app")

        ##---- markdown & mathjax ----##

        # can't use test string, so:
        file =  $blab.resource "md_data"

        # replace troublesome stuff
        preText = file
            .replace(/\\\$/g,"\\&pound;") # \$
            .replace(/\\`/g,"\\&sect;") # \`

        # escape matching text
        matchEscape = (text, RE, escape) ->
            out = ""
            pos = 0 # end position of last match 
            while (match = RE.exec(text)) is not null
                preMatch = text[pos...match.index]
                escMatch = escape match[0]
                out += preMatch + escMatch
                pos = match.index+match[0].length 
            out += text[pos..] # from last match to end

        # escape $ within code sections
        escCodeMath = (u) -> u.replace /\$/g, (m) -> "\\&yen;"
        codeRe = /(```)([\s\S]*?)(```)|(`)([\s\S]*?)(`)/mg
        textCodeEsc =  matchEscape(preText, codeRe, escCodeMath)

        # escape MD chars within equations
        escRe = ///[\\`\*_\{\}\[\]\(\)#\+\-\.\!]///g
        escMarkdown = (u) -> u.replace escRe, (m) -> "\\#{m}"
        texRe = /(\$\$)([\s\S]*?)(\$\$)|(\$)([\s\S]*?)(\$)/mg
        textMdEsc =  matchEscape(textCodeEsc, texRe, escMarkdown)

        # restore escaped stuff
        text = textMdEsc
            .replace(///\\&pound;///g,"\\$")
            .replace(///\\&sect;///g,"\\`")
            .replace(///\\&yen;///g,"$")

        console.log "text", text

        ##---- markdown sections ----##

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
            source = text[start..found.end]
            start: start
            pos: found.pos ? 0 
            order: found.order ? 1
            source: source
            html: marked  source
    
        # search file for "found" regex
        found = {}

        while (match = RE.exec(text)) is not null

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
        
        for m in md 
            container.append("<p>pos:#{m.pos}, order:#{m.order}</p>")
            container.append(m.html)
            container.append("<hr color='red'>")

new Markdown
