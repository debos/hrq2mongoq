/**
 This is the PEG.js grammar file used for generating a parser to transform a HumanReadablyQuery (HRQ) into a
  MongoQuery (MongoQ) string
 **/

result = _ expr:expression _ {return expr;}

expression 'expression'
= head:condition and tail:expression { return '{"$and": [' + head + ', ' + tail + ']}';}
/ head:condition or tail:expression { return '{"$or": [' + head + ', ' + tail + ']}';}
/ head:condition nor tail:expression { return '{"$nor": [' + head + ', ' + tail + ']}';}
/ head:condition {return head;}

and 'and' = __ 'and' __ / _ '&' _
or 'or' = __ 'or' __ / _ '|' _
nor 'nor' = __ 'nor' __
either = __ 'either' / _ ':'
both = __ 'both' / _ ':'

condition
= '(' _ expression:expression _ ')' {return expression;}
/ left:fieldid both right:andlist {var result = '{"$and": ['; right.split(';').forEach(function(item){result += '{' + left + ': ' + item + '},';});  return result.substr(0,result.length-1) + ']}';}
/ left:fieldid either right:orlist {var result = '{"$or": ['; right.split(';').forEach(function(item){result += '{' + left + ': ' + item + '},';});  return result.substr(0,result.length-1) + ']}';}
/ left:fieldid right:valueexpr {return '{' + left + ': ' + right + '}';}

valueexpr
= not value:value {return '{"$ne": ' + value + '}';}
/ is value:value {return value;}
/ lt value:value {return '{"$lt": ' + value + '}';}
/ gt value:value {return '{"$gt": ' + value + '}';}
/ lte value:value {return '{"$lte": ' + value + '}';}
/ gte value:value {return '{"$gte": ' + value + '}';}
/ from from:value to to:value {return '{"$gte": ' + from + ', "$lte": ' + to + '}';}
/ exists {return '{"$exists": true}';}
/ notexists {return '{"$exists": false}';}
/ startswith string:string {return '{"$regex" : "^' + string.substring(1,string.length-1) + '"}';}
/ endswith string:string {return '{"$regex" : "' + string.substring(1,string.length-1) + '$"}';}
/ contains string:string {return '{"$regex" : "' + string.substring(1,string.length-1) + '"}';}
/ matches string:string {return '{"$regex" : "' + string.substring(1,string.length-1) + '"}';}

is  = __ 'is' __ / _ '=' _
not = __ 'is not' __ / _ '!=' _
lt  = __ 'is less than' __ / _ '<' _
gt  = __ 'is greater than' __ / _ '>' _
lte  = __ 'is equal or less than' __ / _ '=<' _ / _ '<=' _
gte  = __ 'is equal or greater than' __ / _ '>=' _ / _ '=>' _
from = __ 'ranges from' __ / _ '{}=' _
to = __ 'to' __ / _ '-' _
exists  = __ 'exists' / _ '*'
notexists  = __ 'does not exist' / _ '^'
startswith  = __ 'starts with' __ / _ '$start=' _
endswith  = __ 'ends with' __ / _ '$end=' _
contains  = __ 'contains' __ / _ '$contains=' _
matches  = __ 'matches' __ / _ '$regex=' _

_ 'whitespace'  = [ \n\t\r]*
__ 'whitespace' = [ \n\t\r]+

fieldid = string / field:fieldexpr {return '"' + field + '"';}

fieldexpr
= left:field of right:fieldexpr {return right + '.' + left;}
/ left:field dot right:fieldexpr {return left + '.' + right;}
/ field
of = __ 'of' __
dot = '.'

field = nodollar chars:notreserved* {return chars.join('');}
nodollar = !"$"
notreserved = [^:${}"'=<>&!*\^., \n\t\r]

value 'value'  = datevalue / number / boolean /  string
number  = float / integer
boolean = "true" / "false"
string  = dqstring

float
= whole:integer '.' partial:digits {
    return parseFloat(whole + '.' + partial)
  }

integer
= sign:sign? digits:digits {
    return parseInt(sign ? sign + digits : digits);
  }

digits
= digits:digit+ {
    return digits.join('');
  }

digit = [0-9]
sign = '+' / '-'

datevalue
= datetime:datetime {return '{"$date": ' + Date.parse(datetime) + '}'; }

datetime
= date:date " " time:time {return date + " " + time;}
/ date

date
= year:year '-' month:month '-' day:day {return year + "-" + month + "-" + day; }

time
= hours:hours ':' minutes:minutes ':' seconds:minutes {return hours + ":" + minutes + ":" + seconds; }
/ hours:hours ':' minutes:minutes {return hours + ":" + minutes; }
/ hours

year    =  millenia:digit centuries:digit decades:digit years:digit { return millenia + centuries + decades + years; }
month   = "0" ones:[1-9] { return "0" + ones;} / "1" ones:[0-2] { return "1" + ones; }
day     = "3" ones:[0-1] { return "3" + ones; } / tens:[0-2] ones:digit { return tens + ones; }
hours   = "2" ones:[0-4] { return "2" + ones; } / tens:[0-1] ones:digit { return tens + ones; }
minutes = tens:[0-5] ones:digit { return tens + ones; }

dqstring
    = '"' text:(!dquote .)* last:dquote {
	var result = "";
	for (var c in text) {
	    result += text[c][1];
	}
	return '"' + result + last + '"';
    }

dquote
    = last:[^\\] '"' {return last;}

andlist
= left:valueexpr _ ',' right:andlist { return left + ';' + right;}
/ left:valueexpr _ '&' right:andlist { return left + ';' + right;}
/ left:valueexpr __ "and" right:valueexpr { return left + ';' + right;}
/ left:valueexpr _ "&" right:valueexpr { return left + ';' + right;}

orlist
= left:valueexpr _ ',' right:orlist { return left + ';' + right;}
/ left:valueexpr _ '|' right:orlist { return left + ';' + right;}
/ left:valueexpr __ "or" right:valueexpr { return left + ';' + right;}
/ left:valueexpr _ "|" right:valueexpr { return left + ';' + right;}