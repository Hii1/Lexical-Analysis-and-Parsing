TO EXECUTE THIS CODE, GO TO YOUR TERMINAL, ENTER YOUR WORKING DIRECTORY AND TYPE THE FOLLOWING COMMANDS.

```
$ yacc -d mpl.y
$ lex mpl.l
$ cc lex.yy.c y.tab.c -o MPL
$ ./MPL <code1.mpl
$ ./MPL <code2.mpl
```

- mpl.h<br/>
  &nbsp;contains the node structure. &nbsp;&nbsp;

## MPL RULES:

- There are 4 predefined data types (int, float, char, string).
  • int: for integers.
  • float: for float numbers
  • char: for single characters (letter or digit)
  • string: for characters string, it must be enclosed by ellipsis (“), the string can include special characters like \n which means new line.
- There are 6 comparison operators (==, !=, >, <, >=, <=),
- There are 2 logical operators (AND, OR).
- There are 5 reserved keywords (while, if, else print, break, HI-TERMINATE).
  • While: loops through a block of code as long as a specified condition is true or if there is a break statement.
  • If: block of code will be executed if the specified condition is true.
  • Else: block of code will be executed if the condition of the if statements was false. (Else must be preceded by if statement)
  • Print: the expression after print statement will be send to stdout (usually the terminal).
  • HI-TERMINATE: ends the execution of the code.
- Variables
  • A variable name can only have letters (both uppercase and lowercase letters), digits and underscore (\_).
  • The first letter of a variable should be either a letter or an underscore.
  • There is no rule on how long a variable name (identifier) can be.
- White space will be ignored, except new line(\n).
- Any other lexeme will result in an error.
