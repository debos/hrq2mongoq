"use strict";

module.exports = ({parse: toMongoQ, dateReviver: dateReviver});

function dateReviver (key, value) {
    var datevalue = value["$date"];
    if (datevalue) return new Date(datevalue);
    return value;
}

function toMongoQ(hrq) {
    var hrqparser = require('./hrq-parser');
    var mongoqstring = hrqparser.parse(hrq);
    return JSON.parse(mongoqstring, dateReviver);
}