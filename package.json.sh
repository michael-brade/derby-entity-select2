#!/usr/local/bin/lsc -cj

name: 'derby-entity-select2'
description: 'Select2 4.0 Derby component with improved usability for Derby Entity'
version: '1.0.2'

author:
    name: 'Michael Brade'
    email: 'brade@kde.org'

keywords:
    'derby'
    'entity'
    'select2'
    'racer'

repository:
    type: 'git'
    url: 'michael-brade/derby-entity-select2'

dependencies:
    # utils
    'lodash': '3.x'

    # the following are commented out because they are not immediate
    # dependencies - the app needs to depend on those

    # derby
    #'derby': 'michael-brade/derby'

    # racer
    #'racer': 'michael-brade/racer'
    #'racer-bundle': 'michael-brade/racer-bundle'


    # derby components
    'derby-entities-lib': '1.1.x'

devDependencies:
    'livescript': '1.x'
    'node-sass': '3.3.x'

    # possibly, depending on how you set it up
    'browserify-livescript': '0.2.x'

engines:
    node: '4.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entity-select2/issues'

homepage: 'https://github.com/michael-brade/derby-entity-select2#readme'
