# % --- BEGIN DISCLAIMER ---
# % Those who use this do so at their own risk;
# % AFSEO does not provide maintenance nor support.
# % --- END DISCLAIMER ---
# % --- BEGIN AFSEO_DATA_RIGHTS ---
# % This is a work of the U.S. Government and is placed
# % into the public domain in accordance with 17 USC Sec.
# % 105. Those who redistribute or derive from this work
# % are requested to include a reference to the original,
# % at <https://github.com/afseo/cmits>, for example by
# % including this notice in its entirety in derived works.
# % --- END AFSEO_DATA_RIGHTS ---
# \section{Add MIME types}
# \label{mimetypes}
#
# Deploy new MIME types. These are necessary on web servers so that Apache can
# send the right HTTP Content-Type header when serving files, so that the
# client on the other end can know what to do with the file it's receiving
# (e.g., show it directly in Word rather than asking what to do with it).
#
# (Stock Apache httpd generally keeps its own MIME types list, but Red Hat has
# patched it to use the systemwide list, so we only need change it once.)


class mimetypes {
# This define will help us insert MIME types below. It is only useful in the
# case where there is a single file extension given for the MIME type.
    define mimetype($ext) {
        require augeas
        # mimetype_$name may be more correct but too long to be wieldy.
        augeas { "mimetype_for_$ext":
            # incl + lens instead of context "greatly speeds up execution"
            incl => "/etc/mime.types",
            lens => "Mimetypes.lns",
            changes => [
                "set rules[.='$name'] '$name'",
                "set rules[.='$name']/rule '$ext'",
            ],
        }
    }

# Office 2007 formats:
# \url{http://blogs.msdn.com/dmahugh/archive/2006/08/08/692600.aspx}
    $avoxfod = "application/vnd.openxmlformats-officedocument"
    $ms = "application/vnd.ms"
    $me12 = "macroEnabled.12"

    # indentation style altered to look better in print
    mimetype {
"${avoxfod}.wordprocessingml.document":   ext => "docx";
"${avoxfod}.wordprocessingml.template":   ext => "dotx";
"${avoxfod}.presentationml.slideshow":    ext => "ppsx";
"${avoxfod}.presentationml.presentation": ext => "pptx";
"${avoxfod}.spreadsheetml.sheet":         ext => "xlsx";
"${ms}-word.document.$me12":              ext => "docm";
"${ms}-word.template.$me12":              ext => "dotm";
"${ms}-powerpoint.slideshow.$me12":       ext => "ppsm";
"${ms}-powerpoint.presentation.$me12":    ext => "pptm";
"${ms}-excel.sheet.binary.$me12":         ext => "xlsb";
"${ms}-excel.sheet.$me12":                ext => "xlsm";
"${ms}-xpsdocument":                      ext => "xps" ;
    }
}
