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
  * Comparison operators: `=`, `>`, `<`, `=>`, `=<`, `either...or`, `both...and` and `ranges`
  * String matching and regexes
  * Dot notation and `$exists`
  * Four datatypes: `strings`, `numbers`, `date and time` and `booleans`


Installation
------------
As easy as npm can be:

    $ npm install hrq2mongoq


Human Readable Query Syntax and Semantics
-----------------------------------------

## Expressions

---

### Basic expression
`expression` <- `field` `vexpr`

Selects the documents for which the `field` satisfies the single value expression `vexpr`.

**Examples**

  * name is "Athena"
  * "hair length" is 40

---

### Multiple value expressions

Instead of providing one value expression, one can provide multiple one with 
on the two following operators. 

---

#### `both...and` operator
`expression` <- `field` `both` `vexpr` `,` ... `,` `vexpr` `and` `vexpr`

`expression` <- `field` `:` `vexpr` `&` ... `&` `vexpr` `&` `vexpr`

Selects the documents for which the `field` satisfies all the listed value 
expressions.

**Examples**

  * name both starts with "A", contains "then" and ends with "a"
  * name:$start="A"&$contains="then"&$end="a"

---

#### `either...or` operator
`expression` <- `field` `either` `vexpr` `,` ... `,` `vexpr` `or` `vexpr`

`expression` <- `field` `:` `vexpr` `|` ... `|` `vexpr` `|` `vexpr`

Selects the documents for which the `field` satisfies at least one of the 
listed value expressions.

**Examples**

  * friends either is "Demeter" or does not exist
  * friends:="Demeter"|^

---

### Combining expressions with logical operators

---

#### `and` operator
`expression` <- `expression` `and` `expression`

`expression` <- `expression` `&` `expression`

Selects the documents for which both expressions are satisfied.

**Examples**

  * friends is "Demeter" and "hair length" is less than 50
  * friends="Demeter"&"hair length"<50

The keyword `and` must be surrounded by whitespace, where as the `&` symbol can be used without surrounding spaces.

---

#### `or` operator
`expression` <- `expression`  ` or` `expression`

`expression` <- `expression` `|` `expression`

Selects the documents for which on of the two expressions is satisfied.

**Examples**

  * friends is "Demeter" or "hair length" is less than 50
  * friends="Demeter"|"hair length"<50

The keyword `or` must be surrounded by whitespace, where as the `|` symbol can be used without surrounding spaces.

---

#### `nor` operator
`expression` ->`expression` `nor` `expression`

Selects the documents for which none of the two expressions are satisfied.

The keyword `nor` must be surrounded by whitespace and it doesn't have a corresponding symbol.

**Examples**

  * friends is "Demeter" nor "hair length" is less than 50
  
---

#### Associativity and precedence
Currently the logical operators all have the same precedence and are right associative. So

`a` `and` `b` `or` `c` `and` `d` is interpreted as `a` `and` (`b` `or` (`c` `and` `d`))

This might be counter intuitive, so it is advised to always use parentheses `(` `)`when combining logical operators.
One could write for example: `(` `a` `and` `b` `)` `or` `(` `c` `and` `d` `)`.

**Examples**

  * (name is "Hera" and friends does not exist) or "hair length" > 90
  * name is "Hera" and (friends does not exist or "hair length" > 90)

---

### Value expressions
A value expression `vexpr` defines a constraint on a field.

---

#### Equality and inequality operators
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

#### Range operator
`vexpr` <- `ranges from` `value` `to` `value`

`vexpr` <- `{}=` `value` `-` `value`

The range operator constraints the value to be within the specified range (inclusive).

**Examples**

  * "hair length" ranges from 70 to 90
  * "hair length"{}=70-90

---

#### String matching
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

  * name both starts with "A", contains "then" and ends with "a"
  * name:$start="A"&$contains="then"&$end="a"
  * name matches "h.*a"
  * name$regex="h.*a"

---

#### Exist
`vexpr` <- `exists`

`vexpr` <- `*`

States that the field should exist.

**Examples**

  * friends exist
  * friends*

---

#### Does not exist
`vexpr` <- `does not exist`

`vexpr` <- `^`

States that the field should not exist.

**Examples**

  * friends does not exist
  * friends^

---

## Fields
`field` <- `fieldname`

`field` <- `fieldname` `.` `fieldname` `.` ... `.` `fieldname`

`field` <- `fieldname` `of` `fieldname` `of` ... `of` `fieldname`

`field` <- `string`

`fieldname` may not contain any of the following special characters: :`$` `{` `}` `"` `'` `=` `<` `>` `&` `!` `*` `^` `.` `,`

If any of the fieldnames does contain such a special character or a space, the field can only be expressed as a `string` (which is always surrounded by quotes, see below).

Fields of embedded documents can be specified by using dot notation `.` or the keyword `of`. If the field is given as a `string` only the dot notation can be used.

Please note there is a subtle semantical difference between the dot notation and the `of` keyword:

`field` `.` `subfield` means the subfield of the field in human language, whereas `subfield` `of` `field` means field.subfield in mongo language. Hoping you still understand my language.

**Examples**

  * birth.date is greater than 1990-01-01
  * date of birth is greater than 1990-01-01
  * "is worth dying for" is true

---

## Values
A `value` can be one of the following four datatypes:

`value` <- `string`

`value` <- `number`

`value` <- `datetime`

`value` <- `boolean`

---

### Strings

A string is a sequence of characters surrounded by double quotes.
Quotes within the string should be escaped.

`string` <- `"`a string with double quotes`"`

`string` <- `"`a string containing \\"quotes\\"`"`

**Examples**

  * place of birth is "in the sea"
  * place of birth is "in my \"brain\""

---

### Numbers

A `number` can be a signed integers or a float, for example `-4567` or `42.314`.

**Examples**
  * "hair length" ranges from -3.14 to 31

---

### Date and time
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

### Booleans
A `boolean` can be represented by the keywords `true` and `false`.

**Examples**

  * "is worth dying for" is true
  * "is worth dying for" is false

---

Development
-----------
hrq2mongoq is developed and maintained by [David de Bos](http://www.debos.eu).