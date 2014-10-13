gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'

gulp.task 'default', ->
  gulp
    .src('./src/*.coffee')
    .pipe(coffee(bare: true)
    .on('error', gutil.log))
    .pipe gulp.dest('./dist/')
