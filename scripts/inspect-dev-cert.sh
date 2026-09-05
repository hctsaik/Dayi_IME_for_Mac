#!/bin/sh
set -e
security find-certificate -c "Apple Development: hctsaik@gmail.com" -p > /tmp/dev.pem
echo "--- cert ---"
openssl x509 -in /tmp/dev.pem -noout -issuer -subject -dates
echo "--- verify ---"
security verify-cert -c /tmp/dev.pem 2>&1 || true
echo "--- wwdr names ---"
security find-certificate -a -c "Apple Worldwide Developer Relations" | grep -i '"labl"' || true
echo "--- apple root ---"
security find-certificate -a -c "Apple Root CA" | grep -i '"labl"' || true
echo "--- trust ---"
security dump-trust-settings -d 2>&1 | head -40 || true
echo "--- keychain cert trust ---"
security dump-trust-settings 2>&1 | head -20 || true
