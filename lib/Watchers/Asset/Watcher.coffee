fs = require 'fs'
Path = require 'path'
LogEmitter = require './LogEmitter'
Mirror = require './mirror'

class AssetWatcher extends LogEmitter
    constructor: ->
        @filelist = {}
        @config or= {verbose: no, howMany: 'some'}

        @config.root = (@config.root or ['./']).map Path.normalize

        super()

        @watch new Mirror(
            @config.root
            @pattern()
            @config
        )

    pattern: (patterns)->
        rootPatterns = (pattern)=>
            if pattern.indexOf('!') is 0
                [pattern]
            else
                @config.root.map (root)->
                    "#{root}/#{pattern}"
        flatten = (a, v)->a.concat(v)
        fullList = patterns.map(rootPatterns).reduce(flatten, [])
        fullList

    watch: (@gaze)->
        @printedEMFILE = @printedEMFILE or no
        @gaze.on 'error', (_)=>
            switch _.code
                when 'EMFILE'
                    unless @printedEMFILE
                        file = _.message.match(/"([^"]+)"/)?[1] or 'ERR_FILE'
                        console.log 'EMFILE', file
                        console.log 'This is likely due to a large watch list.'
                        console.log 'It will still work, but be slow (polling).'
                        console.log 'Consider using `ulimit -n` to raise limit.'
                        console.log ''
                        @printedEMFILE = yes
                else
                    console.log _.code

        @gaze.on 'ready', =>
            @gaze.watched (err, filelist = {})=>
                return @printError('watch ready', err) if err
                Object.keys(filelist).forEach (file)=>
                    @add file
                @compile()

        @gaze.on 'added', (_)=> @add _ ; @compile()
        @gaze.on 'deleted', (_) => @remove _ ; @compile()
        @gaze.on 'changed', (_)=> @compile()
        @gaze.on 'renamed', (n, o)=> @remove o ; @add n ; @compile()

        @gaze.on 'all', (code, event)=>
            @log {code, event}

    add: (filepath)->
        @filelist[filepath] = yes

    remove: (filepath)->
        @filelist[filepath] = no
        delete @filelist[filepath]

    pathpart: (path)->
        @config.root.reduce ((path, root)-> path.replace(root, '')), path

    ###
    This should return an array of files in the correct insert order.
    ###
    getFilenames: ->
        list = Object.keys(@filelist)
        hset = {}
        list.forEach (path)=>
            hset[@pathpart(path)] = path
        hlist = (v for k, v of hset)
        hlist

    getPaths: -> []
    matches: (path)-> path in @getPaths()

    compile: -> throw new Error 'Virtual Exception: Compile not overriden!'

module.exports = AssetWatcher
