var _ = require('lodash')
  , jQuery = require('jquery');



module.exports = Select2;

function Select2() {}

Select2.prototype.view = __dirname;
Select2.prototype.style = __dirname;
Select2.prototype.name = 'd-select2';

Select2.prototype.init = function(model) {
};

Select2.prototype.create = function(model, dom) {

    require('select2');

    if (typeof jQuery.fn.select2 === 'undefined') {
        return console.log('select2.jquery.js required to run select2');
    }

    var self = this
      , defaults = model.get('defaults') || {}
      , optfns = [
            'changefn'
          , 'containercssfn'
          , 'containercssclassfn'
          , 'createsearchchoicefn'
          , 'dropdowncssfn'
          , 'dropdowncssclassfn'
          , 'escapemarkupfn'
          , 'formatinputtooshortfn'
          , 'formatnomatchesfn'
          , 'formatresultfn'
          , 'formatresultcssfn'
          , 'formatresultcssclassfn'
          , 'formatsearchingfn'
          , 'formatselectionfn'
          , 'formatselectiontoobigfn'
          , 'idfn'
          , 'initselectionfn'
          , 'matcherfn'
          , 'maximumselectionsizefn'
          , 'queryfn'
          , 'sortresultsfn'
          , 'tokenizerfn'
        ]
      , opts = [
            'ajax'
          , 'allowclear'
          , 'close'
          , 'closeonselect'
          , 'container'
          , 'containercss'
          , 'containercssclass'
          , 'data'
          , 'dataval'
          , 'destroy'
          , 'disable'
          , 'dropdowncss'
          , 'dropdowncssclass'
          , 'enable'
          , 'inputtype'
          , 'loadmorepadding'
          , 'maximuminputlength'
          , 'maximumselectionsize'
          , 'minimuminputlength'
          , 'minimumresultsforsearch'
          , 'multiple'
          , 'onsortend'
          , 'onsortstart'
          , 'open'
          , 'openonenter'
          , 'openonselect'
          , 'placeholder'
          , 'selectonblur'
          , 'separator'
          , 'tags'
          , 'tokenseparators'
          , 'width'
          , 'val'
        ].concat(optfns);

    function unrecognized(param) {
        if (!_.contains(opts)) {
            console.log('unrecognized parameter "' + key + '"');
        }
    }

    function isBlank(str) {
        //    return (!str || /^\s*$/.test(str)); //  !/\S/.test(str)
        return (!str || !str.trim());
    }

    _.keys(model.get(), unrecognized);
    _.keys(defaults, unrecognized);

    // convert option values to scoped models
    opts = _.object(opts, _.map(opts, function(opt) {
        return model.at(opt);
    }));

    // set option defaults
    _.each(_.keys(defaults), function(key) {
        var val = defaults[key];
        if (typeof val === 'undefined') return;
        if (!opts[key]) return;
        if (typeof opts[key].get() !== 'undefined') return;
        if (_.isFunction(val)) return (opts[key] = val);
        opts[key].set(val);
    });

    // resolve function option names to their actual functions
    _.each(optfns, function(optfn) {
        if (_.isFunction(opts[optfn])) return;

        var name = opts[optfn].get();
        var nofn = function() { return ''; };

        opts[optfn] = undefined;
        if (typeof name === 'undefined') return;
        if (isBlank(name)) return (opts[optfn] = nofn);
        // TODO    if (DERBY.app[name]) return (opts[optfn] = DERBY.app[name]);
        console.log('cannot find function "' + name + '"');
    });

    // infer input type if it is not specified
    if (typeof opts.inputtype.get() === 'undefined') {
        var requireHidden =
            opts.ajax.get() ||
            opts.data.get() ||
            opts.queryfn;
        opts.inputtype.set(requireHidden ? 'hidden' : 'select');
    }

    // infer if select allows multiple values
    if (typeof opts.multiple.get() === 'undefined') {
        if (opts.closeonselect.get()) opts.multiple.set(true);
    }

    var isHidden = opts.inputtype.get() === 'hidden'
      , el = isHidden ? this.input : this.select;

    // parameters to pass to $.fn.select2
    var params = {
          ajax: opts.ajax.get()
        , allowClear: opts.allowclear.get()
        , containerCss: opts.containercssfn || opts.containercss.get()
        , containerCssClass: opts.containercssclassfn || opts.containercssclass.get()
        , createSearchChoice: opts.createsearchchoicefn
        , data: opts.data.get()
        , dropdownCss: opts.dropdowncssfn || opts.dropdowncss.get()
        , dropdownCssClass: opts.dropdowncssclassfn || opts.dropdowncssclass.get()
        , escapeMarkup: opts.escapemarkupfn
        , formatInputTooShort: opts.formatinputtooshortfn
        , formatNoMatches: opts.formatnomatchesfn
        , formatResult: opts.formatresultfn
        , formatResultCss: opts.formatresultcssfn
        , formatResultCssClass: opts.formatresultcssclassfn
        , formatSearching: opts.formatsearchingfn
        , formatSelection: opts.formatselectionfn
        , formatSelectionTooBig: opts.formatselectiontoobigfn
        , id: opts.idfn
        , initSelection: opts.initselectionfn
        , maximumInputLength: opts.maximuminputlength.get()
        , maximumSelectionSize: opts.maximumselectionsizefn || opts.maximumselectionsize.get()
        , minimumInputLength: opts.minimuminputlength.get()
        , minimumResultsForSearch: opts.minimumresultsforsearch.get()
        , matcher: opts.matcherfn
        , multiple: isHidden ? opts.multiple.get() : undefined
        , openOnEnter: opts.openonenter.get()
        , openOnSelect: opts.openonselect.get()
        , placeholder: opts.placeholder.get()
        , query: opts.queryfn
        , separator: opts.separator.get()
        , selectOnBlur: opts.selectonblur.get()
        , sortResults: opts.sortresultsfn
        , tags: opts.tags.get()
        , tokenizer: opts.tokenizerfn
        , tokenSeparators: opts.tokenseparators.get()
        , width: opts.width.get()
    };

    jQuery(function () {
        var datavalSet = valSet = false;
console.log("PARAMS:", params);

        el = jQuery(el).select2(params);
        opts.container.set(el.select2('container'));

        // allow binding to the change event
        el.on('change', function (e) {
            datavalSet = valSet = true;
            opts.val.set(el.select2('val'));
            opts.dataval.set(el.select2('data'));
            self.emit('change', e);
        });

        // allow binding to the open event
        el.on('open', function () {
            self.emit('open');
        });

        function setDataval(val) {
            // ensure we aren't responding to a set event we just triggered
            if (datavalSet) return (datavalSet = false);
            el.select2('data', val);
            datavalSet = valSet = true;
            opts.dataval.set(el.select2('data'));
            opts.val.set(el.select2('val'));
        }

        function setVal(val) {
            // ensure we aren't responding to a set event we just triggered
            if (valSet) return (valSet = false);
            el.select2('val', val);
            datavalSet = valSet = true;
            opts.dataval.set(el.select2('data'));
            opts.val.set(el.select2('val'));
        }

        if (opts.dataval.get())
            setDataval(opts.dataval.get());
        else if (opts.val.get())
            setVal(opts.val.get());

        opts.dataval.on('set', setDataval);
        opts.val.on('set', setVal);

        opts.close.on('set', function (close) {
            el.select2(close ? 'close' : 'open');
        });

        opts.destroy.on('set', function (destroy) {
            if (destroy) el.select2('destroy');
        });

        opts.disable.on('set', function (disable) {
            el.select2(disable ? 'disable' : 'enable');
        });

        opts.enable.on('set', function (enable) {
            el.select2(enable ? 'enable' : 'disable');
        });

        opts.onsortstart.on('set', function (onSortStart) {
            if (onSortEnd) el.select2('onSortEnd');
        });

        opts.onsortstart.on('set', function (onsortstart) {
            if (onSortStart) el.select2('onSortStart');
        });

        opts.open.on('set', function (open) {
            el.select2(open ? 'open' : 'close');
        });
    });

};
