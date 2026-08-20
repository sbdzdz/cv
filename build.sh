#!/bin/sh
# Build cv.pdf from cv.json + cv.css. Pass --html-only to skip the PDF step.
exec node build.mjs "$@"
