FIELD:SYNTAX

# Date

**Open range**  
date:>2022-02-22  
date:>=2022-02-22  
date:<2022-02-22T00:00:00+08:00  
date:<2022-02-22T00:00:00Z  

**Range (inclusive)**  
date:2022-02-22..2022-03-11  

> Note: Date without time is equivalent to 00:00:00 at client timezone  
> Implementation Note: client needs to pass to server its local timezone value

# Text

**Contain**  
remarks:text  

**Escaping**  
remarks:free\ text = contain "free text"  
remarks:free\,text = contain "free,text"  

**Exact match**  
remarks:"text"  

**Regex**  
remarks:/foo.*bar\sbaz/gi  

# Number

**Range**  
balance:>1000  
balance:>=1000  
balance:1000.5..2000  

**Exact**  
balance:1000  

# OR (`|`)

remarks:foo|"bar" = contain "foo" or exactly euqal "bar"  
date:>2022-02-22|<2011-11-11  
balance:>300|<200  

# AND (`,`) (not using `&` coz not url-safe)

remarks:foo,bar = contain "foo" and contain "bar"

# AND (multiple entries)

remarks:foo remarks:bar = contain "foo" and contain "bar"

# NOT

**Not contain text**  
remarks:!foo  

**Not exact equal**  
remarks:!"foo"  

# ANY (just to indicate the column is to be included)

date:*
