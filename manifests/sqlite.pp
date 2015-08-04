# sqlite.pp

# update all packages
exec { 'apt-update':
  command  => '/usr/bin/apt-get update',
}

# get sqlite
package { 'sqlite3':
  ensure  => '3.7.9-2ubuntu1',
  require => Exec['apt-update'],
}

# create sqlite db directory
file { '/var/sqlite3':
	owner  => 'tomcat7',
  	group  => 'tomcat7',
	ensure => "directory",
}

# copy debugger sqlite database
file { '/var/sqlite3/debugger.db':
  owner   => 'tomcat7',
  group   => 'tomcat7',
  source  => '/vagrant/files/debugger.db',
  require => Package['sqlite3'],
}
