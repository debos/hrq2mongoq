Human Readable Query to Mongo Query (hrq2mongoq)
================================================

hrq2mongoq lets you formulate MongoDB queries in a human readable way by
transforming HRQs (human readably queries) into MongoDB queries.

<!-- toc -->

* [Examples of HRQs](#examples-of-hrqs)
* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [Human Readable Query Syntax and Semantics](#human-readable-query-syntax-and-semantics)
  * [Expressions](#expressions)
    * [Basic expression](#basic-expression)
    * [Multiple value expressions](#multiple-value-expressions)
    * [Combining expressions with logical operators](#combining-expressions-with-logical-operators)
    * [Value expressions](#value-expressions)
  * [Sorting and projection](#sorting-and-projection)
  * [Fields](#fields)
  * [Values](#values)
    * [Words](#words)
    * [Quoted strings](#quoted-strings)
    * [Numbers](#numbers)
    * [Date and time](#date-and-time)
    * [Booleans](#booleans)
    * [ObjectIDs](#objectids)
* [Development](#development)

<!-- toc stop -->

Examples of HRQs
----------------
  * city of person is Amsterdam and occupation of person is studying
  * person.city = Amsterdam & person.occupation = studying
  * date of birth descending, surname and firstname

Features
--------

  * Translate human readable queries into MongoDB query, sorting and projection documents
  * Use symbols or words to describe operators  
  * Logical operators: `and`, `or`, `nor` and `not`
  * Comparison operators: `=`, `>`, `<`, `=>`, `=<`, `either...or`, `both...and` and `ranges`
  * String matching and regexes
  * Dot notation and `$exists`
  * Five datatypes: `strings`, `numbers`, `date and time`, `booleans` and `objectIDs`


Installation
------------
As easy as npm can be:

    $ npm install hrq2mongoq

Usage
-----
Example with [mongoose](http://mongoosejs.com/):
```
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/test');
var Person = mongoose.model('Person', yourSchema);

var hrq2mongoq = require('hrq2mongoq');
var hrquery = 'city of person is Amsterdam and occupation of person is studying';
var hrsort = 'date of birth descending, surname and firstname';
var hrproj = 'firstname and surname'

var mongoq = hrq2mongoq.parse(hrquery);
// mongoq = { '$and':
//   [ { 'person.city': 'Amsterdam' },
//     { 'person.occupation': 'studying' } ] }

var mongos = hrq2mongoq.parse(hrsort);
// mongos = { 'birth.date': -1, 'surname': 1, 'firstname': 1}

var mongop = hrq2mongoq.parse(hrproj);
// mongop = { 'firstname': 1, 'surname': 1}

Person.find(mongoq, mongop).sort(mongos);
// firstname and surname of people studying in Amsterdam, sorted in descending order by date of birth and then in ascending order by surname and first name
```

Human Readable Query Syntax and Semantics
-----------------------------------------

### Expressions

---

#### Basic expression
`expression` <- `field` `vexpr`

Selects the documents for which the `field` satisfies the single value expression `vexpr`.

**Examples**

  * name is Athena
  * "hair length" is 40

---

#### Multiple value expressions

Instead of providing one value expression, one can provide multiple one with
on the two following operators.

---

##### `both...and` operator
`expression` <- `field` `both` `vexpr` `,` ... `,` `vexpr` `and` `vexpr`

`expression` <- `field` `:` `vexpr` `&` ... `&` `vexpr` `&` `vexpr`

Selects the documents for which the `field` satisfies all the listed value
expressions.

**Examples**

  * name both starts with A, contains then and ends with a
  * name:$start=A&$contains=then&$end=a

---

##### `either...or` operator
`expression` <- `field` `either` `vexpr` `,` ... `,` `vexpr` `or` `vexpr`

`expression` <- `field` `:` `vexpr` `|` ... `|` `vexpr` `|` `vexpr`

Selects the documents for which the `field` satisfies at least one of the
listed value expressions.

**Examples**

  * friends either is Demeter or does not exist
  * friends:=Demeter|^

---

#### Combining expressions with logical operators

---

##### `and` operator
`expression` <- `expression` `and` `expression`

`expression` <- `expression` `&` `expression`

Selects the documents for which both expressions are satisfied.

**Examples**

  * friends is Demeter and "hair length" is less than 50
  * friends=Demeter&"hair length"<50

The keyword `and` must be surrounded by whitespace, where as the `&` symbol can be used without surrounding spaces.

---

##### `or` operator
`expression` <- `expression`  ` or` `expression`

`expression` <- `expression` `|` `expression`

Selects the documents for which on of the two expressions is satisfied.

**Examples**

  * friends is Demeter or "hair length" is less than 50
  * friends=Demeter|"hair length"<50

The keyword `or` must be surrounded by whitespace, where as the `|` symbol can be used without surrounding spaces.

---

##### `nor` operator
`expression` ->`expression` `nor` `expression`

Selects the documents for which none of the two expressions are satisfied.

The keyword `nor` must be surrounded by whitespace and it doesn't have a corresponding symbol.

**Examples**

  * friends is Demeter nor "hair length" is less than 50

---

##### Associativity and precedence
Currently the logical operators all have the same precedence and are right associative. So

`a` `and` `b` `or` `c` `and` `d` is interpreted as `a` `and` (`b` `or` (`c` `and` `d`))

This might be counter intuitive, so it is advised to always use parentheses `(` `)`when combining logical operators.
One could write for example: `(` `a` `and` `b` `)` `or` `(` `c` `and` `d` `)`.

**Examples**

  * (name is Hera and friends does not exist) or "hair length" > 90
  * name is Hera and (friends does not exist or "hair length" > 90)

---

#### Value expressions
A value expression `vexpr` defines a constraint on a field.

---

##### Equality and inequality operators
The following operators can be used:

`vexpr` <- `is` `value`

`vexpr` <- `is not` `value`

`vexpr` <- `is greater than` `value`

`vexpr` <- `is less than` `value`

`vexpr` <- `is equal or greater than` `value`

`vexpr` <- `is equal or less than` `value`

`vexpr` <- `=` `value`

`vexpr` <- `!=` `value`

`vexpr` <- `<` `value`

`vexpr` <- `>` `value`

`vexpr` <- `=<` `value`

`vexpr` <- `=>` `value`

As with the logical operators, the 'natural language' keywords must be surrounded by whitespace, where the symbols can be used without surrounding spaces. If it is needed to explain the semantics of these operators any further, you can contact the author to make a personal appointment in Switzerland. During a hike in the Alps he will most happily explain all the ins and outs about them.

---

##### Range operator
`vexpr` <- `ranges from` `value` `to` `value`

`vexpr` <- `{}=` `value` `-` `value`

The range operator constraints the value to be within the specified range (inclusive).

**Examples**

  * "hair length" ranges from 70 to 90
  * "hair length"{}=70-90

---

##### String matching
`vexpr` <- `starts with` `string`

`vexpr` <- `ends with` `string`

`vexpr` <- `contains` `string`

`vexpr` <- `matches` `regex_string`

`vexpr` <- `$start=` `string`

`vexpr` <- `$end=` `string`

`vexpr` <- `$contains=` `string`

`vexpr` <- `$regex=` `regex_string`

All string matching is currently case sensitive.

The `matches` and `regex=` operators constraint the value to match the specified regular expression (Perl compatible).

**Examples**

  * name both starts with A, contains then and ends with a
  * name:$start=A&$contains=then&$end=a
  * name matches "h.*a"
  * name$regex="h.*a"

---

##### Exist
`vexpr` <- `exists`

`vexpr` <- `*`

States that the field should exist.

**Examples**

  * friends exist
  * friends*

---

##### Does not exist
`vexpr` <- `does not exist`

`vexpr` <- `^`

States that the field should not exist.

**Examples**

  * friends does not exist
  * friends^

---

### Sorting and projection

`sorting` <- `field` [`descending`], `field` [`descending`], ..., `field` [`descending`]
`sorting` <- `field` [`descending`] `and` `field` [`descending`] `and` ... `and` `field` [`descending`]
`projection` <- `field`, `field`, ..., `field`
`projection` <- `field` `and` `field` `and` ... `and` `field`

Parsing sorting and projection expressions will return a JSON document which can be used with Mongo's cursor.sort(sort) and db.collection.find(query, projection) respectively.

**Examples**

  * date of birth descending, surname and firstname
  * date of birth, surname and firstname

---

### Fields
`field` <- `word`

`field` <- `word` `.` `word` `.` ... `.` `word`

`field` <- `word` `of` `word` `of` ... `of` `word`

`field` <- `quoted string`

Fields of embedded documents can be specified by using dot notation `.` or the keyword `of`. If the field is given as a `quoted_string` only the dot notation can be used.

Please note there is a subtle semantical difference between the dot notation and the `of` keyword:

`field` `.` `subfield` means the subfield of the field in human language, whereas `subfield` `of` `field` means field.subfield in mongo language. Hoping you still understand my language.

**Examples**

  * birth.date is greater than 1990-01-01
  * date of birth is greater than 1990-01-01
  * "is worth dying for" is true

---

### Values
A `value` can be one of the following datatypes:

`value` <- `word`

`value` <- `quoted string`

`value` <- `number`

`value` <- `datetime`

`value` <- `boolean`

`value` <- `objectID`

---

#### Words

A `word`

  * is a sequence of characters without whitespaces
  * may not contain any of the following special characters: `$` `:` `{` `}` `-` `+` `"` `'` `=` `<` `>` `&` `|` `!` `*` `^` `.` `,`
  * may not start with a digit (0-9)


Examples

  * name is whatever
  * name is word_with_underscore

---

#### Quoted strings

A `quoted string is a sequence of characters surrounded by double quotes.
Quotes within the string should be escaped.

`string` <- `"`a string with double quotes`"`

`string` <- `"`a string containing \\"quotes\\"`"`

**Examples**

  * place of birth is "in the sea"
  * place of birth is "in my \"brain\""

---

#### Numbers

A `number` can be a signed integers or a float, for example `-4567` or `42.314`.

**Examples**
  * "hair length" ranges from -3.14 to 31

---

#### Date and time
`datetime` <- `yyyy` `-` `MM` `-` `dd`

`datetime` <- `yyyy` `-` `MM` `-` `dd` `hh` `:` `mm`

`datetime` <- `yyyy` `-` `MM` `-` `dd` `hh` `:` `mm` `:` `ss `

Note that all three formats will internally be converted to a JavaScript Date
object, which is the number of milliseconds from 1 January 1970 00:00:00 UTC.

**Examples**

  * date of birth is 2009-04-05
  * date of birth is 2009-04-05 22:00
  * date of birth is 2009-04-05 22:00:14

---

#### Booleans
A `boolean` can be represented by the keywords `true` and `false`.

**Examples**

  * "is worth dying for" is true
  * "is worth dying for" is false

---

#### ObjectIDs
An `objectID` is represented as `0x` followed by 24 hexadecimal characters.

**Examples**

  * \_id is 0x507f1f77bcf86cd799439011  

---

Development
-----------
hrq2mongoq is developed and maintained by [David de Bos](http://www.debos.eu).

Initial development was sponsored by [dividat GmbH](http://www.dividat.ch) in Schindellegi, Switzerland.
