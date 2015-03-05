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
# \subsection{System file permissions}

class stig_misc::system_files {
# ``System accounts'' and ``system groups'' for use in the next couple of
# requirements.
    $system_users = $osfamily ? {
        'darwin' => [ '_uucp', 'root' ],
        'redhat' => [ 'root' ],
        default  => [ 'root' ],
    }
    $system_groups = $osfamily ? {
        'darwin' => [ '_postdrop', 'admin', 'mail', 'procmod',
                     'staff', 'tty', 'wheel' ],
# Under RHEL, all system files installed by means of RPM packages are owned by
# system groups---but some system groups are owned by a package, such that if
# the package isn't installed, the group won't exist. There's no sense creating
# the group where it doesn't exist, and Puppet can't deal with groups that
# don't exist. But Puppet doesn't mind using numerical group IDs. So we fall
# back on the definition of a ``system group,'' which is a group having an
# identifier less than 500.
#
# N.B. According to Puppet documentation, the default meaning when a list is
# given as a value for something like group ownership of a file is that any
# value in the list is a valid value for the group owner of the file, but if
# the file's group owner is found to be a value not in the list, the group
# owner will be set to the \emph{first value} in the list. So it's significant
# that our list starts with 0, which is the \verb!root! group under RHEL.
        'redhat' => [ 
              0,   1,   2,   3,   4,   5,   6,   7,   8,
              9,  10,  11,  12,  13,  14,  15,  16,  17,
             18,  19,  20,  21,  22,  23,  24,  25,  26,
             27,  28,  29,  30,  31,  32,  33,  34,  35,
             36,  37,  38,  39,  40,  41,  42,  43,  44,
             45,  46,  47,  48,  49,  50,  51,  52,  53,
             54,  55,  56,  57,  58,  59,  60,  61,  62,
             63,  64,  65,  66,  67,  68,  69,  70,  71,
             72,  73,  74,  75,  76,  77,  78,  79,  80,
             81,  82,  83,  84,  85,  86,  87,  88,  89,
             90,  91,  92,  93,  94,  95,  96,  97,  98,
             99, 100, 101, 102, 103, 104, 105, 106, 107,
            108, 109, 110, 111, 112, 113, 114, 115, 116,
            117, 118, 119, 120, 121, 122, 123, 124, 125,
            126, 127, 128, 129, 130, 131, 132, 133, 134,
            135, 136, 137, 138, 139, 140, 141, 142, 143,
            144, 145, 146, 147, 148, 149, 150, 151, 152,
            153, 154, 155, 156, 157, 158, 159, 160, 161,
            162, 163, 164, 165, 166, 167, 168, 169, 170,
            171, 172, 173, 174, 175, 176, 177, 178, 179,
            180, 181, 182, 183, 184, 185, 186, 187, 188,
            189, 190, 191, 192, 193, 194, 195, 196, 197,
            198, 199, 200, 201, 202, 203, 204, 205, 206,
            207, 208, 209, 210, 211, 212, 213, 214, 215,
            216, 217, 218, 219, 220, 221, 222, 223, 224,
            225, 226, 227, 228, 229, 230, 231, 232, 233,
            234, 235, 236, 237, 238, 239, 240, 241, 242,
            243, 244, 245, 246, 247, 248, 249, 250, 251,
            252, 253, 254, 255, 256, 257, 258, 259, 260,
            261, 262, 263, 264, 265, 266, 267, 268, 269,
            270, 271, 272, 273, 274, 275, 276, 277, 278,
            279, 280, 281, 282, 283, 284, 285, 286, 287,
            288, 289, 290, 291, 292, 293, 294, 295, 296,
            297, 298, 299, 300, 301, 302, 303, 304, 305,
            306, 307, 308, 309, 310, 311, 312, 313, 314,
            315, 316, 317, 318, 319, 320, 321, 322, 323,
            324, 325, 326, 327, 328, 329, 330, 331, 332,
            333, 334, 335, 336, 337, 338, 339, 340, 341,
            342, 343, 344, 345, 346, 347, 348, 349, 350,
            351, 352, 353, 354, 355, 356, 357, 358, 359,
            360, 361, 362, 363, 364, 365, 366, 367, 368,
            369, 370, 371, 372, 373, 374, 375, 376, 377,
            378, 379, 380, 381, 382, 383, 384, 385, 386,
            387, 388, 389, 390, 391, 392, 393, 394, 395,
            396, 397, 398, 399, 400, 401, 402, 403, 404,
            405, 406, 407, 408, 409, 410, 411, 412, 413,
            414, 415, 416, 417, 418, 419, 420, 421, 422,
            423, 424, 425, 426, 427, 428, 429, 430, 431,
            432, 433, 434, 435, 436, 437, 438, 439, 440,
            441, 442, 443, 444, 445, 446, 447, 448, 449,
            450, 451, 452, 453, 454, 455, 456, 457, 458,
            459, 460, 461, 462, 463, 464, 465, 466, 467,
            468, 469, 470, 471, 472, 473, 474, 475, 476,
            477, 478, 479, 480, 481, 482, 483, 484, 485,
            486, 487, 488, 489, 490, 491, 492, 493, 494,
            495, 496, 497, 498, 499 ],
        default  => [ 0 ],
    }

# \implements{unixsrg}{GEN001180}%
# \implements{macosxstig}{GEN001180 M6}%
# Make sure all ``network services daemon files'' are not group- or
# world-writable.
#
# (The check content implies that these files are the ones under
# \verb!/usr/sbin!.)
#
# \implements{macosxstig}{GEN001200 M6}%
# Make sure all ``system command files'' are not group- or world-writable.
# 
# (The check content implies that these files are the ones under \verb!/bin!,
# \verb!/sbin! and \verb!/usr/bin!).
#
# \implements{macosxstig}{GEN001220 M6}%
# \implements{unixsrg}{GEN001220}%
# Make sure all ``system files, programs, and directories'' are owned by ``a
# system account.''
#
# (The check content implies that these files are the ones under \verb!/bin!,
# \verb!/sbin!, \verb!/usr/bin!, and \verb!/usr/sbin!.)
#
# \implements{macosxstig}{GEN001240 M6}%
# \implements{unixsrg}{GEN001240}%
# Make sure all ``system files, programs, and directories'' are group-owned by
# ``a system group.''
#
# (The check content imples that these files, unlike the ones in the previous
# requirement, are only the ones under \verb!/usr/bin!. We'll throw the other
# ones in for free.)
    file { ['/bin', '/sbin', '/usr/bin', '/usr/sbin']:
        owner => $system_users,
        group => $system_groups,
        mode => go-w,
        recurse => true,
    }

# \implements{macosxstig}{GEN001190 M6}%
# Remove extended ACLs on ``network services daemon files.''
    no_ext_acl { '/usr/sbin':
        recurse => true,
    }

# \implements{macosxstig}{GEN001210 M6}% 
# Remove extended ACLs on ``system command files.''
    no_ext_acl { ['/bin', '/sbin', '/usr/bin']:
        recurse => true,
    }
}
