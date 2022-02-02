int x = 6;
int y;
y = x + 7;
string xstr = "Hi";
string ystr = "Bye";
string strcon = "x";
strcon = xstr + " " + ystr;

print "x is: "; print x; print "\n";
print "y is: "; print y; print "\n";
print "xstr is: "; print xstr; print "\n";
print "ystr is: "; print ystr; print "\n";
print "xstr + \" \" + ystr is: "; print strcon; print "\n";

print "\n5 + 3 + 3 + 4 - 4 -3 * 4 * 3 * 5 / 4 / 5 * (4 - 4) = ";
print 5 + 3 + 3 + 4 - 4 - -3 * 4 * 3 * 5 / 4 / 5 * (4 - 4);
print"\n";

print "\nx + 5 + 3 + 3 + 4 - 4 -3 * 4 * 3 * 5 / 4 / 5 * (4 - 4) = ";
print x + 5 + 3 + 3 + 4 - 4 - -3 * 4 * 3 * 5 / 4 / 5 * (4 - 4);
print"\n";


print"\n\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\n\n";

x = 5;

while(x >= 1)
{
    y = 3;
    while(y > 0)
    {
        print x; print "\t"; print y; print"\n";
        y = y - 1;
    }
	if(x == 3)
	{
		print "x was: "; print x; print ". terminate the loop\n";
		break;
	}
    x = x - 1;
}

print"\n\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\n\n";
x = 1; y = 0;
if(x OR y) {print "x or y is true.\n";}
else   print "x or y is false.\n";


x = 1; y = 0;

if(x AND y) {print "x and y is true.\n";}
else
{
    print "x and y is false.\n";
}

print"\n\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\n\n";

x = 9;
if(x / 9 == 1)
{
print "Time to terminate the program. Bye!\n";
HI-TERMINATE;
}
print "proof the program will stop after HI-TERMINATE;\n";
