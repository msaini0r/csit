# -*- coding: utf-8 -*-

"""CSIT report documentation build configuration file

This file is execfile()d with the current directory set to its
containing dir.

Note that not all possible configuration values are present in this
autogenerated file.

All configuration values have a default; values that are commented out
serve to show the default.

If extensions (or modules to document with autodoc) are in another directory,
add these directories to sys.path here. If the directory is relative to the
documentation root, use os.path.abspath to make it absolute, like shown here.
"""


import os
import sys

sys.path.insert(0, os.path.abspath(u'.'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [u'sphinxcontrib.programoutput',
              u'sphinx.ext.ifconfig']

# Add any paths that contain templates here, relative to this directory.
templates_path = [u'_templates']

# The suffix(es) of source file names.
# You can specify multiple suffix as a list of string:
#
source_suffix = [u'.rst', u'.md']

# The master toctree document.
master_doc = u'index'

# General information about the project.
report_week = u'11'
project = u'FD.io CSIT-2202.{week}'.format(week=report_week)
copyright = u'2022, FD.io'
author = u'FD.io CSIT'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
# version = u''
# The full version, including alpha/beta/rc tags.
# release = u''

rst_epilog = u"""
.. |release-1| replace:: {prev_release}
.. |srelease| replace:: {srelease}
.. |csit-release| replace:: CSIT-{csitrelease}
.. |csit-release-1| replace:: CSIT-{csit_prev_release}
.. |vpp-release| replace:: VPP-{vpprelease} release
.. |vpp-release-1| replace:: VPP-{vpp_prev_release} release
.. |dpdk-release| replace:: DPDK-{dpdkrelease}
.. |dpdk-release-1| replace:: DPDK-{dpdk_prev_release}
.. |trex-release| replace:: TRex {trex_version}

.. _pdf version of this report: https://s3-docs.fd.io/csit/{release}/report/_static/archive/csit_{release}.{report_week}.pdf
.. _tag documentation rst file: https://git.fd.io/csit/tree/docs/tag_documentation.rst?h={release}
.. _TRex driver: https://git.fd.io/csit/tree/GPL/tools/trex/trex_stl_profile.py?h={release}
.. _CSIT Performance Tests Documentation: https://s3-docs.fd.io/csit/{release}/docs/index.html
.. _VPP test framework documentation: https://docs.fd.io/vpp/{vpprelease}/vpp_make_test/html/
.. _FD.io CSIT testbeds - Xeon Skylake, Arm, Atom: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_skx_hw_bios_cfg.md?h={release}
.. _FD.io CSIT testbeds - Xeon Cascade Lake: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_clx_hw_bios_cfg.md?h={release}
.. _Ansible inventory - hosts: https://git.fd.io/csit/tree/fdio.infra.ansible/inventories/lf_inventory/host_vars?h={release}
.. _build logs from FD.io trex performance job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-iterative-{srelease}-2n-skx
.. _build logs from FD.io dpdk performance job 3n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-skx
.. _build logs from FD.io dpdk performance job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-skx
.. _build logs from FD.io dpdk performance job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-clx
.. _build logs from FD.io dpdk performance job 2n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-dnv
.. _build logs from FD.io dpdk performance job 3n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-dnv
.. _build logs from FD.io dpdk performance job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-tsh
.. _build logs from FD.io dpdk performance job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-tx2
.. _build logs from FD.io dpdk performance job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-zn2
.. _build logs from FD.io vpp performance job 3n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-skx
.. _build logs from FD.io vpp performance job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-skx
.. _build logs from FD.io vpp performance job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-tsh
.. _build logs from FD.io vpp performance job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-tx2
.. _build logs from FD.io vpp performance job 3n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-dnv
.. _build logs from FD.io vpp performance job 2n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-dnv
.. _build logs from FD.io vpp performance job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-clx
.. _build logs from FD.io vpp performance job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-icx
.. _build logs from FD.io vpp performance job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-icx
.. _build logs from FD.io vpp performance job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-zn2
.. _build logs from FD.io vpp performance job 3n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-aws
.. _build logs from FD.io vpp performance job 2n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-aws
.. _build logs from FD.io dpdk coverage job 3n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-skx
.. _build logs from FD.io dpdk coverage job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-skx
.. _build logs from FD.io dpdk coverage job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-clx
.. _build logs from FD.io dpdk coverage job 2n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-dnv
.. _build logs from FD.io dpdk coverage job 3n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-dnv
.. _build logs from FD.io dpdk coverage job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-tsh
.. _build logs from FD.io dpdk coverage job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-tx2
.. _build logs from FD.io dpdk coverage job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-zn2
.. _build logs from FD.io trex coverage job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-coverage-{srelease}-2n-skx
.. _build logs from FD.io vpp coverage job 3n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-skx
.. _build logs from FD.io vpp coverage job 2n-skx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-skx
.. _build logs from FD.io vpp coverage job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-tsh
.. _build logs from FD.io vpp coverage job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-tx2
.. _build logs from FD.io vpp coverage job 3n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-dnv
.. _build logs from FD.io vpp coverage job 2n-dnv: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-dnv
.. _build logs from FD.io vpp coverage job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-clx
.. _build logs from FD.io vpp coverage job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-icx
.. _build logs from FD.io vpp coverage job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-icx
.. _build logs from FD.io vpp coverage job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-zn2
.. _build logs from FD.io vpp coverage job 3n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-aws
.. _build logs from FD.io vpp coverage job 2n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-aws
.. _build logs from FD.io vpp device jobs using Ubuntu: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-device-{srelease}-ubuntu2004-1n-skx
.. _FD.io VPP compile job: https://jenkins.fd.io/view/vpp/job/vpp-merge-{srelease}-ubuntu2004-x86_64/
.. _CSIT Testbed Setup: https://git.fd.io/csit/tree/fdio.infra.ansible?h={release}
.. _VPP startup.conf: https://git.fd.io/vpp/tree/src/vpp/conf/startup.conf?h=stable/{srelease}&id={vpp_release_commit_id}
""".format(release=u'rls2202',
           report_week=report_week,
           prev_release=u'rls2110',
           srelease=u'2202',
           csitrelease=u'2202',
           csit_prev_release=u'2110',
           vpprelease=u'22.02',
           vpp_prev_release=u'21.10',
           dpdkrelease=u'21.11',
           dpdk_prev_release=u'21.08',
           sdpdkrelease=u'2111',
           trex_version=u'v2.88',
           vpp_release_commit_id=u'0e0384cde97a71acc0313a0904ed340730a87817')

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = u'en'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This patterns also effect to html_static_path and html_extra_path
exclude_patterns = [u'_build', u'Thumbs.db', u'.DS_Store']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = u'sphinx'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = u'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
html_theme_options = {
    u'canonical_url': u'',
    u'analytics_id': u'',
    u'logo_only': False,
    u'display_version': True,
    u'prev_next_buttons_location': u'bottom',
    u'style_external_links': False,
    # Toc options
    u'collapse_navigation': True,
    u'sticky_navigation': True,
    u'navigation_depth': 3,
    u'includehidden': True,
    u'titles_only': False
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_theme_path = [u'env/lib/python3.8/site-packages/sphinx_rtd_theme']

# html_static_path = ['_build/_static']
html_static_path = [u'_tmp/src/_static']

html_context = {
    u'css_files': [
        # overrides for wide tables in RTD theme
        u'_static/theme_overrides.css'
    ]
}

# If false, no module index is generated.
html_domain_indices = True

# If false, no index is generated.
html_use_index = True

# If true, the index is split into individual pages for each letter.
html_split_index = False

# -- Options for LaTeX output ---------------------------------------------

latex_engine = u'pdflatex'

latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    #
    u'papersize': u'a4paper',

    # The font size ('10pt', '11pt' or '12pt').
    #
    #'pointsize': '10pt',

    # Additional stuff for the LaTeX preamble.
    #
    u'preamble': r'''
     \usepackage{pdfpages}
     \usepackage{svg}
     \usepackage{charter}
     \usepackage[defaultsans]{lato}
     \usepackage{inconsolata}
     \usepackage{csvsimple}
     \usepackage{longtable}
     \usepackage{booktabs}
    ''',

    # Latex figure (float) alignment
    #
    u'figure_align': u'H',

    # Latex font setup
    #
    u'fontpkg': r'''
     \renewcommand{\familydefault}{\sfdefault}
    ''',

    # Latex other setup
    #
    u'extraclassoptions': u'openany',
    u'sphinxsetup': r'''
     TitleColor={RGB}{225,38,40},
     InnerLinkColor={RGB}{62,62,63},
     OuterLinkColor={RGB}{225,38,40},
     shadowsep=0pt,
     shadowsize=0pt,
     shadowrule=0pt
    '''
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, u'csit.tex', u'CSIT REPORT', u'', u'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#
# latex_logo = 'fdio.pdf'

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#
# latex_use_parts = True

# If true, show page references after internal links.
#
latex_show_pagerefs = True

# If true, show URL addresses after external links.
#
latex_show_urls = u'footnote'

# Documents to append as an appendix to all manuals.
#
# latex_appendices = []

# It false, will not define \strong, \code, 	itleref, \crossref ... but only
# \sphinxstrong, ..., \sphinxtitleref, ... To help avoid clash with user added
# packages.
#
# latex_keep_old_macro_names = True

# If false, no module index is generated.
#
# latex_domain_indices = True
