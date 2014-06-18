should = require('chai').should()
fs = require 'fs'
request = require 'supertest'
express = require 'express'
stasset = require './index'

app = express()

app.use(stasset({root: "#{__dirname}/../test/assets"}))

loadFixture = (fixture)->
    fs.readFileSync(
        "#{__dirname}/../test/fixtures/#{fixture}"
    ).toString('utf-8')

describe "DS Asset Middleware", ->
    before (done)->
        # Let the watchers compile
        setTimeout done, 50

    describe "Index", ->
        it 'renders jade to html', (done)->
            request(app)
            .get('/index.html')
            .set('Accept', 'text/html')
            .expect(200)
            .expect('Content-Type', /html; charset=utf-8/)
            .expect(loadFixture('index.html'))
            .end(done)

        it 'injects fingerprints', ->

    describe "Templates", ->
        it 'renders jade to JS', (done)->
            request(app)
            .get('/templates.js')
            .set('Accept', 'application/javascript')
            .expect(200)
            .expect('Content-Type', /javascript/)
            .expect(loadFixture('templates.js'))
            .end(done)

        it 'inserts into correct modules', ->

    describe "App Styles", ->
        it 'renders Stylus with Nib', (done)->
            request(app)
            .get('/screen.css')
            .expect(200).expect('Content-Type', /css/)
            .expect(loadFixture('screen.css'))
            .end(done)

        it 'renders all', (done)->
            request(app)
            .get('/all.css')
            .expect(200).expect('Content-Type', /css/)
            .expect(loadFixture('all.css'))
            .end(done)

        it 'renders print', (done)->
            request(app)
            .get('/print.css')
            .expect(200).expect('Content-Type', /css/)
            .expect(loadFixture('print.css'))
            .end(done)


    describe "Application", ->
        it 'loads application code', (done)->
            request(app)
            .get('/application.js')
            .set('Accept', 'application/javascript')
            .expect(200)
            .expect('Content-Type', /javascript/)
            .expect(loadFixture('application.js'))
            .end(done)

        it 'ignores test code', ->

        it 'generates a source map', (done)->
            request(app)
            .get('/application.js.map')
            .expect(200)
            .expect(loadFixture('application.js.map'))
            .end(done)

    describe "Vendors", ->
        it 'loads the vendors js', (done)->
            request(app)
            .get('/vendors.js')
            .set('Accept', 'application/javascript')
            .expect(200)
            .expect('Content-Type', /javascript/)
            # .expect(loadFixture('vendors.js'))
            .end(done)

    describe "Vendor Styles", ->
        it 'loads a joined stylesheet', (done)->
            request(app)
            .get('/vendors.css')
            .expect(200).expect('Content-Type', /css/)
            # .expect(loadFixture('vendors.css'))
            .end(done)
