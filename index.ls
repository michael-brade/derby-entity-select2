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

        if (typeof jQuery.fn.select2 === 'undefined')
            return console.log 'select2.js is required to run select2'


        # functions to see possible changes
        text = ~> @getAttribute('text')
        key = ~> @getAttribute('key')
        obj = ~> @getAttribute('obj')
        single = ~> @getAttribute('single')
        fixed = ~> @getAttribute('fixed')


        # localization

        # initialization
        @internalChange = false

        @.$element = $(@input)

        @.$element.select2(
            #allowClear: true   # makes only sense with a placeholder!
            width: "resolve"    #element/style/function()
            #language: @getAttribute('i18n')
            #maximumSelectionLength: 2
            #minimumResultsForSearch: Infinity    # never show search box
            multiple: !@getAttribute('single')
            #closeOnSelect: !!@getAttribute('single')  # ? maybe?
            tags: !@getAttribute('fixed')
        )



        # update model when select2 changes
        @.$element.on("change", (e) ~>
            return if @internalChange

            # TODO: not needed anymore
            @internalChange = true

            try
                data = @.$element.val() # if this is an array of value attributes (= ids) of the option tag
                if (data && data.length > 0)
                    if key!
                        # look object ids up in @items, which is an array of objects
                        data = _.filter @getAttribute('items'), (object) ->
                            _.includes data, object[key()]

                    if single!
                        # turn the array into an element
                        data = data[0]

                    model.set('value', data)
                else
                    model.set('value', null)

            finally
                @internalChange = false
        )


    /*
        value is the key() attr
        TODO write unit tests for each if
    */
    selected: (value) ->
        key = ~> @getAttribute('key')

        selected = @getAttribute('value')

        # nothing selected yet
        if (selected === undefined)
            return false;

        if (selected.length)
            # TODO: use for ... of for array
            return _.find(selected, (object) ->
                if (key())
                    return object[key()] == value
                else
                    return object == value
            ) != undefined

        if (key())
            return selected[key()] == value

        return selected == value


/* If needed, a custom data adapter has to be written instead of the old setValue() stuff!

$.fn.select2.amd.require(
['select2/data/array', 'select2/utils'],
function (ArrayData, Utils) {
  function CustomData ($element, options) {
    CustomData.__super__.constructor.call(this, $element, options);
  }

  Utils.Extend(CustomData, ArrayData);

  # Get the currently selected options. This is called when trying to get the
  # initial selection for Select2, as well as when Select2 needs to determine
  # what options within the results are selected.
  #
  # @param callback A function that should be called when the current selection
  #   has been retrieved. The first parameter to the function should be an array
  #   of data objects.
  CustomData.prototype.current = function (callback) {
    var data = [];
    var currentVal = this.$element.val();

    if (!this.$element.prop('multiple')) {
      currentVal = [currentVal];
    }

    for (var v = 0; v < currentVal.length; v++) {
      data.push({
        id: currentVal[v],
        text: currentVal[v]
      });
    }

    callback(data);
  };

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
  DataAdapter.query = function (params, callback) {
    callback(queryiedData);
  }

  $("#select").select2({
    dataAdapter: CustomData
  });
}
*/
