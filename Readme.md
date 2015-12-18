Human Readable Query to Mongo Query (hrq2mongoq)
================================================

NOTE: THIS PROJECT IS STILL WORK IN PROGRESS.

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

### Expressions

#### Basic expression
`expression` <- `field` `vexpr`\
Selects the documents for which the `field` satisfies the value expression `vexpr`.

#### Combining expressions with logical operators

##### `and` operator
`expression` <- `expression` &nbsp; `and` &nbsp; `expression`\
`expression` <- `expression` `&` `expression`\
Selects the documents for which both expressions are satisfied.\
The keyword `and` must be surrounded by whitespace, where as the `&` symbol can be used without surrounding spaces.

##### `or` operator
`expression` <- `expression`  &nbsp; ` or` &nbsp; `expression`\
`expression` <- `expression` `|` `expression`\
Selects the documents for which on of the two expressions is satisfied.\
The keyword `or` must be surrounded by whitespace, where as the `|` symbol can be used without surrounding spaces.

##### `nor` operator
`expression` ->`expression` &nbsp; `nor` &nbsp; `expression`\
Selects the documents for which none of the two expressions are satisfied.\
The keyword `nor` must be surrounded by whitespace and it doesn't have a corresponding symbol.

##### Associativity and precedence
Currently the logical operators all have the same precedence and are right associative. So\
`a` `and` `b` `or` `c` `and` `d` is interpreted as `a` `and` (`b` `or` (`c` `and` `d`))\
This might be counter intuitive, so it is advised to always use parentheses `(` `)`when combining logical operators.\
One could write for example: `(` `a` `and` `b` `)` `or` `(` `c` `and` `d` `)`.

#### Value expressions
A value expression `vexpr` defines a constraint on a field.

##### Equality and inequality operators
The following operators can be used:\
`vexpr` <- &nbsp; `is` &nbsp; `value`\
`vexpr` <- &nbsp; `is not` &nbsp; `value`\
`vexpr` <- &nbsp; `is greater than` &nbsp; `value`\
`vexpr` <- &nbsp; `is less than` &nbsp; `value`\
`vexpr` <- &nbsp; `is equal or greater than` &nbsp; `value`\
`vexpr` <- &nbsp; `is equal or less than` &nbsp; `value`\
`vexpr` <- `=` `value`\
`vexpr` <- `!=` `value`\
`vexpr` <- `<` `value`\
`vexpr` <- `>` `value`\
`vexpr` <- `=<` `value`\
`vexpr` <- `=>` `value`\
As with the logical operators, the 'natural language' keywords must be surrounded by whitespace, where the symbols can be used without surrounding spaces. If it is needed to explain the semantics of these operators any further, you can contact the author to make a personal appointment in Switzerland. During a hike in the Alps he will most happily explain all the ins and outs about them.

##### Range operator
`vexpr` <- &nbsp; `ranges from` &nbsp; `value` &nbsp; `to` &nbsp; `value`\
`vexpr` <- `{}=` `value` `-` `value`\
The range operator constraints the value to be within the specified range (inclusive).

##### String matching
`vexpr` <- &nbsp; `starts with` &nbsp; `string`\
`vexpr` <- &nbsp; `ends with` &nbsp; `string`\
`vexpr` <- &nbsp; `contains` &nbsp; `string`\
`vexpr` <- &nbsp; `matches` &nbsp; `regex_string`\
`vexpr` <- &nbsp; `start=` `string`\
`vexpr` <- &nbsp; `end=` `string`\
`vexpr` <- &nbsp; `text=` `string`\
`vexpr` <- &nbsp; `regex=` `regex_string`\
The `matches` and `regex=` operators constraints the value to match the speficied regular expression (Perl compatible).

##### Exist
`vexpr` <- &nbsp; `exists`\
`vexpr` <- `*`\
States that the field should exist.

##### Does not exist
`vexpr` <- &nbsp; `does not exist`\
`vexpr` <- `^`\
States that the field should not exist.

### Fields
`field` <- `fieldname`\
`field` <- `fieldname` `.` `fieldname` `.` ... ... `.` `fieldname`\
`field` <- `fieldname` &nbsp; `of` &nbsp; `fieldname` &nbsp; `of` &nbsp; ... ... &nbsp; `of` &nbsp; `fieldname`\
`field` <- `string`

`fieldname` may not start with `$` and may not contain any of the following special characters: :`{` `}` `"` `'` `=` `<` `>` `&` `!` `*` `^` `.` `,`\
If any of the fieldnames does contain such a special character or a space, the field can only be expressed as a `string` (which is always surrounded by quotes, see below).

Fields of embedded documents can be specified by using dot notation `.` or the keyword `of`. If the field is given as a `string`only the dot notation can be used.

Please note there is a subtle semantical difference between the dot notation and the `of`keyword:\
`field` `.` `subfield` means the subfield of the field in human language, whereas `subfield` &nbsp; `of` &nbsp; `field` means field.subfield in mongo language. Hoping you still understand my language.

### Values
A `value` can be one of the following four datatypes:\
`value` <- `string`\
`value` <- `number`\
`value` <- `datetime`\
`value` <- `boolean`

#### Strings

A string is a sequence of characters surrounded by single or double 
quotes. Quotes within the string should be escaped.\
`string` <- `"`a string with double quotes`"`\
`string` <- `'`a string with single quotes`'`\
`string` <- `"`a string containing \\"quotes\\"`"`

#### Numbers

A `number` can be a signed integers or a float, for example `-4567` or `42.314`.

#### Date and time
`datetime` <- `yyyy` `-` `MM` `-` `dd`\
`datetime` <- `yyyy` `-` `MM` `-` `dd` &nbsp; `hh` `:` `mm`\
`datetime` <- `yyyy` `-` `MM` `-` `dd` &nbsp; `hh` `:` `mm` `:` `ss `\
Note that all three formats will internally be converted to a JavaScript Date 
object, which is the number of milliseconds from 1 January 1970 00:00:00 UTC.

#### Booleans
A `boolean` can be represented by the keywords `true` and `false`.

Development
-----------
hrq2mongoq is developed by [David de Bos](http://www.debos.eu).
It is still work in progress.