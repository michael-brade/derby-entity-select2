require! {
    './select2/data/base': BaseAdapter
    './select2/results': Results
    './select2/utils': Utils
}


/*
    SelectAdapter: find child elements with :select attribute set
    ArrayAdapter: data from an array, create option elements and work with those
*/


# The EntityData Adapter: get the data from a racer model. Handles selection/deselection, etc.
#
# Options:
#  - model: the racer model
#  - value: model path to current selection
#
#  - attribute: select2 is always used for an attribute of an entity, this contains all the information,
#       like if value has references, which entity type, etc.
!function EntityData ($element, options)
    @$element = $element;
    @options = options;

    @entitiesApi = EntitiesApi.instance!
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
                v = @entitiesApi.item v, @attribute.entity

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
        fn.call @value, @entitiesApi.item data.id, @attribute.entity

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

    for let i in @entitiesApi.items(@attribute.entity)
        matcher = @options.get('matcher')

        item = @_normalizeItem i

        if matcher(params, item)
            data.push item

    callback results: data


# Turn an item into an object of the form
# {
#     id: itemId,
#     text: text to display
#     html: optionally, html form of text
# }
EntityData.prototype._normalizeItem = (item) ->
    return
        id: item?.id
        text: @entitiesApi.renderAsText(item, @attribute.entity)
        html: @entitiesApi.render(item, @attribute.entity)
