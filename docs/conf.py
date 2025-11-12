# pylint: disable=C0103,C0114,W0622
# This is a automatically created file, some pylint issues are ignored.

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information


import string

author = 'TQ-Systems'

copyright = '''Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany.
All rights reserved.'''

version = release = 'v0.1.0'

documenttype = 'Quickstart Document'
createddate = '12.11.2025'
createdby = 'Krutz, Christoph'
checkeddate = "14.11.2025"
checkedby = "Krummsdorf, Michael"
project = 'App SDK'
customer = 'TQ-Systems GmbH'
documentnr = f"EM400AppSDK-{version}"
filename = f"{documentnr}.pdf"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = []

templates_path = ['_templates']
exclude_patterns = []

# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_context = {
    'css_files': [
        '_static/css/theme.css',        # theme CSS
        '_static/theme_overrides.css',  # custom CSS
        ],
}
html_sidebars = {
    '**': [
        'relations.html',  # needs 'show_related': True theme option to display
        'searchbox.html',
    ]
}

language = 'en'

pygments_style = 'sphinx'
highlight_language = 'none'

todo_include_todos = False

latex_logo = '_static/tq_logo.png'

latex_engine = 'xelatex'

with open('preamble.tex', encoding='utf-8') as f:
    template = string.Template(f.read())

latex_contents = r"""
\copyrightpage
\tocpage
"""

latex_elements = {
    'sphinxsetup': r'''
        verbatimwithframe=false,
        VerbatimColor={RGB}{217,217,217},
        HeaderFamily=\sffamily\bfseries\color{darkgrey}
    ''',
    # The paper size ('letterpaper' or 'a4paper').
    #
    # 'papersize': 'letterpaper',

    # The font size ('10pt', '11pt' or '12pt').
    #
    # 'pointsize': '10pt',

    # Additional stuff for the LaTeX preamble.
    #
    'preamble': template.substitute(title=project,
                                    author=author,
                                    release=release,
                                    filename=filename,
                                    copyright=copyright,
                                    createddate=createddate,
                                    createdby=createdby,
                                    checkeddate = checkeddate,
                                    checkedby = checkedby,
                                    project = project,
                                    customer = customer,
                                    documentnr = documentnr,
                                    documenttype = documenttype,
                                    ),

    'extraclassoptions': 'openany',

    'tableofcontents': latex_contents

    # Latex figure (float) alignment
    #
    # 'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'EM400AppSDK.tex', 'EM400 App SDK',
     'TQ-Systems', 'manual'),
]


# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'EM400AppSDK', 'EM400 App SDK',
     [author], 1)
]


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
    (master_doc, 'EM400AppSDK', 'EM400 App SDK',
     author, 'EM400AppSDK', 'One line description of project.',
     'Miscellaneous'),
]
