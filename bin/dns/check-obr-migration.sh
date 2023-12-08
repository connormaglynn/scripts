echo "--------------------------------------"
echo "✨ Records that should be created ✨"
echo "--------------------------------------"
echo "👉 mimecast20231207._domainkey.obr.uk TXT 👈"
echo "Expected value 🧪:"
echo "v=DKIM1;\n"
echo "k=rsa;\n"
echo "p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgBGJm4LWcGNz+lMZ0NZ7vvV/ylE6ezq/J5/mqruAMqPLtYIKrnKpo4T0z/brejbLdUuRUFzl5sNrKPPGS0twGeU/iL8dmqRT5UHOX6n1kRZLK9KDWOxY+x/bTYON+c0X3ijQXrfp5UgzaRg5C/lSjeuXNpC20EJoKIdxOJeBGs+QjYzgZKxQUJVqAPKlqOVlGHCYcWbeIwOFl7+G5ccvttRw3p0QTVVBkRM28UjnYGv427H1++NsP3xIhXbRwujiuvCKlXFZpxfNJMlt6vHXcJJvh5+Yab9eQQsHuuHzioo/ZWBP4wejOMTqmGLfo8R75UVFgghdkspll3jz8kR0PwIDAQAB\n"
echo "Actual value 👇"
dig +noall +answer +multiline mimecast20231207._domainkey.obr.uk TXT
echo ""

echo "--------------------------------------"
echo "♻️ Records that should be replaced ♻️"
echo "--------------------------------------"
echo "👉 obr.uk TXT 👈"
echo "Expected value 🧪:"
echo "v=spf1 ip4:194.33.196.8/32 ip4:194.33.192.8/32 include:eu._netblocks.mimecast.com ~all\n"
echo "atlassian-domain-verification=eZYa71sfUYC3GKWDAnR6IDBAD7m0PkEaKKOYkM2cjWj8or0XT0PwqvFpqTLtaNby0ed1fe018a00b931d1f1014ad8bc2cdf188f9ab969\n"
echo "MS=ms61537345\n"
echo "Actual value 👇"
dig +noall +answer +multiline obr.uk TXT
echo "---"
echo "👉 obr.uk MX 👈"
echo "Expected value 🧪:"
echo "10 eu-smtp-inbound-1.mimecast.com\n"
echo "10 eu-smtp-inbound-2.mimecast.com\n"
echo "Actual value 👇"
dig +noall +answer +multiline obr.uk MX
echo ""

echo "--------------------------------------"
echo "🔥 Records that should be deleted 🔥"
echo "--------------------------------------"
echo "👉 _dmarc.obr.uk CNAME 👈"
dig +noall +answer +multiline _dmarc.obr.uk CNAME
echo "---"
echo "👉 selector1._domainkey.obr.uk CNAME 👈"
dig +noall +answer +multiline selector1._domainkey.obr.uk CNAME
echo "---"
echo "👉 selector2._domainkey.obr.uk CNAME 👈"
dig +noall +answer +multiline selector2._domainkey.obr.uk CNAME
echo "---"
echo "👉 _smtp._tls.obr.uk TXT 👈"
dig +noall +answer +multiline _smtp._tls.obr.uk TXT
echo "---"
echo "👉 _asvdns-38231a2b-cd36-4b0f-b6ae-06eef91176ac.obr.uk TXT 👈"
dig +noall +answer +multiline _asvdns-38231a2b-cd36-4b0f-b6ae-06eef91176ac.obr.uk TXT
echo "---"
echo "👉 fp01._domainkey.obr.uk TXT 👈"
dig +noall +answer +multiline fp01._domainkey.obr.uk TXT
echo ""




