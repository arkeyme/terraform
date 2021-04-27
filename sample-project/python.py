
import pathlib

path = pathlib.Path().absolute()

#path = pathlib.Path().absolute()
print(path)


f = open('install_apache.sh')
for line in f:
    print(line,end='')
