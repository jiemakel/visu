require!{
  gulp
  \main-bower-files
  \uglify-save-license
}
$ = require(\gulp-load-plugins)!

gulp.task \dist:partials, ->
  gulp.src(".tmp/partials/**/*.html")
    .pipe($.plumber(errorHandler: $.notify.onError("<%= error.stack %>")))
    .pipe($.ngHtml2js(
      moduleName: "app"
      prefix: "partials/"
    ))
    .pipe(gulp.dest(".tmp/partials"))

gulp.task \dist:html, <[dist:partials]>, ->
  jsFilter = $.filter("**/*.js")
  cssFilter = $.filter("**/*.css")
  assets = $.useref.assets!
  gulp.src(".tmp/*.html")
    .pipe($.plumber(errorHandler: $.notify.onError("<%= error.stack %>")))
    .pipe($.inject(gulp.src(".tmp/partials/**/*.js"),
      read: false
      starttag: "<!-- inject:partials-->"
      endtag: "<!-- endinject-->"
      addRootSlash: false
      addPrefix: ".."
    ))
    .pipe(assets)
    .pipe($.rev!)
    .pipe(jsFilter)
    .pipe($.ngAnnotate!)
    .pipe($.uglify(preserveComments: uglifySaveLicense))
    .pipe(jsFilter.restore!)
    .pipe(cssFilter)
    .pipe($.csso!)
    .pipe(cssFilter.restore!)
    .pipe(assets.restore!)
    .pipe($.useref!)
    .pipe($.revReplace!)
    .pipe($.size!)
    .pipe(gulp.dest("dist"))

gulp.task \dist:images, ->
  gulp.src("app/images/**/*")
    .pipe($.plumber(errorHandler: $.notify.onError("<%= error.stack %>")))
    .pipe($.cache($.imagemin(
      optimizationLevel: 3
      progressive: true
      interlaced: true
    )))
    .pipe($.size!)
    .pipe(gulp.dest("dist/images"))

gulp.task \dist:fonts, ->
  gulp.src(mainBowerFiles!)
    .pipe($.plumber(errorHandler: $.notify.onError("<%= error.stack %>")))
    .pipe($.filter("**/*.{eot,svg,ttf,woff}"))
    .pipe($.flatten!)
    .pipe($.size!)
    .pipe(gulp.dest("dist/fonts"))

gulp.task \dist, (cb) ->
  require("run-sequence") \build, <[dist:html dist:images dist:fonts]>, cb
