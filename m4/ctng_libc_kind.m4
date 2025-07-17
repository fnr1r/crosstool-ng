# CTNG_C_MACRO_DEFINED(PROLOGUE, MACRO_NAME, [VARIABLE_TO_SET], [MESSAGE])
# ------------------------------------------------------------------------
# Checks if a C preprocessor macro MACRO_NAME is defined.
#
# Arguments:
#   MACRO_NAME: The name of the C macro to check (e.g., __GLIBC__).
#   PROLOGUE: Passed as-is to AC_LANG_PROGRAM
#   VARIABLE_TO_SET (optional): An M4 variable to set to 'yes' or 'no'
#     based on the check result. If not provided, the result is stored
#     internally and also made available via AC_SUBST.
#   MESSAGE (optional): Message to print instead of the default:
#     "whether C macro $1 is defined"
#
# Sets:
#   ctng_cv_c_macro_defined_MACRO_NAME (internal cache variable)
#   CTNG_C_MACRO_DEFINED_MACRO_NAME (shell variable for Makefile.am)
#
# Example usage:
#   CTNG_C_MACRO_DEFINED(
#       [__GLIBC__],
#       [[#include <features.h>]],
#       [host_libc_is_glibc],
#       [whether host libc is glibc],
#   )
#   if test "x$host_libc_is_glibc" = xyes; then
#       AC_MSG_NOTICE([The host is bloated.])
#   fi
#   # In Makefile.am, you can use @CTNG_C_MACRO_DEFINED___GLIBC__@
AC_DEFUN([CTNG_C_MACRO_DEFINED],
    [AC_CACHE_CHECK(
        m4_ifval([$4], [$4], [whether C macro $1 is defined]),
        [ctng_cv_c_macro_defined_$1],
        [AC_COMPILE_IFELSE(
            [AC_LANG_PROGRAM(
                [$2],
                [[#ifndef $1
#error $1 not defined
#endif]],
            )],
            [ctng_cv_c_macro_defined_$1=yes],
            [ctng_cv_c_macro_defined_$1=no],
        )]
    )
    m4_ifval(
        [$3],
        [$3=$ctng_cv_c_macro_defined_$1],
    )
    AC_SUBST(
        [CTNG_C_MACRO_DEFINED_$1],
        [$ctng_cv_c_macro_defined_$1],
    )]
)

# CTNG_LIBC_IS_GLIBC([VARIABLE_TO_SET])
# -------------------------------------
# Checks if the HOST libc is glibc by attempting to compile and link
# a small program that includes <features.h> and checks for __GLIBC__.
#
# Arguments:
#   VARIABLE_TO_SET (optional): An M4 variable to set to 'yes' or 'no'
#     based on the check result.
#
# Example usage:
#   CTNG_LIBC_IS_GLIBC([host_libc_is_glibc])
#   if test "x$host_libc_is_glibc" = xyes; then
#       AC_MSG_NOTICE([Host libc is glibc.])
#   else
#       AC_MSG_NOTICE([Host libc is NOT glibc.])
#   fi
AC_DEFUN([CTNG_LIBC_IS_GLIBC],
    [CTNG_C_MACRO_DEFINED(
        [__GLIBC__],
        [[#include <features.h>]],
        [$1],
        [whether host libc is glibc],
    )]
)

# CTNG_SET_KCONFIG_OPTION_X([KCONFIG_OPTION], [VARIABLE])
# -------------------------------------------------------
# I'm bad at naming 2: electic boogaloo
#
# Arguments:
#   KCONFIG_OPTION: KConfig option suffix
#   VARIABLE: An M4 variable that may be set to either 'yes' or 'y' or
#     anything else.
#
# Example usage:
#   CTNG_LIBC_IS_GLIBC([host_libc_is_glibc])
#   CTNG_SET_KCONFIG_OPTION_X([glibc], [host_libc_is_glibc])
#   # Then @KCONFIG_glibc@ is available for use
AC_DEFUN([CTNG_SET_KCONFIG_OPTION_X],
    [AS_IF(
        [test "$$2" = "yes" -o "$$2" = "y"],
        [AC_SUBST([KCONFIG_$1], ["def_bool y"])],
        [AC_SUBST([KCONFIG_$1], ["bool"])],
    )]
)
