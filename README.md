# Description
- Installs standard dependencies
- Sets up nginx
- Sets up certbot auto renew
- Sets up mariadb
- Configures SELinux

# Usage
Direct:
`sudo ./bootstrap.sh`

In script:
`[[ -f /bootstrapped ]] || bash <(curl -s https://mywebsite.com/myscript.txt)`
