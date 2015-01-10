gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
shell = require 'gulp-shell'
fs = require 'fs'
mocha = require 'gulp-mocha'
watch = require 'gulp-watch'
replace = require 'gulp-replace'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
chai = require 'chai'
sinonChai = require 'sinon-chai'

gulp.task 'default', ['build', 'docs', 'uglify']

gulp.task 'watch', ->
  gulp.watch('./src/*.coffee', ['default'])

gulp.task 'coffee', ->
  gulp
    .src('./src/*.coffee')
    .pipe(coffee(bare: true)
    .on('error', gutil.log))
    .pipe gulp.dest('./dist/')

gulp.task 'build', ['coffee'], ->
  gulp
    .src('./src/*.coffee')
    .pipe(replace(/(.*) = require (.*)/g, ''))
    .pipe(replace('module.exports = Databound', ''))
    .pipe(coffee(bare: true)
    .on('error', gutil.log))
    .pipe(rename('databound-standalone.js'))
    .pipe(gulp.dest('./dist/'))

gulp.task 'uglify', ['build'], ->
  gulp
    .src('./dist/databound-standalone.js')
    .pipe(uglify())
    .pipe(rename('databound-standalone.min.js'))
    .pipe(gulp.dest('./dist/'))

gulp.task 'docs', shell.task('node_modules/groc/bin/groc src/*.coffee')

gulp.task 'test', ->
  chai.use(sinonChai)
  global.expect = chai.expect
  gulp.src('spec/**/*.coffee', read: false)
  .pipe(mocha(
    reporter: 'spec'
  ).on('error', gutil.log))
