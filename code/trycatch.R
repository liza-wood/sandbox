# https://stackoverflow.com/questions/8093914/use-trycatch-skip-to-next-value-of-loop-upon-error

# The key to using tryCatch is realising that it returns an object. If there was an error inside the tryCatch then this object will inherit from class error. You can test for class inheritance with the function inherit.

x <- tryCatch(stop("Error"), error = function(e) e)
class(x)

# What is the meaning of the argument error = function(e) e? This baffled me, and I don't think it's well explained in the documentation. What happens is that this argument catches any error messages that originate in the expression that you are tryCatching. If an error is caught, it gets returned as the value of tryCatch. In the help documentation this is described as a calling handler. The argument e inside error=function(e) is the error message originating in your code.

#I come from the old school of procedural programming where using next was a bad thing. So I would rewrite your code something like this. (Note that I removed the next statement inside the tryCatch.):

for (i in 1:39487) {
  #ERROR HANDLING
  possibleError <- tryCatch(
    thing(),
    error=function(e) e
  )
  
  if(inherits(possibleError, "error")) next
  
  #REAL WORK
  useful(i); fun(i); good(i);
  
}  #end for