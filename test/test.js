var expect    = require("chai").expect;
var hrq2mongoq = require("../lib");
var happyflowsuites = require("./happyflow");

var runTest = function (test, useDB) {
    it(test.test, function (done) {
        var mongoq = hrq2mongoq.parse(test.hrq);
        expect(mongoq).to.eql(JSON.parse(JSON.stringify(test.mongoq), hrq2mongoq.dateReviver));

        if (useDB) {
            var MongoClient = require('mongodb').MongoClient;
            MongoClient.connect('mongodb://localhost:27017/test', function (err, db) {
                if (err) done(err);
                db.collection('hrqTestData').aggregate(
                    [
                        {$match: mongoq},
                        {$sort: {name: 1} },
                        {$group: {"_id": null, "result": {$push: "$name"}}}
                    ], function (err, result) {
                        if (err) done(err);
                        expect(result[0].result).to.eql(test.result);
                        db.close();
                        done();
                    });
            });
        } else {
            done();
        }
    })
};

var runTests = function(useDB) {
    happyflowsuites.forEach(function(suite) {
        runSuite(suite, useDB);
    });
};

var runSuite = function(suite, useDB) {
    describe(suite.suite, function() {
        suite.tests.forEach(function (test) {
            runTest(test, useDB);
        });
    });
};

describe("hr2mongoq (with DB verification)", function() {runTests(true)});
describe("hr2mongoq (without DB verification)", function() {runTests(false)});