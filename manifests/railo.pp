# railo.pp

# define the railo version you want here:
$railoVersion = '4.1.2.005'
$warFileName = "railo-${railoVersion}.war"

# update all packages
exec { 'apt-get':
  command  => '/usr/bin/apt-get update',
}

# get htop
package { 'htop':
  ensure  => present,
  require => Exec['apt-get'],
}

package { 'curl':
  ensure  => present,
  require => Exec['apt-get'],
}

# add cp2 to to the hosts file
host { 'cp2.retailcloud.net':
  ip  => '127.0.0.1',
}


# make sure tomcat is installed
package {'tomcat7':
  ensure  => installed,
  require => Package['curl'],
}

# once tomcat is installed
service { 'tomcat7':
  ensure  => 'running',
  enable  => true,
  require => Package['tomcat7'],
}

# download the railo war
exec { 'railo-download':
  command => "/usr/bin/wget --quiet http://www.getrailo.org/railo/remote/download/${railoVersion}/custom/all/${warFileName}",
  cwd     => '/home/vagrant/',
  creates => "/home/vagrant/${warFileName}",
  require => Package['tomcat7'],
}

# stick the railo war file into tomcat
file { 'railo.war':
  name    => '/var/lib/tomcat7/webapps/railo.war',
  owner   => 'tomcat7',
  group   => 'tomcat7',
  source  => "/home/vagrant/${warFileName}",
  require => Exec['railo-download'],
}


# add sqlite JDBC driver jar
file { '/usr/share/tomcat7/lib/sqlite-jdbc-3.7.15-M1.jar':
  owner   => 'tomcat7',
  group   => 'tomcat7',
  source  => '/vagrant/files/sqlite-jdbc-3.7.15-M1.jar',
  require => Package['tomcat7'],
  notify  => Service['tomcat7'],
}

# prod tomcat
exec { 'curl':
  name    => '/usr/bin/curl localhost:8080',
  require => File['railo.war'],
  notify  => Service['tomcat7'],
}
