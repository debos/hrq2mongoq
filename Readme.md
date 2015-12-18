Human Readable Query to Mongo Query (hrq2mongoq)
================================================

hrq2mongoq lets you formulate MongoDB queries in a human readable way by 
transforming HRQs (human readably queries) into MongoDB queries.

Examples of HRQs
----------------
  * city of person is "Amsterdam" and occupation of person is "studying"
  * person.city="Amsterdam" & person.occupation="studying"
  
Features
--------

  * Translate human readable queries into MongoDB queries
  * Use symbols or words to describe operators  
  * Logical operators: `and`, `or`, `nor` and `not`
  * Comparison operators: `=`, `>`, `<`, `=>`, `=<`, `either...or`, `both..
  .and` and `ranges`
  * String matching and regexes
  * Dot notation and `$exists`
  * Four datatypes: `strings`, `numbers`, `date and time` and `booleans`


Installation
------------
As easy as npm can be:

    $ npm install hrq2mongoq


Human Readable Query Syntax and Semantics
-----------------------------------------

### Fields

A field can be expressed as follows:
  * fieldname
  * "field names with spaces or special characters should be quoted"

Fields of embedded documents can be specified by using dot notation or the 
keyword `of`:
  * doc.field
  * field of doc
  * field of subdoc of doc
  
If either a field or embedded document contains spaces or special characters, 
only dot notation can be used and the entire field expression should be quoted:
  * WRONG: "field with space" of doc
  * CORRECT: "doc.field with space"

### Values

To express values the following datatypes can be used: strings, numbers, date
and time, and booleans.

#### Strings

A string is just a sequence of characters surrounded by single or double 
quotes. Quotes within the string should be escaped.
  * "a string with double quotes"
  * 'a string with single quotes'
  * "a string containing \\"quotes\\""

#### Numbers

hrq2mongoq supports signed integers, e.g. -4567, and floats, e.g. 42.314.

#### Date and time

The following date and time formats can be used:
  * yyyy-MM-dd
  * yyyy-MM-dd hh:mm
  * yyyy-MM-dd hh:mm:ss
Note that all three formats will internally be converted to a JavaScript Date 
object, which is the number of milliseconds from 1 January 1970 00:00:00 UTC.

#### Booleans

The literals `true` and `false` can be used to represent boolean values.