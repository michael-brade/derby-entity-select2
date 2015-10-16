require! {
    './select2/results': Results
    './select2/utils': Utils
}

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
