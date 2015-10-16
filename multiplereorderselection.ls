require! {
    './select2/selection/multiple': MultipleSelection
}

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
        filter: '.select2-search'

        # dragging started
        onStart: (evt) ->

        # dragging ended,  evt.oldIndex, evt.newIndex
        onEnd: (evt) ->

        onMove: (evt) ->
            evt.related.className.indexOf('select2-search') === -1

        onUpdate: (evt) ~>
            return if evt.oldIndex == evt.newIndex

            @options.get('model').move(@options.get('value'), evt.oldIndex, evt.newIndex)
    )
