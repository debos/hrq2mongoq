"use strict";

module.exports = ({parse: toMongoQ, bsonReviver: bsonReviver});

function bsonReviver (key, value) {
    var datevalue = value["$date"];
    if (datevalue) return new Date(datevalue);

    var oidvalue = value["$oid"];
    if (oidvalue) {
        var BSON = require("bson").BSONPure;
        return new BSON.ObjectID(oidvalue);
    }

    return value;
}

function toMongoQ(hrq) {
    var hrqparser = require('./hrq-parser');
    var mongoqstring = hrqparser.parse(hrq);
    return JSON.parse(mongoqstring, bsonReviver);
}