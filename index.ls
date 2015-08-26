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
             'select2/selection/search',  'select2/selection/single', 'select2/selection/multiple', 'select2/selection/eventRelay',
             'select2/selection/placeholder', 'select2/selection/allowClear',
             'select2/utils'],
            (BaseAdapter, Results,
             SelectionSearch, SingleSelection, MultipleSelection, EventRelay, Placeholder, AllowClear,
             Utils) !~>

                # The EntityData Adapter: get the data from a racer model. Handles selection/deselection, etc.
                #
                # Options:
                #  - model: the racer model
                #  - value: model path to current selection

                #  - entities: the entities class instance
                #  - attribute: select2 is always used for an attribute of an entity, this contains all the information,
                #       like if value has references, which entity type, etc.
                !function EntityData ($element, options)
                    @$element = $element;
                    @options = options;

                    @entities = @options.get('entities')
                    @attribute = @options.get('attribute')

                    @value = @options.get('model').at(@options.get('value'))
                    @value.on 'all', !~> @$element.trigger('change')    # TODO: how to also trigger if references change?

                    EntityData.__super__.constructor.call(this);

                Utils.Extend(EntityData, BaseAdapter)


                EntityData.prototype.bind = (container, $container) ->
                    @container = container;

                    container.on 'select',   (params) ~> @select(params.data)
                    container.on 'unselect', (params) ~> @unselect(params.data)


                EntityData.prototype.destroy = ->


                # Get the currently selected options. This is called when trying to get the
                # initial selection for Select2, as well as when Select2 needs to determine
                # what options within the results (the dropdown) are selected.
                #
                # @param callback A function that should be called when the current selection
                #   has been retrieved. The first parameter to the function should be an array
                #   of data objects.
                EntityData.prototype.current = (callback) ->
                    data = []
                    currentVal = @value.get!

                    if currentVal
                        if !@options.get('multiple')
                            currentVal = [currentVal]   # we always want an array, even if it is only one item

                        for let v, pos in currentVal
                            if @attribute.reference
                                v = @entities.getItem v, @attribute.entity

                            item = @_normalizeItem v

                            # If duplicates can be selected, we need the position to be able to unselect the correct
                            # item again. This is possible because unselect() gets its data from current() (this method),
                            # select gets its data from query() with the true id.
                            #
                            # In all other cases, the results adapter needs the real id to display the selection
                            # in the dropdown (Results.prototype.setClasses)
                            if @options.get('duplicates')
                                item.id = pos

                            data.push item

                    callback(data)


                # add an item to the selection
                #    data is the _normalize'd object with id and text
                EntityData.prototype.select = (data) ->
                    if @options.get('multiple')
                        fn = @value.push
                    else
                        fn = @value.set

                    if @attribute.reference
                        fn.call @value, data.id
                    else
                        fn.call @value, @entities.getItem data.id, @attribute.entity

                    @$element.val(@value.get!)
                    @$element.trigger('change')


                # remove an item from the selection
                #    item is the _normalize'd object with id and text
                EntityData.prototype.unselect = (item) ->
                    if @options.get('duplicates')
                        @value.remove item.id
                    else if @options.get('multiple')
                        @value.remove _.findIndex @value.get!, (id) -> id == item.id
                    else
                        @value.del!

                    @$element.val(@value.get!)
                    @$element.trigger('change')


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
                EntityData.prototype.query = (params, callback) ->
                    data = []

                    for let i in @entities.getItems(@attribute.entity)
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
                EntityData.prototype._normalizeItem = (item) ->
                    return
                        id: item?.id
                        text: @entities.getItemAttr(item, 'name', @attribute.entity, @options.get 'locale')


                /**
                 *  MultiselectResults: allow clicking and choosing an already selected item again
                 */
                !function MultiselectResults ($element, options, dataAdapter)
                    MultiselectResults.__super__.constructor.call(this, $element, options, dataAdapter);

                Utils.Extend(MultiselectResults, Results)


                MultiselectResults.prototype.render = ->
                    @$results = $('<ul class="select2-results__options" role="tree"></ul>')
                    return @$results

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
                            @trigger 'toggle',
                                originalEvent: evt


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

                multiple = @getAttribute('multi')
                duplicates = multiple && @getAttribute('uniq') == false # duplicate selections possible - makes only sense with multiple

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


                @.$element.select2(
                    width: "100%" # auto/resolve/element/style/function()
                    #language: @getAttribute('i18n')
                    #maximumSelectionLength: 2
                    #minimumResultsForSearch: Infinity    # never show search box
                    multiple: multiple
                    duplicates: duplicates
                    closeOnSelect: !multiple
                    reorder: true               # means selection oder is important and reodering is possible

                    placeholder: ''
                    tags: !@getAttribute('fixed')

                    # EntityData Adapter options
                    model: @model
                    value: 'value'                          # model path to current selection

                    entities: @getAttribute('entities')     # the Entities instance
                    attribute: @getAttribute('attribute')   # the attribute definition this select2 is used for
                    locale: @getAttribute('locale')

                    # Results Adapter options
                    sorter: (data) ->
                        _.sortBy(data, 'text')

                    # Adapter definition
                    dataAdapter: EntityData                 # TODO: write another Adapter for key() or obj() false!?
                    selectionAdapter: selectionAdapter
                    resultsAdapter: resultsAdapter
                )

        )
