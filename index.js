/*var _ = {
    map: require('lodash/collection/map'),
    get: require('lodash/object/get'),
    find: require('lodash/collection/find')
}*/

var _ = require('lodash');

module.exports = Select2;

function Select2() {}

Select2.prototype.view = __dirname;
Select2.prototype.name = 'd-select2';

Select2.prototype.init = function(model) {
};


// value - the target property, could be: an object or a primitive type, an array of the objects or primitive types
// If 'obj' attribute exists it means the target propety is a object
// If 'key' attribute exists it means the items is a list of objects
// text - the name of the displayed property
// single - one item could be choosed only
// fixed - don't allow add new items

Select2.prototype.create = function (model, dom) {
    require('select2');

    if (typeof jQuery.fn.select2 === 'undefined') {
        return console.log('select2.js is required to run select2');
    }

    window._ = _

    var self = this;

    // functions to see possible changes
    function text() {
        return self.getAttribute('text');
    }

    function key() {
        return self.getAttribute('key');
    }

    function obj() {
        return self.getAttribute('obj');
    }

    function single() {
        return self.getAttribute('single');
    }

    function fixed() {
        return self.getAttribute('fixed');
    }


    // localization

    // initialization
    self.internalChange = false;
    self.$element = $(self.input);

    self.$element.select2({
        allowClear: true,   // makes only sense with a placeholder? exception in select2 without...
        width: "resolve", //element/style/function()
        //language: self.getAttribute('i18n'),
        //maximumSelectionLength: 2,
        //minimumResultsForSearch: Infinity,    // never show search box
        multiple: !self.single,
        //closeOnSelect: self.single,  // ? maybe?
        tags: !self.getAttribute('fixed')
/*
        data: function () {
            var items = model.get('items');
            items = _.map(items, function (item) {
                return key() ? {
                    id: item[key()],
                    text: _.get(item, text())
                } : {
                    id: item,
                    text: item
                };
            });
            return items || [];
        }
*/
    });



    // update select2 when model changes
    /*model.on("change", "value", function (newVal, oldVal, passed) {
        self.setValue(newVal);
    });*/

    // update model when select2 changes
    self.$element.on("change", function (e) {
        if (self.internalChange)
            return;

        self.internalChange = true;

        try {
            var data = self.$element.val(); // if obj(), then this is an array of ids (value attribute of option tag)
            if (data && data.length > 0) {
                if (key()) {
                    // look object ids up in @items, which is an array of objects
                    data = _.filter(self.getAttribute('items'), function(object) {
                        return _.includes(data, object[key()]);
                    });
                }

                if (single()) {
                    // turn the array into an element
                    data = data[0];
                }
                model.set('value', data);
            } else {
                model.set('value', null);
            }
        }
        finally {
            self.internalChange = false;
        }
    });

};

/*
    value is the key() attr
    TODO write unit tests for each if
*/
Select2.prototype.selected = function (value) {
    var self = this;
    function key() {
        return self.getAttribute('key');
    }

    var selected = this.getAttribute('value');

    // nothing selected yet
    if (selected === undefined)
        return false;

    if (selected.length)
        // TODO: use for ... of for array
        return _.find(selected, function (object) {
            if (key())
                return object[key()] == value;
            else
                return object == value;
        }) != undefined;

    if (key())
        return selected[key()] == value;

    return selected == value;
}

/* If needed, a custom data adapter has to be written instead of the old setValue() stuff!

$.fn.select2.amd.require(
['select2/data/array', 'select2/utils'],
function (ArrayData, Utils) {
  function CustomData ($element, options) {
    CustomData.__super__.constructor.call(this, $element, options);
  }

  Utils.Extend(CustomData, ArrayData);

  // Get the currently selected options. This is called when trying to get the
  // initial selection for Select2, as well as when Select2 needs to determine
  // what options within the results are selected.
  //
  // @param callback A function that should be called when the current selection
  //   has been retrieved. The first parameter to the function should be an array
  //   of data objects.
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

  // Get a set of options that are filtered based on the parameters that have
  // been passed on in.
  //
  // @param params An object containing any number of parameters that the query
  //   could be affected by. Only the core parameters will be documented.
  // @param params.term A user-supplied term. This is typically the value of the
  //   search box, if one exists, but can also be an empty string or null value.
  // @param params.page The specific page that should be loaded. This is typically
  //   provided when working with remote data sets, which rely on pagination to
  //   determine what objects should be displayed.
  // @param callback The function that should be called with the queried results.
  DataAdapter.query = function (params, callback) {
    callback(queryiedData);
  }

  $("#select").select2({
    dataAdapter: CustomData
  });
}
*/

Select2.prototype.setValue = function (value) {
    var self = this;


    if (self.internalChange) return;
    if (value) {
        self.internalChange = true;

        var data;
        if (obj()) {
            if (single()) {
                data = [
                    {id: value[key()], text: value[text()]}
                ];
            } else {
                data = _.map(value, function (item) {
                    return {id: item[key()], text: item[text()]};
                });
            }
        } else {
            if (single()) {
                data = [
                    {id: value, text: value}
                ];
            } else {
                data = _.map(value, function (item) {
                    return {id: item, text: item};
                });
            }
        }

        self.$element.val(data).trigger("change");

        self.internalChange = false;
    }
};
