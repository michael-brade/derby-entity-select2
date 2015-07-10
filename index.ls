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
        $.fn.select2.amd.require(
            ['select2/data/base',
             'select2/results',
             'select2/selection/search', 'select2/selection/multiple', 'select2/selection/eventRelay',
             'select2/utils'],
            (BaseAdapter, Results,
             SelectionSearch, MultipleSelection, EventRelay,
             Utils) !~>

                # The ModelData Adapter: get the data from a racer model. Handles selection/deselection,
                #
                # Options:
                #  - model: the racer model
                #  - value: model path to current selection
                #  - ref: true if value contains only ids (references to other items instead of items itself)
                #  - data: function that returns the data (all possible items available for selection)
                #
                #  - key: function that returns the item path to the item id
                #  - text: function that returns the item path to the display text
                !function ModelData ($element, options)
                    @$element = $element;
                    @options = options;
                    @value = @options.get('model').at(@options.get('value'))
                    @value.on 'all', !~> @$element.trigger('change')

                    ModelData.__super__.constructor.call(this);

                Utils.Extend(ModelData, BaseAdapter)


                ModelData.prototype.bind = (container, $container) ->
                    @container = container;

                    container.on 'select',   (params) ~> @select(params.data)
                    container.on 'unselect', (params) ~> @unselect(params.data)


                ModelData.prototype.destroy = ->


                # Get the currently selected options. This is called when trying to get the
                # initial selection for Select2, as well as when Select2 needs to determine
                # what options within the results (the dropdown) are selected.
                #
                # @param callback A function that should be called when the current selection
                #   has been retrieved. The first parameter to the function should be an array
                #   of data objects.
                ModelData.prototype.current = (callback) ->
                    data = []
                    currentVal = @value.get!

                    if currentVal
                        if !@$element.prop('multiple')  # TODO: use @options?
                            currentVal = [currentVal]   # we always want an array, even if it is only one item

                        for let v, pos in currentVal
                            item = @_normalizeItem v
                            # id is the position to be able to deselect the correct one again
                            # unselect gets this data (from current()), select gets the data from query() with the true id
                            item.id = pos
                            data.push item

                    callback(data)

                # add an item to the selection
                #    data is the _normalize'd object with id and text
                ModelData.prototype.select = (data) ->
                    if @$element.prop('multiple')
                        fn = @value.push
                    else
                        fn = @value.set

                    if @options.get('ref')
                        fn.call @value, data.id
                    else
                        fn.call @value, @_getItem data.id


                # get the object with key == itemId
                ModelData.prototype._getItem = (itemId) ->
                    _.find @options.get('data')!, (item) ~>
                        _.get(item, @options.get('key')!) == itemId


                # remove an item from the selection
                #    data is the _normalize'd object with id and text
                ModelData.prototype.unselect = (data) ->
                    return if not @$element.prop('multiple')

                    @value.remove data.id


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

                    for let i in @options.get('data')!
                        matcher = @options.get('matcher')

                        item = @_normalizeItem i

                        if matcher(params, item)
                            data.push item

                    callback results: data


                # Turn an item into an object of the form
                # {
                #     id: itemId,
                #     text: textToDisplay
                # }
                ModelData.prototype._normalizeItem = (item) ->
                    # console.log 'normalize: ', typeof item, item

                    # select2 is always used for an attribute of an entity. That attribute can be set to "reference == true",
                    # which means that only item ids will be stored. But data will still contain the objects with those ids.

                    if typeof item == 'string'  # TODO: or: if entity.attribute.<this>.reference == true
                        # item is in fact the itemId
                        item = @_getItem item

                    id = _.get item, @options.get('key')!

                    # TODO: this will be needed when using references, it should contain all entity items of the referenced type
                    #if @options.get('entityOfText')!
                    #    items = @options.get('entityOfText')!   # rename to textEntityItems

                    # TODO: item.name should be encoded in attribute
                    text = if typeof! item.name == 'Array' then
                        # TODO: if we are using references, v is an array of ids, and this will have to use a map of ids to the entities items
                        _.reduce item.name, (result, subitem) ~>
                            result += " " if result
                            result += _.get subitem, @options.get('text')!
                        , ""
                    else
                        _.get item, @options.get('text')!

                    return
                        id: id
                        text: text


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

                # override bind and prevent a click on "remove (x)" to open the dropdown
                MultipleReorderSelection.prototype.bind = (container, $container) !->
                    MultipleReorderSelection.__super__.bind.apply(this, arguments);

                    @$selection.off 'click'

                    @$selection.on 'click', (evt) !~>
                        $selection = $(evt.target).parent!
                        data = $selection.data('data')

                        if $(evt.target).hasClass('select2-selection__choice__remove')
                            @trigger 'unselect',
                                originalEvent: evt,
                                data: data
                        else
                            @trigger 'toggle', originalEvent: evt


                MultipleReorderSelection.prototype.update = (data) ->
                    MultipleReorderSelection.__super__.update.apply(this, arguments);
                    $selection = @$selection.find('.select2-selection__rendered');
                    $selection.sortable(
                        animation: 200

                        # dragging started
                        onStart: (evt) ->

                        # dragging ended,  evt.oldIndex, evt.newIndex
                        onEnd: (evt) ->

                        onUpdate: (evt) ~>
                            return if evt.oldIndex == evt.newIndex

                            @options.get('model').move(@options.get('value'), evt.oldIndex, evt.newIndex)
                    )


                ## select2 initialization

                multiple =  !@getAttribute('single')

                if (multiple)
                    selectionAdapter = Utils.Decorate(MultipleReorderSelection, SelectionSearch)
                    selectionAdapter = Utils.Decorate(selectionAdapter, EventRelay)

                @.$element.select2(
                    #allowClear: true   # makes only sense with a placeholder!
                    width: "100%" # auto/resolve/element/style/function()
                    #language: @getAttribute('i18n')
                    #maximumSelectionLength: 2
                    #minimumResultsForSearch: Infinity    # never show search box
                    multiple: multiple
                    #closeOnSelect: !!@getAttribute('single')  # ? maybe?
                    tags: !@getAttribute('fixed')

                    order: true         # means selection oder is important and reodering is possible
                    duplicates: true    # duplicate selections possible
                    closeOnSelect: false

                    # Model Data Adapter options
                    model: @model
                    value: 'value' # model path to current selection

                    data: ~> @getAttribute('items')  # function that returns the data (all items)

                    key: ~> @getAttribute('key')
                    text: ~> @getAttribute('text')
                    obj: ~> @getAttribute('obj')
                    ref: ~> @getAttribute('ref')

                    entityOfText: ~> @getAttribute('entityOfText')


                    dataAdapter: ModelData  # TODO: write another Adapter for key() or obj() false!?
                    selectionAdapter: selectionAdapter
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
                    id: _.get value, key!
                    text: _.get value, text!
                ]
            else
                data = _.map(value, (item) ->
                    id: _.get item, key!
                    text: _.get item, text!
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
