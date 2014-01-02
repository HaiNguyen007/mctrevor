# # Compile Stuff Using Gulp

# ## Requirements

gulp = require 'gulp'
gutil = require 'gulp-util'
ee = require 'streamee'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
clean = require 'gulp-clean'
uglify = require 'gulp-uglify'
template = require 'gulp-template'

# ## Constants

# ### Vendor Files from Bower

VENDOR_FILES_JS = [
  "underscore/underscore-min.js"
  "jquery/jquery.min.js"
  "Eventable/eventable.js"
  "sir-trevor-js/sir-trevor.min.js"
]

VENDOR_FILES_CSS = [
  "sir-trevor-js/sir-trevor-icons.css"
  "sir-trevor-js/sir-trevor.css"
  "bootswatch/yeti/bootstrap.min.css"
]

bowerPrefix = (files) -> files.map (f) -> "bower_components/#{f}"

# ### Paths

destDir = "./public/"

# ## Tasks

gulp.task "clean", cleanPublic = ->
  gulp.src(destDir).pipe(clean())

gulp.task "compile", compileScripts = ->
  console.log "sup?"
  ee.interleave([
    gulp.src("client/js/**/*.coffee").pipe(coffee().on('error', gutil.log))
    gulp.src("client/js/**/*.js")
  ])
  .pipe(concat("app.js"))
  .pipe(uglify())
  .pipe(gulp.dest(destDir))

gulp.task "vendor", copyVendor = ->
  gulp.src(bowerPrefix VENDOR_FILES_JS)
  .pipe(concat("vendor.js"))
  .pipe(uglify())
  .pipe(gulp.dest(destDir))

  gulp.src(bowerPrefix VENDOR_FILES_CSS)
  .pipe(concat("vendor.css"))
  .pipe(gulp.dest(destDir))

gulp.task "templates", renderTemplates = ->
  gulp.src("client/**/*.html")
  .pipe(template
    js: ["vendor.js", "app.js"]
    css: ["vendor.css"]
  )
  .pipe(gulp.dest(destDir))

gulp.task "build", ['vendor', 'compile', 'templates'], ->
  vendorFiles = bowerPrefix VENDOR_FILES_CSS.concat(VENDOR_FILES_JS)
  gulp.watch vendorFiles, (event) ->
    copyVendor()

  gulp.watch "client/js/**/*", (event) ->
    console.log "hi"
    compileScripts()

  gulp.watch "client/**/*.html", (event) ->
    renderTemplates()