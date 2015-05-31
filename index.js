var _ = {
    map: require('lodash/collection/map'),
    get: require('lodash/object/get')
}

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
        return console.log('select2.jquery.js required to run select2');
    }

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
    var noMatches = self.model.get('noMatches') || self.model.get('lang.select2.noMatches') || "No matches";
    var onlyOneValue = self.model.get('onlyOneValue') || self.model.get('lang.select2.onlyOneValue') || "You cannot select any more choices";

    // initialization
    self.$element = $(self.input);

    var options = {
        allowClear: true,
        //width: "element/style/resolve/function()",
        //language: self.getAttribute('i18n'),
        multiple: !self.single,
        tags: !self.getAttribute('fixed'),
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
    };

    self.$element.select2(options);

    self.internalChange = false;

    // update control
    model.on("change", "value", function (newVal, oldVal, passed) {
        self.setValue(newVal);
    });

    // update model
    self.$element.on("change", function (e) {
        if (self.internalChange)
            return;

        self.internalChange = true;

        try {
            // update model
            var data = self.$element.select2('data');
            if (data && data.length > 0) {
                data = _.map(data, function (item) {
                    if (key()) {
                        var value = {};
                        value[key()] = item.id;
                        value[text()] = item.text;
                        return value;
                    }
                    return item.text;
                });
                if (single()) {
                    data = obj() ? data[0] : (key() ? data[0][key()] : data[0]);
                }
                else {
                    data = obj() ? data : _.map(data, key());
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

    // set initial value
    var value = model.get('value');
    self.setValue(value);
};

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

        self.$element.select2('data', data);

        self.internalChange = false;
    }
};
