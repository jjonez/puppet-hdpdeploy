class ambari::os(

)inherits ::ambari::params {

  contain ambari::os::packages
  contain ambari::os::firewall
  contain ambari::os::jdk
  contain ambari::os::ntp
  contain ambari::os::thp
  contain ambari::os::limits
  contain ambari::os::ambari_user_prep

  Class[::ambari::os::packages] ->
  Class[::ambari::os::jdk] ->
  Class[::ambari::os::firewall] ->
  Class[::ambari::os::ntp] ->
  Class[::ambari::os::thp] ->
  Class[::ambari::os::limits] ->
  Class[::ambari::os::ambari_user_prep]

}


