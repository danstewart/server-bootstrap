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
`[[ -f /bootstrapped ]] || bash <(curl -s https://raw.githubusercontent.com/danstewart/server-bootstrap/master/bootstrap.sh)`
