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

        # functions to see possible changes
        text = ~> @getAttribute('text')
        key = ~> @getAttribute('key')
        obj = ~> @getAttribute('obj')
        single = ~> @getAttribute('single')
        fixed = ~> @getAttribute('fixed')




    /*
        return an object of ids
        derby templates use "in" to check if an object has a property
        TODO write unit tests for each if
    */
    selected:
        get: (selection, current) ->
            console.log("get called: ", selection, current)
            key = ~> @getAttribute('key')

            # nothing selected yet
            return false if selection == undefined

            if selection.length
                x = _.find(selection, (object) ->
                    if (key())
                        return object[key()] == current
                    else
                        return object == current
                )
                console.log "x", x
                return x != undefined
            else if key!
                return selection[key()] == current
            else
                return selection == current

        # inputValue: true/false -> the new selection state
        # selection: the previous selection model values of the select2 component -> to be updated
        # id: the id of the option now to be added or removed from selection (depending on inputValue)
        set: (inputValue, selection, id) ->
            alert("not implemented!")
            [selection, id]
