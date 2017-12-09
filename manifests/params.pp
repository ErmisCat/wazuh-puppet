# Paramas file
class wazuh::params {
  case $::kernel {
    'Linux': {
      $config_file = '/var/ossec/etc/ossec.conf'
      $shared_agent_config_file = '/var/ossec/etc/shared/agent.conf'

      $config_mode = '0640'
      $config_owner = 'root'
      $config_group = 'ossec'

      $keys_file = '/var/ossec/etc/client.keys'
      $keys_mode = '0640'
      $keys_owner = 'root'
      $keys_group = 'ossec'

      $authd_pass_file = '/var/ossec/etc/authd.pass'

      $validate_cmd_conf = '/var/ossec/bin/verify-agent-conf -f %'

      $processlist_file = '/var/ossec/bin/.process_list'
      $processlist_mode = '0640'
      $processlist_owner = 'root'
      $processlist_group = 'ossec'

      # this hash is currently only covering the basic config section of config.js
      # TODO: allow customization of the entire config.js
      # for reference: https://documentation.wazuh.com/current/user-manual/api/configuration.html
      $api_config_params = [
        {'name' => 'ossec_path', 'value' => '/var/ossec'},
        {'name' => 'host', 'value' => '0.0.0.0'},
        {'name' => 'port', 'value' => '55000'},
        {'name' => 'https', 'value' => 'no'},
        {'name' => 'basic_auth', 'value' => 'yes'},
        {'name' => 'BehindProxyServer', 'value' => 'no'}
      ]

      case $::osfamily {
        'Debian': {
          $agent_service = 'wazuh-agent'
          $agent_package = 'wazuh-agent'
          $service_has_status = false
          $ossec_service_provider = undef
          $api_service_provider = undef
          $deb_repo = 'https://packages.wazuh.com/apt'
          $deb_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
          $deb_key_id = '0DCFCA5547B19D2A6099506096B3EE5F29111145'

          $default_local_files = {
            '/var/log/syslog'                      => 'syslog',
            '/var/log/kern.log'                    => 'syslog',
            '/var/log/auth.log'                    => 'syslog',
            '/var/log/mail.log'                    => 'syslog',
            '/var/log/dpkg.log'                    => 'syslog',
            '/var/ossec/logs/active-responses.log' => 'syslog',
          }

          case $::lsbdistcodename {
            'xenial': {
              $server_service = 'wazuh-manager'
              $server_package = 'wazuh-manager'
              $api_service = 'wazuh-api'
              $api_package = 'wazuh-api'
              $wodle_openscap_content = {
                'ssg-ubuntu-1604-ds.xml' => {
                  type => 'xccdf',
                  profiles => ['xccdf_org.ssgproject.content_profile_common']
                }
              }
            }
            'jessie': {
              $server_service = 'wazuh-manager'
              $server_package = 'wazuh-manager'
              $api_service = 'wazuh-api'
              $api_package = 'wazuh-api'
              $wodle_openscap_content = {
                'ssg-debian-8-ds.xml' => {
                  type => 'xccdf',
                  profiles => ['xccdf_org.ssgproject.content_profile_common']
                },
                'cve-debian-oval.xml' => {
                  type => 'oval'
                }
              }
            }
            /^(wheezy|stretch|sid|precise|trusty|vivid|wily|xenial)$/: {
              $server_service = 'wazuh-manager'
              $server_package = 'wazuh-manager'
              $api_service = 'wazuh-api'
              $api_package = 'wazuh-api'
              $wodle_openscap_content = undef
            }
            default: {
              fail("Module ${module_name} is not supported on ${::operatingsystem}")
            }
          }
        }
        'Linux', 'RedHat': {
          $agent_service  = 'wazuh-agent'
          $agent_package  = 'wazuh-agent'
          $server_service = 'wazuh-manager'
          $server_package = 'wazuh-manager'
          $api_service = 'wazuh-api'
          $api_package = 'wazuh-api'
          $service_has_status  = true
          $ossec_service_provider = 'redhat'
          $api_service_provider = 'redhat'

          $default_local_files = {
            '/var/log/messages'         => 'syslog',
            '/var/log/secure'           => 'syslog',
            '/var/log/maillog'          => 'syslog',
            '/var/log/yum.log'          => 'syslog',
            '/var/log/httpd/access_log' => 'apache',
            '/var/log/httpd/error_log'  => 'apache'
          }
          if ( $::operatingsystem == 'Amazon' ) {
            $wodle_openscap_content = undef
            $rpm_repo = 'https://packages.wazuh.com/yum/el/6Server/$basearch'
            $rpm_key = 'https://packages.wazuh.com/key/RPM-GPG-KEY-OSSEC-RHEL5'
          } else {
            case $::os[name] {
              'CentOS': {
                $rpm_repo = 'https://packages.wazuh.com/yum/el/$releasever/$basearch'
                if ( $::operatingsystemrelease =~ /^5.*/ ) {
                  $wodle_openscap_content = undef
                  $rpm_key = 'https://packages.wazuh.com/key/RPM-GPG-KEY-OSSEC-RHEL5'
                }
                if ( $::operatingsystemrelease =~ /^6.*/ ) {
                  $wodle_openscap_content = {
                    'ssg-centos-6-ds.xml' => {
                      type => 'xccdf',
                      profiles => ['xccdf_org.ssgproject.content_profile_pci-dss', 'xccdf_org.ssgproject.content_profile_server']
                    }
                  }
                  $rpm_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
                }
                if ( $::operatingsystemrelease =~ /^7.*/ ) {
                  $wodle_openscap_content = {
                    'ssg-centos-7-ds.xml' => {
                      type => 'xccdf',
                      profiles => ['xccdf_org.ssgproject.content_profile_pci-dss', 'xccdf_org.ssgproject.content_profile_common']
                    }
                  }
                  $rpm_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
                }
              }
              /^(RedHat|OracleLinux)$/: {
                $rpm_repo = 'https://packages.wazuh.com/yum/rhel/$releasever/$basearch'
                if ( $::operatingsystemrelease =~ /^5.*/ ) {
                  $wodle_openscap_content = undef
                  $rpm_key = 'https://packages.wazuh.com/key/RPM-GPG-KEY-OSSEC-RHEL5'
                }
                if ( $::operatingsystemrelease =~ /^6.*/ ) {
                  $wodle_openscap_content = {
                    'ssg-rhel-6-ds.xml' => {
                      type => 'xccdf',
                      profiles => ['xccdf_org.ssgproject.content_profile_pci-dss', 'xccdf_org.ssgproject.content_profile_server']
                    },
                    'cve-redhat-6-ds.xml' => {
                      type => 'xccdf',
                    }
                  }
                  $rpm_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
                }
                if ( $::operatingsystemrelease =~ /^7.*/ ) {
                  $wodle_openscap_content = {
                    'ssg-rhel-7-ds.xml' => {
                      type => 'xccdf',
                      profiles => ['xccdf_org.ssgproject.content_profile_pci-dss', 'xccdf_org.ssgproject.content_profile_common',]
                    },
                    'cve-redhat-7-ds.xml' => {
                      type => 'xccdf',
                    }
                  }
                  $rpm_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
                }
              }
              'Fedora': {
                $rpm_repo = 'https://packages.wazuh.com/yum/fc/$releasever/$basearch'
                $rpm_key = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
                if ( $::operatingsystemrelease =~ /^(23|24|25).*/ ) {
                  $wodle_openscap_content = {
                    'ssg-fedora-ds.xml' => {
                      type => 'xccdf',
                      profiles => ['xccdf_org.ssgproject.content_profile_standard', 'xccdf_org.ssgproject.content_profile_common']
                    },
                  }
                }
              }
              default: { fail('This ossec module has not been tested on your distribution') }
            }
          }
        }
        default: { fail('This ossec module has not been tested on your distribution') }
    }
  }
    'windows': {
      $config_file = regsubst(sprintf('c:/Program Files (x86)/ossec-agent/ossec.conf'), '\\\\', '/')
      $shared_agent_config_file = regsubst(sprintf('c:/Program Files (x86)/ossec-agent/shared/agent.conf'), '\\\\', '/')
      $config_owner = 'Administrator'
      $config_group = 'Administrators'

      $keys_file = regsubst(sprintf('c:/Program Files (x86)/ossec-agent/client.keys'), '\\\\', '/')
      $keys_mode = '0440'
      $keys_owner = 'Administrator'
      $keys_group = 'Administrators'

      $agent_service  = 'OssecSvc'
      $agent_package  = 'Wazuh Agent 2.0'
      $server_service = ''
      $server_package = ''
      $api_service = ''
      $api_package = ''
      $service_has_status  = true

      # TODO
      $validate_cmd_conf = undef
      # Pushed by shared agent config now
      $default_local_files = {}
    }
  default: { fail('This ossec module has not been tested on your distribution') }
  }
}
