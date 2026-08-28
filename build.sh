#!/bin/sh
# Build sebastian_dziadzio_cv.pdf from cv.json + cv.css.
# Pass --html-only to skip the PDF step.
exec node build.mjs "$@"
