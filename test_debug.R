# Test file for browser()-based debugging in R
#
# Usage:
# 1. Start R console: <LocalLeader>rf
# 2. Source this file: select all and <Enter>
# 3. Run: test_function(5)
# 4. When browser() is hit, you're in debug mode
# 5. Try debug commands:
#    - ls()    : see local variables
#    - where   : see call stack
#    - n       : next line
#    - s       : step into
#    - c       : continue
#    - Q       : quit debug mode
# 6. Or use helper keybindings:
#    - <LocalLeader>dl : List variables
#    - <LocalLeader>de : List with structure
#    - <LocalLeader>dw : Show call stack

test_function <- function(n) {
  x <- n * 2
  y <- x + 10
  browser()  # Execution pauses here - try ls() to see x, y, n
  z <- calculate_sum(x, y)

  result <- list(
    input = n,
    doubled = x,
    plus_ten = y,
    sum = z
  )

  return(result)
}

calculate_sum <- function(a, b) {
  total <- a + b
  squared <- total^2
  return(squared)
}

# Try it:
# test_function(5)
