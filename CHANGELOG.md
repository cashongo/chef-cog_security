# 0.5.1
- change slack channel for actual use

# 0.5.0 (2016-09-20)
- fail2ban script for slack

# 0.4.3 (2015-11-20)
- ssh configuration only changes if has to change

# 0.4.2 (2015-11-12)
- fail2ban logs to syslog
- bugfixed case statement

# 0.4.1 (2015-11-09)
- add E-mail target address for fail2ban
- centos 7 fail2ban action is ipset
- ssh client timeout needs also ClientAliveCountMax setting

# 0.4.0 (2015-11-09)
- will change ssh PermitRootLogin to yes or no, previously only no
- add fail2ban checks to SSH
- add ssh timeout value (30 minutes)

# 0.3.0 (2015-09-17)
- rewrote data bag logic
- renamed attribute bag_name to bucket_name
- possible to add regular users (without sudo rights)

# 0.2.5 (2015-09-08)
- remove home when removing home
