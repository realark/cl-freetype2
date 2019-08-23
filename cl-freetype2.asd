(cl:eval-when (:load-toplevel :execute)
  (asdf:load-system :cffi-grovel))

(defsystem :cl-freetype2
  :description "Wrapper for the Freetype2 library"
  :author "Ryan Pavlik <rpavlik@gmail.com>"
  :license "New BSD, LLGPL"

  :depends-on (:alexandria :cffi :trivial-garbage)
  :serial t

  :pathname "src"
  :components ((:file "package")

               (:module "freetype2-ffi"
                :pathname "ffi"
                :serial t
                :components
                (
                 #-win32
                 (:module "freetype2-grovel"
                  :pathname "grovel"
                  :components
                          ((:static-file "grovel-freetype.h")
                           (cffi-grovel:grovel-file "grovel-freetype2")))

                 #+win32
                 (:file "grovel/grovel-freetype2-processed-grovel-file")
                 (:file "cffi-cwrap")
                 (:file "cffi-defs")
                 (:file "ft2-lib")
                 (:file "ft2-init")
                 (:file "ft2-basic-types")
                 (:file "ft2-face")
                 (:file "ft2-glyph")
                 (:file "ft2-size")
                 (:file "ft2-outline")
                 (:file "ft2-bitmap")))

               (:file "init")
               (:file "face")
               (:file "bitmap")
               (:file "glyph")
               (:file "render")
               (:file "outline")
               (:file "toy")))

;; Making an :around COMPILE-OP GROVEL-FILE is sortof the right way to do
;; this, if it didn't override everything else anyway.  Fix.
(push (concatenate 'string "-I"
                   (directory-namestring
                    (asdf:component-pathname
                     (asdf:find-component :cl-freetype2 '("freetype2-ffi" #-win32 "freetype2-grovel")))))
      cffi-grovel::*cc-flags*)

(defmethod perform ((o test-op) (c (eql (find-system :cl-freetype2))))
  (operate 'asdf:load-op :cl-freetype2-tests)
  (operate 'asdf:test-op :cl-freetype2-tests))


(defsystem :cl-freetype2-doc
  :description "Documentation generation for cl-freetype2"
  :depends-on (#+sbcl :sb-introspect
               :cl-freetype2 :cl-who :cl-markdown)

  :pathname "doc"
  :serial t
  :components ((:file "gendoc")
               (:file "ft2docs")
               (:static-file "ft2docs.css")))

(defmethod perform :after ((o load-op) (c (eql (find-system :cl-freetype2))))
  (pushnew :freetype2 cl:*features*))

(defmethod perform :after ((o load-op) (c (eql (find-system :cl-freetype2-doc))))
  (let ((fn (find-symbol "GENERATE-DOCS" (find-package :freetype2))))
    (funcall fn)))
