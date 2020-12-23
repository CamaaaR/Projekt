CREATE TABLE `Budzet` (
  `idBudzet` int NOT NULL AUTO_INCREMENT,
  `Dochody` float NOT NULL,
  `Pensje` float NOT NULL,
  `StaleWydatki` float NOT NULL,
  `WartoscKlubu` float NOT NULL,
  `KasaTransfer` int NOT NULL,
  `Rok` year NOT NULL,
  PRIMARY KEY (`idBudzet`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci




CREATE DEFINER=`rodzenkon`@`localhost` TRIGGER `Budzet_BEFORE_UPDATE` BEFORE UPDATE ON `Budzet` FOR EACH ROW BEGIN
	IF NEW.StaleWydatki+NEW.Pensje>NEW.Dochody
    THEN
	UPDATE Zawodnicy
    SET Pensje= NEW.Zawodnicy.Zarobki-50;
    END IF;
    
END



CREATE TABLE `Mecz` (
  `idMecz` int NOT NULL AUTO_INCREMENT,
  `Kiedy` int NOT NULL,
  `Kto` int NOT NULL,
  `Gra` enum('Wyjsciowy','Rezerwowy','Brak') NOT NULL,
  PRIMARY KEY (`idMecz`),
  KEY `Kiedy_idx` (`Kiedy`),
  KEY `Kto_idx` (`Kto`),
  CONSTRAINT `Kiedy` FOREIGN KEY (`Kiedy`) REFERENCES `Terminarz` (`idTerminarz`),
  CONSTRAINT `Kto` FOREIGN KEY (`Kto`) REFERENCES `Statystyki` (`idStatystyki`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


CREATE TABLE `Statystyki` (
  `idStatystyki` int NOT NULL AUTO_INCREMENT,
  `Pilkarz` int NOT NULL,
  `Bramki` int NOT NULL,
  `Minut` int NOT NULL,
  `Zolte` int NOT NULL,
  `Czerwone` int NOT NULL,
  `Mecze` int NOT NULL,
  PRIMARY KEY (`idStatystyki`),
  KEY `Pilkarz_idx` (`Pilkarz`),
  CONSTRAINT `Pilkarz` FOREIGN KEY (`Pilkarz`) REFERENCES `Zawodnicy` (`idZawodnicy`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci




CREATE TABLE `Terminarz` (
  `idTerminarz` int NOT NULL AUTO_INCREMENT,
  `Data` date NOT NULL,
  `Gdzie` enum('Wyjazdowy','Domowy') NOT NULL,
  `Stadion` varchar(45) NOT NULL,
  `DruzynaPrzeciwna` varchar(45) NOT NULL,
  PRIMARY KEY (`idTerminarz`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci



CREATE TABLE `Transfery` (
  `idTransfery` int NOT NULL AUTO_INCREMENT,
  `Pilkarz` int NOT NULL,
  `StaryKlub` varchar(45) NOT NULL,
  `Cena` float NOT NULL,
  `Kasa` int NOT NULL,
  `PensjaStaryKlub` float NOT NULL,
  PRIMARY KEY (`idTransfery`),
  KEY `Pilkarz_idx` (`Pilkarz`),
  KEY `Kasa_idx` (`Kasa`),
  CONSTRAINT `Kasa` FOREIGN KEY (`Kasa`) REFERENCES `Budzet` (`idBudzet`),
  CONSTRAINT `Pilkarz2` FOREIGN KEY (`Pilkarz`) REFERENCES `Zawodnicy` (`idZawodnicy`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci



CREATE TABLE `Zawodnicy` (
  `idZawodnicy` int NOT NULL AUTO_INCREMENT,
  `Imie` varchar(45) NOT NULL,
  `Nazwisko` varchar(45) NOT NULL,
  `Koszulka` int NOT NULL,
  `Pozycja` enum('Bramkarz','Obronca','Pomocnik','Napastnik') NOT NULL,
  `DataUr` date NOT NULL,
  `Zarobki` float NOT NULL,
  `Wartosc` float NOT NULL,
  `Premia` float DEFAULT NULL,
  PRIMARY KEY (`idZawodnicy`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci




CREATE DEFINER=`rodzenkon`@`localhost` TRIGGER `Zawodnicy_BEFORE_UPDATE` BEFORE UPDATE ON `Zawodnicy` FOR EACH ROW BEGIN
 IF NEW.Zarobki < OLD.Zarobki
  THEN
    UPDATE Budzet
    SET Pensje= NEW.Zarobki+Budzet.Pensje;
  END IF;
END




CREATE DEFINER=`rodzenkon`@`localhost` FUNCTION `Zarobki`() RETURNS int
BEGIN
	DECLARE ile INT;
    SELECT AVG(Zarobki) INTO @ile FROM Zawodnicy Group by Zarobki;
    RETURN @ile;
END






CREATE DEFINER=`rodzenkon`@`localhost` PROCEDURE `Premia`()
BEGIN
	UPDATE rodzenkon.Zawodnicy
    SET Premia = (Zawodnicy.zarobki/100)*(Statystyki.Bramki)-(Statystyki.Czerwone*5);
END