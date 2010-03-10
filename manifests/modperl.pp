# domainalias:
#   - www: add as well a www.${name} entry
#   - absent: do nothing
#   - default: add the string
# user_provider:
#   - local: user will be crated locally (*default*)
#   - everything else will currently do noting
# run_mode:
#   - normal: nothing special (*default*)
#   - itk: apache is running with the itk module
#          and run_uid and run_gid are used as vhost users
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
define webhosting::modperl(
    $ensure = present,
    $uid = 'absent',
    $uid_name = 'absent',
    $gid = 'uid',
    $user_provider = 'local',
    $password = 'absent',
    $password_crypted = true,
    $domain = 'absent',
    $domainalias = 'www',
    $server_admin = 'absent',
    $owner = root,
    $group = 'sftponly',
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_uid_name = 'absent',
    $run_gid = 'absent',
    $run_gid_name = 'absent',
    $allow_override = 'None',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $ssl_mode = false,
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $nagios_check = 'ensure',
    $nagios_check_domain = 'absent',
    $nagios_check_url = '/',
    $nagios_check_code = 'OK',
    $mod_security = true
){
    if ($uid_name == 'absent'){
      $real_uid_name = $name
    } else {
      $real_uid_name = $uid_name
    }
    webhosting::common{$name:
        ensure => $ensure,
        uid => $uid,
        uid_name => $uid_name,
        gid => $gid,
        user_provider => $user_provider,
        password => $password,
        password_crypted => $password_crypted,
        htpasswd_file => $htpasswd_file,
        ssl_mode => $ssl_mode,
        run_mode => $run_mode,
        run_uid => $run_uid,
        run_uid_name => $run_uid_name,
        run_gid => $run_gid,
        run_gid_name => $run_gid_name,
        nagios_check => $nagios_check,
        nagios_check_domain => $nagios_check_domain,
        nagios_check_url => $nagios_check_url,
        nagios_check_code => $nagios_check_code,
    }
    apache::vhost::modperl{"${name}":
        ensure => $ensure,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => 'absent',
        group => $group,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        run_mode => $run_mode,
        ssl_mode => $ssl_mode,
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        htpasswd_file => $htpasswd_file,
        mod_security => $mod_security,
    }
    case $run_mode {
        'itk': {
          if ($run_uid_name == 'absent'){
            $real_run_uid_name = "${name}_run"
          } else {
            $real_run_uid_name = $run_uid_name
          }
          if ($run_gid_name == 'absent'){
            $real_run_gid_name = $name
          } else {
            $real_run_gid_name = $run_gid_name
          }

          Apache::Vhost::Modperl[$name]{
            documentroot_owner => $real_uid_name,
            documentroot_group => $real_uid_name,
            documentroot_mode => 0750,
            run_uid => $real_run_uid_name,
            run_gid => $real_run_gid_name,
          }
          if ($user_provider == 'local') {
              Apache::Vhost::Modperl[$name]{
                require => [ User::Sftp_only["${real_uid_name}"], User::Managed["${real_run_uid_name}"] ],
              }
          }
        }
        default: {
          if ($user_provider == 'local') {
            Apache::Vhost::Modperl[$name]{
                require => User::Sftp_only["${real_uid_name}"],
            }
          }
        }
    }
}
