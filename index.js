var _ = require('lodash')
  , jQuery = require('jquery');



module.exports = Select2;

function Select2() {}

Select2.prototype.view = __dirname;
Select2.prototype.style = __dirname;
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
    $ = jQuery;

    if (typeof jQuery.fn.select2 === 'undefined') {
        return console.log('select2.jquery.js required to run select2');
    }

    var self = this;

    self.key = model.get('key');
    self.text = model.get('text');
    self.obj = model.get('obj');
    self.single = model.get('single');
    self.fixed = model.get('fixed');

    // localization
    var noMatches = self.model.get('noMatches') || self.model.get('lang.select2.noMatches') || "No matches";
    var onlyOneValue = self.model.get('onlyOneValue') || self.model.get('lang.select2.onlyOneValue') || "You cannot select any more choices";

    // initialization
    self.$element = $(self.input);
    var options = {
        formatNoMatches: function (term) {
            return noMatches;
        },
        formatSelectionTooBig: function (maxSize) {
            return onlyOneValue;
        },
        tags: function () {
            var items = model.get('items');
            items = _.map(items, function (item) {
                return self.key ? {id: item[self.key], text: item[self.text]} : {id: item, text: item};
            });
            return items || [];
        }
    };

    if (self.single)
        options.maximumSelectionSize = 1;

    if (self.fixed)
        options.createSearchChoice = function () {
            return null;
        };

    self.$element.select2(options);

    self.internalChange = false;

    // update control
    model.on("change", "value", function (newVal, oldVal, passed) {
        self.setValue(newVal);
    });

    // update model
    self.$element.on("change", function (e) {
        if (self.internalChange) return;
        self.internalChange = true;
        try {
            if (e.added) {
                var items = model.get('items');
                var lowerText = e.added.text.toLowerCase();
                var itemExists = false;

                // ckeck if the item exists in the collection, if not - add it
                if (self.key) {
                    for (var i = 0, cnt = items.length; i < cnt; i++) {
                        var item = items[i];
                        if (item[self.text].toLowerCase() === lowerText) {
                            itemExists = true;
                            break;
                        }
                    }
                } else {
                    for (var j = 0, cnt1 = items.length; j < cnt1; j++) {
                        var item1 = items[j];
                        if (item1.toLowerCase() === lowerText) {
                            itemExists = true;
                            break;
                        }
                    }
                }

                if (!itemExists) {
                    var newItem;
                    if (self.key) {
                        newItem = {};
                        newItem[self.key] = e.added.id;
                        newItem[self.text] = e.added.text;
                    } else {
                        newItem = e.added.text;
                    }
                    model.push('items', newItem);
                }
            }

            // update model
            var data = self.$element.select2('data');
            if (data && data.length > 0) {
                data = _.map(data, function (item) {
                    if (self.key) {
                        var value = {};
                        value[self.key] = item.id;
                        value[self.text] = item.text;
                        return value;
                    }
                    return item.text;
                });
                if (self.single) {
                    data = self.obj ? data[0] : (self.key ? data[0][self.key] : data[0]);
                }
                else {
                    data = self.obj ? data : _.map(data, self.key);
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
        if (self.obj) {
            if (self.single) {
                data = [
                    {id: value[self.key], text: value[self.text]}
                ];
            } else {
                data = _.map(value, function (item) {
                    return {id: item[self.key], text: item[self.text]};
                });
            }
        } else {
            if (self.single) {
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
