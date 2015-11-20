# 0.4.3 (2015-11-20)
- SSH configuration only changes if has to change

# 0.4.2 (2015-11-12)
- Fail2ban logs to syslog
- bugfixed case statement

# 0.4.1 (2015-11-09)
- Added E-mail target address for fail2ban
- Centos 7 fail2ban action is ipset
- SSH client timeout needs also ClientAliveCountMax setting

# 0.4.0 (2015-11-09)
- Will change SSH PermitRootLogin to yes or no, previously only no
- Add fail2ban checks to SSH
- Add SSH timeout value (30 minutes)

# 0.3.0 (2015-09-17)
- Rewrote data bag logic
- Renamed attribute bag_name to bucket_name
- Possible to add regular users (without sudo rights)

# 0.2.5 (2015-09-08)
- When removing user, remove also home
