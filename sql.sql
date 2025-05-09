CREATE TABLE IF NOT EXISTS `exter_moneywash` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(46) DEFAULT NULL,
  `props` longtext DEFAULT NULL,
  `miner` longtext DEFAULT NULL,
  `canvas` longtext DEFAULT NULL,
  `machine_data` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;