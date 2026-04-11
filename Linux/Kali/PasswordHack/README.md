## Password Hack

### Password crack (exact match)

> Using john in Kali

```bash

mkdir passtest
cd passtest

cat <<EOF > small.txt
password
123456
qwerty
letmein
admin
password123
EOF

openssl passwd -1 password123 >> hash.txt

john --wordlist=small.txt hash.txt

john --show hash.txt



cd -
rm -rf passtest


```

### Password crack (mutate)

```bash

mkdir passtest
cd passtest

cat <<EOF > small.txt
password
123456
qwerty
letmein
admin
EOF

cat <<'EOF' > ~/.john/john.conf
[List.Rules:CommonSuffixes]
:
c
$1$2$3
$1$2$3$4
$a$b$c
c$1$2$3
c$1$2$3$4
c$a$b$c
EOF

openssl passwd -1 password123 >> hash.txt


john --wordlist=small.txt --rules=commonsuffixes --stdout

john --wordlist=small.txt --rules hash.txt ## IF NO john.conf use default
john --wordlist=small.txt --rules=CommonSuffixes hash.txt



john --show hash.txt



cd -
rm -rf passtest


```

### List john 

````bash
ls ~/.john -l

cat ~/.john/john.pot


```

### Clean john

```bash

rm -rf ~/.john
mkdir ~/.john



```


### Hack a users linux password

```bash

sudo userdel labuser

sudo useradd -m -s /bin/bash labuser
sudo passwd labuser

sudo cat /etc/passwd | grep labuser
sudo cat /etc/shadow | grep labuser

mkdir userhack
cd userhack

sudo grep '^labuser:' /etc/shadow | sudo tee lab-shadow.txt >/dev/null


[ -e small.txt ] && rm small.txt
cat <<'EOF' > small.txt
password
admin
letmein
qwerty
EOF


[ -e ~/.john/john.conf ] && rm ~/.john/john.conf
cat <<'EOF' > ~/.john/john.conf
[List.Rules:CommonSuffixes]
:
c
$1$2$3
$1$2$3$4
$a$b$c
c$1$2$3
c$1$2$3$4
c$a$b$c
EOF


## Reset results

rm -f ~/.john/john.pot

john --format=crypt --wordlist=small.txt --rules=CommonSuffixes lab-shadow.txt

john --format=crypt --show lab-shadow.txt


cat ~/.john/john.pot 



```