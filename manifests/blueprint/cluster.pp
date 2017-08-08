class ambari::blueprint::cluster() {

 $ambari_server      = $::ambari::blueprint::ambari_server
 $ambari_server_port = $::ambari::blueprint::ambari_server_port
 $hdp_stack_version  = $::ambari::blueprint::hdp_stack_version
 $num_datanodes      = $::ambari::blueprint::num_datanodes
 $cluster_name       = $::ambari::blueprint::cluster_name
 $cluster_config     = $::ambari::blueprint::cluster_config

 $url = "http://${ambari_server}:${ambari_server_port}/api/v1/blueprints/${cluster_name}" 

 file {
   'cluster_config_file':
   ensure => 'file',
   content => template("ambari/blueprint/$cluster_config"),
   path => '/var/lib/puuppet-ambari/cluster_config.json',
   owner => 'root',
   group => 'root',
   mode  => '0700',
   notify => Exec['run_cluster_blueprint'],
 } -> 
 exec {
  'run_cluster_blueprint':
  command => "/bin/env curl -f -H 'X-Requested-By: ambari' -X POST -u admin:admin $url -d @/var/lib/puuppet-ambari/cluster_config.json",
  refreshonly => true
 }

}
