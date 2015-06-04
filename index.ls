/*var _ = {
    map: require('lodash/collection/map'),
    get: require('lodash/object/get'),
    find: require('lodash/collection/find')
}*/
_ = require 'lodash'  # use prelude.ls ?


export class Select2

    view: __dirname
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

        require 'select2'

        if (typeof jQuery.fn.select2 == 'undefined')
            return console.log 'select2.js is required to run select2'

        @.$element = $(@input)


        /*  SelectAdapter: find child elements with :select attribute set
            ArrayAdapter: data from an array, create option elements and work with those
        */
        $.fn.select2.amd.require(['select2/data/base', 'select2/results', 'select2/selection/multiple', 'select2/utils'],
            (BaseAdapter, Results, MultipleSelection, Utils) !~>
                !function ModelData ($element, options)
                    @$element = $element;
                    @options = options;
                    @model = @options.get('model')
                    @model.on 'all', @options.get('value'), !~> @$element.trigger('change') # TODO model.at shortcut possible

                    ModelData.__super__.constructor.call(this);

                Utils.Extend(ModelData, BaseAdapter)


                ModelData.prototype.bind = (container, $container) ->
                    @container = container;

                    container.on 'select',   (params) ~> @select(params.data)
                    container.on 'unselect', (params) ~> @unselect(params.data)


                ModelData.prototype.destroy = ->


                # Get the currently selected options. This is called when trying to get the
                # initial selection for Select2, as well as when Select2 needs to determine
                # what options within the results are selected.
                #
                # @param callback A function that should be called when the current selection
                #   has been retrieved. The first parameter to the function should be an array
                #   of data objects.
                ModelData.prototype.current = (callback) ->
                    data = []
                    # TODO: could use model.at() as a shortcut, maybe even in options already
                    currentVal = @model.get(@options.get('value'))

                    #if !@$element.prop('multiple')  # TODO: use @options?
                    #    currentVal = [currentVal]

                    if currentVal
                        for let v, pos in currentVal
                            # id is the position to be able to deselect the correct one again
                            # unselect gets this data (from current()), select gets the data from query() with the true id
                            data.push(
                                id: pos
                                text: v[@options.get('text')!]
                            )

                    callback(data)

                # add and remove an item to or from selections
                #    data is the object with id and text
                ModelData.prototype.select = (data) ->
                    if @$element.prop('multiple')
                        # TODO: make it a function: id -> object
                        @model.push(@options.get('value'), _.find @options.get('data')!, (item) ~>
                            item[@options.get('key')!] == data.id
                        )

                        #@$element.val(val)

                    else
                        @model.set(@options.get('value'), _.find @options.get('data')!, (item) ~>
                            item[@options.get('key')!] == data.id
                        )

                        #@$element.val data.id


                ModelData.prototype.unselect = (data) ->
                    return if !@$element.prop('multiple')

                    @model.remove @options.get('value'), data.id


                # Get a set of options that are filtered based on the parameters that have
                # been passed on in.
                #
                # @param params An object containing any number of parameters that the query
                #   could be affected by. Only the core parameters will be documented.
                # @param params.term A user-supplied term. This is typically the value of the
                #   search box, if one exists, but can also be an empty string or null value.
                # @param params.page The specific page that should be loaded. This is typically
                #   provided when working with remote data sets, which rely on pagination to
                #   determine what objects should be displayed.
                # @param callback The function that should be called with the queried results.
                ModelData.prototype.query = (params, callback) ->
                    data = []
                    currentVal = @options.get('data')!

                    for let v in currentVal
                        matcher = @options.get('matcher')

                        # TODO: re-use function _normalizeItem
                        item =
                            id: v[@options.get('key')!]
                            text: v[@options.get('text')!]

                        if matcher(params, item)
                            data.push item

                    callback results: data


                /**
                 *  MultiselectResults: allow clicking and choosing an already selected item again
                 */
                !function MultiselectResults ($element, options, dataAdapter)
                    MultiselectResults.__super__.constructor.call(this, $element, options, dataAdapter);

                Utils.Extend(MultiselectResults, Results)


                MultiselectResults.prototype.render = ->
                    @$results = $('<ul class="select2-results__options" role="tree"></ul>')
                    return @$results;

                MultiselectResults.prototype.setClasses = ->
                    # don't set any selected classes to be able to re-select items


                /**
                 *  MultipleReorderSelection: allow reodering a selection via drag&drop
                 */
                !function MultipleReorderSelection ($element, options)
                    require 'jquery.sortable'

                    MultipleReorderSelection.__super__.constructor.call(this, $element, options);

                Utils.Extend(MultipleReorderSelection, MultipleSelection)


                MultipleReorderSelection.prototype.update = (data) ->
                    MultipleReorderSelection.__super__.update.apply(this, arguments);
                    $selection = @$selection.find('.select2-selection__rendered');
                    $selection.sortable(
                        animation: 200
                    )




                @.$element.select2(
                    #allowClear: true   # makes only sense with a placeholder!
                    width: "auto" #"resolve"    #element/style/function()
                    #language: @getAttribute('i18n')
                    #maximumSelectionLength: 2
                    #minimumResultsForSearch: Infinity    # never show search box
                    multiple: !@getAttribute('single')
                    #closeOnSelect: !!@getAttribute('single')  # ? maybe?
                    tags: !@getAttribute('fixed')

                    model: @model
                    value: 'value' # model path to current selection

                    order: true         # means selection oder is important and reodering is possible
                    duplicates: true    # duplicate selections possible

                    data: ~> @getAttribute('items')  # function that returns the data (all items)

                    key: ~> @getAttribute('key')
                    text: ~> @getAttribute('text')
                    obj: ~> @getAttribute('obj')

                    dataAdapter: ModelData  # TODO: write another Adapter for key() or obj() false!?
                    selectionAdapter: MultipleReorderSelection
                    resultsAdapter: MultiselectResults
                )

        )


    # get value from select2
    getValue: ->
        console.log("getValue", @internalChange)

        # functions to see possible changes
        text = ~> @getAttribute('text')
        key = ~> @getAttribute('key')
        obj = ~> @getAttribute('obj')
        single = ~> @getAttribute('single')
        fixed = ~> @getAttribute('fixed')

        data = @.$element.val() # this is an array of value attributes (= ids) of the option tag
        if (data && data.length > 0)
            if key!
                # look object ids up in @items, which is an array of objects
                data = _.filter @getAttribute('items'), (object) ->
                    _.includes data, object[key!]

            if single!
                # turn the array into an element
                data = data[0]

            return data
        else
            return null



    # set select2 to given value (either string, object, or array)
    setValue: (value) ->
        console.log("setValue", @internalChange)
        return if @internalChange

        # functions to see possible changes
        text = ~> @getAttribute('text')
        key = ~> @getAttribute('key')
        obj = ~> @getAttribute('obj')
        single = ~> @getAttribute('single')
        fixed = ~> @getAttribute('fixed')

        if obj!
            if single!
                # turn the element into an array
                data = [
                    id: value[key!]
                    text: value[text!]
                ]
            else
                data = _.map(value, (item) ->
                    id: item[key!]
                    text: item[text!]
                )
        else if single!
            data = [
                id: value
                text: value
            ]
        else
            data = _.map(value, (item) ->
                    id: item
                    text: item
            )


        @internalChange = true

        @.$element.val(data)

        @internalChange = false
