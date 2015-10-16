_ = {
    findIndex: require('lodash/array/findIndex')
    sortBy: require('lodash/collection/sortBy')
}

require! {
    'derby-entities-lib/api': EntitiesApi

    './jquery.select2': Select2

    './select2/selection/search': SelectionSearch
    './select2/selection/single': SingleSelection
    './select2/selection/eventRelay': EventRelay
    './select2/selection/placeholder': Placeholder
    './select2/selection/allowClear': AllowClear
    './select2/results': Results
    './select2/utils': Utils

    './entitydata': EntityData
    './multiplereorderselection': MultipleReorderSelection
    './multiselectresults': MultiselectResults
}



export class EntitySelect2

    view: __dirname
    style: __dirname
    name: 'd-select2'


    # called on the server and the client before rendering
    init: (model) !->


    # value - the target property, could be: an object or a primitive type, an array of the objects or primitive types
    # If 'obj' attribute exists it means the target propety is a object
    # If 'key' attribute exists it means the items is a list of objects
    # text - the name of the displayed property
    # single - one item could be choosed only
    # fixed - don't allow add new items

    create: (model, dom) !->

        ## select2 initialization

        attribute = @getAttribute('attr')

        multiple = attribute.multi
        duplicates = multiple && attribute.uniq == false # duplicate selections possible - makes only sense with multiple

        selectionAdapter = SingleSelection
        resultsAdapter = Results

        if (multiple)
            selectionAdapter = MultipleReorderSelection
            selectionAdapter = Utils.Decorate(MultipleReorderSelection, SelectionSearch)
            if duplicates
                resultsAdapter = MultiselectResults
        else
            selectionAdapter = Utils.Decorate(selectionAdapter, Placeholder)
            selectionAdapter = Utils.Decorate(selectionAdapter, AllowClear)

        #selectionAdapter = Utils.Decorate(selectionAdapter, EventRelay)


        $(@input).select2(
            theme: "bootstrap"

            width: "100%" # auto/resolve/element/style/function()
            #language: @getAttribute('i18n')
            #maximumSelectionLength: 2
            #minimumResultsForSearch: Infinity  # never show search box
            multiple: multiple
            duplicates: duplicates
            closeOnSelect: !multiple
            reorder: true               # means selection oder is important and reodering is possible

            placeholder: ''
            tags: !@getAttribute('fixed')

            # EntityData Adapter options
            model: @model
            value: 'value'                      # model path to current selection

            attribute: attribute                # the attribute definition this select2 is used for

            # Results Adapter options
            sorter: (data) ->
                _.sortBy data, 'text'

            templateResult: (result) ->
                if result.html
                    $.parseHTML result.html
                else
                    result.text

            templateSelection: (selection) ->
                if selection.html
                    $.parseHTML selection.html
                else
                    selection.text

            # Adapter definition
            dataAdapter: EntityData             # TODO: write another Adapter for key() or obj() false!?
            selectionAdapter: selectionAdapter
            resultsAdapter: resultsAdapter
        )
