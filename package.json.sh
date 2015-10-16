#!/usr/local/bin/lsc -cj

name: 'derby-entity-select2'
description: 'Select2 4.0 Derby component with improved usability for Derby Entity'
version: '1.1.0'

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
    'jquery': '2.x'
    'jquery-mousewheel': '*'


peerDependencies:
    # derby
    'derby': 'michael-brade/derby'
    'racer-bundle': '0.2.x'

    # derby components
    'derby-entities-lib': '1.1.x'

devDependencies:
    'livescript': '1.x'
    'node-sass': '3.3.x'

    'require-globify': '1.x'

    # possibly, depending on how you set it up
    'browserify-livescript': '0.2.x'

engines:
    node: '4.x'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/derby-entity-select2/issues'

homepage: 'https://github.com/michael-brade/derby-entity-select2#readme'
