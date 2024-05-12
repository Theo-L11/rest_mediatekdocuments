-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3308
-- Généré le : dim. 12 mai 2024 à 20:06
-- Version du serveur : 8.0.31
-- Version de PHP : 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mediatek86`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `InsertExemplaires`$$
CREATE DEFINER=`u571444920_adminmediadoc`@`127.0.0.1` PROCEDURE `InsertExemplaires` (IN `idCommande` VARCHAR(5), IN `nbExemplaire` INT)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE exemplaire_numero INT;
    DECLARE dateCommande DATE;
    DECLARE idLivreDvd VARCHAR(5);
    SELECT c.dateCommande, cd.idLivreDvd INTO dateCommande, idLivreDvd FROM commande c JOIN commandedocument cd ON c.id = cd.id WHERE cd.id = idCommande;
    IF EXISTS (SELECT 1 FROM document WHERE id = idLivreDvd) THEN
        WHILE i < nbExemplaire DO
            IF EXISTS (SELECT 1 FROM exemplaire WHERE id = idLivreDvd) THEN
                SELECT COALESCE(MAX(numero), 0) + 1 INTO exemplaire_numero FROM exemplaire WHERE id = idLivreDvd;
            ELSE
                SET exemplaire_numero = 1;
            END IF;
            INSERT INTO exemplaire(id, numero, dateAchat, photo, idEtat) VALUES (idLivreDvd, exemplaire_numero, dateCommande, ' ', '00001');
            SET i = i + 1;
        END WHILE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Document does not exist';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `abonnement`
--

DROP TABLE IF EXISTS `abonnement`;
CREATE TABLE IF NOT EXISTS `abonnement` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dateFinAbonnement` date DEFAULT NULL,
  `idRevue` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRevue` (`idRevue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `abonnement`
--

INSERT INTO `abonnement` (`id`, `dateFinAbonnement`, `idRevue`) VALUES
('25', '2024-04-26', '10002'),
('27', '2024-04-20', '10001');

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dateCommande` date DEFAULT NULL,
  `montant` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`id`, `dateCommande`, `montant`) VALUES
('16', '2024-04-15', 12),
('25', '2024-04-16', 50),
('27', '2024-04-16', 46),
('3', '2024-04-08', 25),
('35', '2024-04-23', 15),
('49', '2024-04-23', 50);

--
-- Déclencheurs `commande`
--
DROP TRIGGER IF EXISTS `delete_commandedocument`;
DELIMITER $$
CREATE TRIGGER `delete_commandedocument` BEFORE DELETE ON `commande` FOR EACH ROW BEGIN
    DELETE FROM commandedocument WHERE id = OLD.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `commandedocument`
--

DROP TABLE IF EXISTS `commandedocument`;
CREATE TABLE IF NOT EXISTS `commandedocument` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nbExemplaire` int DEFAULT NULL,
  `idLivreDvd` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idEtape` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idLivreDvd` (`idLivreDvd`),
  KEY `idetape` (`idEtape`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `commandedocument`
--

INSERT INTO `commandedocument` (`id`, `nbExemplaire`, `idLivreDvd`, `idEtape`) VALUES
('16', 12, '20001', '2'),
('3', 25, '00005', '4'),
('35', 2, '00005', '3'),
('49', 10, '00005', '3');

--
-- Déclencheurs `commandedocument`
--
DROP TRIGGER IF EXISTS `check_partition_constraint`;
DELIMITER $$
CREATE TRIGGER `check_partition_constraint` BEFORE INSERT ON `commandedocument` FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM commande WHERE id = NEW.id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'violation de la contrainte de partition : la ligne dans la table commande n'existe pas';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `create_exemplaire_after_delivery`;
DELIMITER $$
CREATE TRIGGER `create_exemplaire_after_delivery` AFTER UPDATE ON `commandedocument` FOR EACH ROW BEGIN
    IF NEW.idEtape = '3' AND OLD.idEtape != '3' THEN
        CALL InsertExemplaires(NEW.id, NEW.nbExemplaire);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `document`
--

DROP TABLE IF EXISTS `document`;
CREATE TABLE IF NOT EXISTS `document` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `titre` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idRayon` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idPublic` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idGenre` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idRayon` (`idRayon`),
  KEY `idPublic` (`idPublic`),
  KEY `idGenre` (`idGenre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `document`
--

INSERT INTO `document` (`id`, `titre`, `image`, `idRayon`, `idPublic`, `idGenre`) VALUES
('00001', 'Quand sort la recluse', '', 'LV003', '00002', '10014'),
('00002', 'Un pays à l\'aube', '', 'LV001', '00002', '10004'),
('00003', 'Et je danse aussi', '', 'LV002', '00003', '10013'),
('00004', 'L\'armée furieuse', '', 'LV003', '00002', '10014'),
('00005', 'Les anonymes', '', 'LV001', '00002', '10014'),
('00006', 'La marque jaune', '', 'BD001', '00003', '10001'),
('00007', 'Dans les coulisses du musée', '', 'LV001', '00003', '10006'),
('00008', 'Histoire du juif errant', '', 'LV002', '00002', '10006'),
('00009', 'Pars vite et reviens tard', '', 'LV003', '00002', '10014'),
('00010', 'Le vestibule des causes perdues', '', 'LV001', '00002', '10006'),
('00011', 'L\'île des oubliés', '', 'LV002', '00003', '10006'),
('00012', 'La souris bleue', '', 'LV002', '00003', '10006'),
('00013', 'Sacré Pêre Noël', '', 'JN001', '00001', '10001'),
('00014', 'Mauvaise étoile', '', 'LV003', '00003', '10014'),
('00015', 'La confrérie des téméraires', '', 'JN002', '00004', '10014'),
('00016', 'Le butin du requin', '', 'JN002', '00004', '10014'),
('00017', 'Catastrophes au Brésil', '', 'JN002', '00004', '10014'),
('00018', 'Le Routard - Maroc', '', 'DV005', '00003', '10011'),
('00019', 'Guide Vert - Iles Canaries', '', 'DV005', '00003', '10011'),
('00020', 'Guide Vert - Irlande', '', 'DV005', '00003', '10011'),
('00021', 'Les déferlantes', '', 'LV002', '00002', '10006'),
('00022', 'Une part de Ciel', '', 'LV002', '00002', '10006'),
('00023', 'Le secret du janissaire', '', 'BD001', '00002', '10001'),
('00024', 'Pavillon noir', '', 'BD001', '00002', '10001'),
('00025', 'L\'archipel du danger', '', 'BD001', '00002', '10001'),
('00026', 'La planète des singes', '', 'LV002', '00003', '10002'),
('10001', 'Arts Magazine', '', 'PR002', '00002', '10016'),
('10002', 'Alternatives Economiques', '', 'PR002', '00002', '10015'),
('10003', 'Challenges', '', 'PR002', '00002', '10015'),
('10004', 'Rock and Folk', '', 'PR002', '00002', '10016'),
('10005', 'Les Echos', '', 'PR001', '00002', '10015'),
('10006', 'Le Monde', '', 'PR001', '00002', '10018'),
('10007', 'Telerama', '', 'PR002', '00002', '10016'),
('10008', 'L\'Obs', '', 'PR002', '00002', '10018'),
('10009', 'L\'Equipe', '', 'PR001', '00002', '10017'),
('10010', 'L\'Equipe Magazine', '', 'PR002', '00002', '10017'),
('10011', 'Geo', '', 'PR002', '00003', '10016'),
('20001', 'Star Wars 5 L\'empire contre attaque', '', 'DF001', '00003', '10002'),
('20002', 'Le seigneur des anneaux : la communauté de l\'anneau', '', 'DF001', '00003', '10019'),
('20003', 'Jurassic Park', '', 'DF001', '00003', '10002'),
('20004', 'Matrix', '', 'DF001', '00003', '10002');

-- --------------------------------------------------------

--
-- Structure de la table `dvd`
--

DROP TABLE IF EXISTS `dvd`;
CREATE TABLE IF NOT EXISTS `dvd` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `synopsis` text COLLATE utf8mb4_unicode_ci,
  `realisateur` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duree` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `dvd`
--

INSERT INTO `dvd` (`id`, `synopsis`, `realisateur`, `duree`) VALUES
('20001', 'Luc est entraîné par Yoda pendant que Han et Leia tentent de se cacher dans la cité des nuages.', 'George Lucas', 124),
('20002', 'L\'anneau unique, forgé par Sauron, est porté par Fraudon qui l\'amène à Foncombe. De là, des représentants de peuples différents vont s\'unir pour aider Fraudon à amener l\'anneau à la montagne du Destin.', 'Peter Jackson', 228),
('20003', 'Un milliardaire et des généticiens créent des dinosaures à partir de clonage.', 'Steven Spielberg', 128),
('20004', 'Un informaticien réalise que le monde dans lequel il vit est une simulation gérée par des machines.', 'Les Wachowski', 136);

-- --------------------------------------------------------

--
-- Structure de la table `etat`
--

DROP TABLE IF EXISTS `etat`;
CREATE TABLE IF NOT EXISTS `etat` (
  `id` char(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `etat`
--

INSERT INTO `etat` (`id`, `libelle`) VALUES
('00001', 'neuf'),
('00002', 'usagé'),
('00003', 'détérioré'),
('00004', 'inutilisable');

-- --------------------------------------------------------

--
-- Structure de la table `exemplaire`
--

DROP TABLE IF EXISTS `exemplaire`;
CREATE TABLE IF NOT EXISTS `exemplaire` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero` int NOT NULL,
  `dateAchat` date DEFAULT NULL,
  `photo` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idEtat` char(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`,`numero`),
  KEY `idEtat` (`idEtat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `exemplaire`
--

INSERT INTO `exemplaire` (`id`, `numero`, `dateAchat`, `photo`, `idEtat`) VALUES
('00005', 1, '2024-04-08', ' ', '00001'),
('00005', 2, '2024-04-08', ' ', '00001'),
('00005', 3, '2024-04-08', ' ', '00001'),
('00005', 4, '2024-04-08', ' ', '00001'),
('00005', 5, '2024-04-08', ' ', '00001'),
('00005', 6, '2024-04-08', ' ', '00001'),
('00005', 7, '2024-04-08', ' ', '00001'),
('00005', 8, '2024-04-08', ' ', '00001'),
('00005', 9, '2024-04-08', ' ', '00001'),
('00005', 10, '2024-04-08', ' ', '00001'),
('00005', 11, '2024-04-08', ' ', '00001'),
('00005', 12, '2024-04-08', ' ', '00001'),
('00005', 13, '2024-04-08', ' ', '00001'),
('00005', 14, '2024-04-08', ' ', '00001'),
('00005', 15, '2024-04-08', ' ', '00001'),
('00005', 16, '2024-04-08', ' ', '00001'),
('00005', 17, '2024-04-08', ' ', '00001'),
('00005', 18, '2024-04-08', ' ', '00001'),
('00005', 19, '2024-04-08', ' ', '00001'),
('00005', 20, '2024-04-08', ' ', '00001'),
('00005', 21, '2024-04-08', ' ', '00001'),
('00005', 22, '2024-04-08', ' ', '00001'),
('00005', 23, '2024-04-08', ' ', '00001'),
('00005', 24, '2024-04-08', ' ', '00001'),
('00005', 25, '2024-04-08', ' ', '00001'),
('00005', 26, '2024-04-08', ' ', '00001'),
('00005', 27, '2024-04-08', ' ', '00001'),
('00005', 28, '2024-04-08', ' ', '00001'),
('00005', 29, '2024-04-08', ' ', '00001'),
('00005', 30, '2024-04-08', ' ', '00001'),
('00005', 31, '2024-04-08', ' ', '00001'),
('00005', 32, '2024-04-08', ' ', '00001'),
('00005', 33, '2024-04-08', ' ', '00001'),
('00005', 34, '2024-04-08', ' ', '00001'),
('00005', 35, '2024-04-08', ' ', '00001'),
('00005', 36, '2024-04-23', ' ', '00001'),
('00005', 37, '2024-04-23', ' ', '00001'),
('00005', 38, '2024-04-23', ' ', '00001'),
('00005', 39, '2024-04-23', ' ', '00001'),
('00005', 40, '2024-04-23', ' ', '00001'),
('00005', 41, '2024-04-23', ' ', '00001'),
('00005', 42, '2024-04-23', ' ', '00001'),
('00005', 43, '2024-04-23', ' ', '00001'),
('00005', 44, '2024-04-23', ' ', '00001'),
('00005', 45, '2024-04-23', ' ', '00001'),
('00005', 46, '2024-04-23', ' ', '00001'),
('00005', 47, '2024-04-23', ' ', '00001'),
('10002', 418, '2021-12-01', '', '00001'),
('10002', 419, '2022-02-10', '', '00001'),
('10002', 420, '2024-04-20', '', '00001'),
('10007', 3237, '2021-11-23', '', '00001'),
('10007', 3238, '2021-11-30', '', '00001'),
('10007', 3239, '2021-12-07', '', '00001'),
('10007', 3240, '2021-12-21', '', '00001'),
('10011', 505, '2022-10-16', '', '00001'),
('10011', 506, '2021-04-01', '', '00001'),
('10011', 507, '2021-05-03', '', '00001'),
('10011', 508, '2021-06-05', '', '00001'),
('10011', 509, '2021-07-01', '', '00001'),
('10011', 510, '2021-08-04', '', '00001'),
('10011', 511, '2021-09-01', '', '00001'),
('10011', 512, '2021-10-06', '', '00001'),
('10011', 513, '2021-11-01', '', '00001'),
('10011', 514, '2021-12-01', '', '00001'),
('20001', 1, '2024-04-08', ' ', '00001'),
('20001', 2, '2024-04-08', ' ', '00001'),
('20001', 3, '2024-04-08', ' ', '00001'),
('20001', 4, '2024-04-08', ' ', '00001'),
('20001', 5, '2024-04-08', ' ', '00001'),
('20001', 6, '2024-04-08', ' ', '00001'),
('20001', 7, '2024-04-08', ' ', '00001'),
('20001', 8, '2024-04-08', ' ', '00001'),
('20001', 9, '2024-04-08', ' ', '00001'),
('20001', 10, '2024-04-08', ' ', '00001'),
('20001', 11, '2024-04-15', ' ', '00001'),
('20001', 12, '2024-04-15', ' ', '00001'),
('20001', 13, '2024-04-15', ' ', '00001'),
('20001', 14, '2024-04-15', ' ', '00001'),
('20001', 15, '2024-04-15', ' ', '00001'),
('20001', 16, '2024-04-15', ' ', '00001'),
('20001', 17, '2024-04-15', ' ', '00001'),
('20001', 18, '2024-04-15', ' ', '00001'),
('20001', 19, '2024-04-15', ' ', '00001'),
('20001', 20, '2024-04-15', ' ', '00001'),
('20001', 21, '2024-04-15', ' ', '00001'),
('20001', 22, '2024-04-15', ' ', '00001'),
('20001', 23, '2024-04-15', ' ', '00001'),
('20001', 24, '2024-04-15', ' ', '00001'),
('20001', 25, '2024-04-15', ' ', '00001'),
('20001', 26, '2024-04-15', ' ', '00001'),
('20001', 27, '2024-04-15', ' ', '00001'),
('20001', 28, '2024-04-15', ' ', '00001'),
('20001', 29, '2024-04-15', ' ', '00001'),
('20001', 30, '2024-04-15', ' ', '00001'),
('20001', 31, '2024-04-15', ' ', '00001'),
('20001', 32, '2024-04-15', ' ', '00001'),
('20001', 33, '2024-04-15', ' ', '00001'),
('20001', 34, '2024-04-15', ' ', '00001'),
('20001', 35, '2024-04-15', ' ', '00001'),
('20001', 36, '2024-04-15', ' ', '00001'),
('20001', 37, '2024-04-15', ' ', '00001'),
('20001', 38, '2024-04-15', ' ', '00001'),
('20001', 39, '2024-04-15', ' ', '00001'),
('20001', 40, '2024-04-15', ' ', '00001'),
('20001', 41, '2024-04-15', ' ', '00001'),
('20001', 42, '2024-04-15', ' ', '00001'),
('20001', 43, '2024-04-15', ' ', '00001'),
('20001', 44, '2024-04-15', ' ', '00001'),
('20001', 45, '2024-04-15', ' ', '00001'),
('20001', 46, '2024-04-15', ' ', '00001'),
('20001', 47, '2024-04-15', ' ', '00001'),
('20001', 48, '2024-04-15', ' ', '00001'),
('20001', 49, '2024-04-15', ' ', '00001'),
('20001', 50, '2024-04-15', ' ', '00001'),
('20001', 51, '2024-04-15', ' ', '00001'),
('20001', 52, '2024-04-15', ' ', '00001'),
('20001', 53, '2024-04-15', ' ', '00001'),
('20001', 54, '2024-04-15', ' ', '00001'),
('20001', 55, '2024-04-15', ' ', '00001'),
('20001', 56, '2024-04-12', ' ', '00001'),
('20001', 57, '2024-04-12', ' ', '00001'),
('20001', 58, '2024-04-12', ' ', '00001'),
('20001', 59, '2024-04-12', ' ', '00001'),
('20001', 60, '2024-04-12', ' ', '00001'),
('20001', 61, '2024-04-12', ' ', '00001'),
('20001', 62, '2024-04-12', ' ', '00001'),
('20001', 63, '2024-04-12', ' ', '00001'),
('20001', 64, '2024-04-12', ' ', '00001'),
('20001', 65, '2024-04-12', ' ', '00001'),
('20001', 66, '2024-04-12', ' ', '00001'),
('20001', 67, '2024-04-12', ' ', '00001'),
('20001', 68, '2024-04-12', ' ', '00001'),
('20001', 69, '2024-04-12', ' ', '00001'),
('20001', 70, '2024-04-12', ' ', '00001'),
('20001', 71, '2024-04-12', ' ', '00001'),
('20001', 72, '2024-04-12', ' ', '00001'),
('20001', 73, '2024-04-12', ' ', '00001'),
('20001', 74, '2024-04-12', ' ', '00001'),
('20001', 75, '2024-04-12', ' ', '00001'),
('20001', 76, '2024-04-12', ' ', '00001'),
('20001', 77, '2024-04-12', ' ', '00001'),
('20001', 78, '2024-04-12', ' ', '00001'),
('20001', 79, '2024-04-12', ' ', '00001'),
('20001', 80, '2024-04-12', ' ', '00001'),
('20001', 81, '2024-04-12', ' ', '00001'),
('20001', 82, '2024-04-12', ' ', '00001'),
('20001', 83, '2024-04-12', ' ', '00001'),
('20001', 84, '2024-04-12', ' ', '00001'),
('20001', 85, '2024-04-12', ' ', '00001'),
('20001', 86, '2024-04-12', ' ', '00001'),
('20001', 87, '2024-04-12', ' ', '00001'),
('20001', 88, '2024-04-12', ' ', '00001'),
('20001', 89, '2024-04-12', ' ', '00001'),
('20001', 90, '2024-04-12', ' ', '00001'),
('20001', 91, '2024-04-12', ' ', '00001'),
('20001', 92, '2024-04-12', ' ', '00001'),
('20001', 93, '2024-04-12', ' ', '00001'),
('20001', 94, '2024-04-12', ' ', '00001'),
('20001', 95, '2024-04-12', ' ', '00001'),
('20001', 96, '2024-04-12', ' ', '00001'),
('20001', 97, '2024-04-12', ' ', '00001'),
('20001', 98, '2024-04-12', ' ', '00001'),
('20001', 99, '2024-04-12', ' ', '00001'),
('20001', 100, '2024-04-12', ' ', '00001');

-- --------------------------------------------------------

--
-- Structure de la table `genre`
--

DROP TABLE IF EXISTS `genre`;
CREATE TABLE IF NOT EXISTS `genre` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `genre`
--

INSERT INTO `genre` (`id`, `libelle`) VALUES
('10000', 'Humour'),
('10001', 'Bande dessinée'),
('10002', 'Science Fiction'),
('10003', 'Biographie'),
('10004', 'Historique'),
('10006', 'Roman'),
('10007', 'Aventures'),
('10008', 'Essai'),
('10009', 'Documentaire'),
('10010', 'Technique'),
('10011', 'Voyages'),
('10012', 'Drame'),
('10013', 'Comédie'),
('10014', 'Policier'),
('10015', 'Presse Economique'),
('10016', 'Presse Culturelle'),
('10017', 'Presse sportive'),
('10018', 'Actualités'),
('10019', 'Fantazy');

-- --------------------------------------------------------

--
-- Structure de la table `livre`
--

DROP TABLE IF EXISTS `livre`;
CREATE TABLE IF NOT EXISTS `livre` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ISBN` varchar(13) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auteur` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `collection` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `livre`
--

INSERT INTO `livre` (`id`, `ISBN`, `auteur`, `collection`) VALUES
('00001', '1234569877896', 'Fred Vargas', 'Commissaire Adamsberg'),
('00002', '1236547896541', 'Dennis Lehanne', ''),
('00003', '6541236987410', 'Anne-Laure Bondoux', ''),
('00004', '3214569874123', 'Fred Vargas', 'Commissaire Adamsberg'),
('00005', '3214563214563', 'RJ Ellory', ''),
('00006', '3213213211232', 'Edgar P. Jacobs', 'Blake et Mortimer'),
('00007', '6541236987541', 'Kate Atkinson', ''),
('00008', '1236987456321', 'Jean d\'Ormesson', ''),
('00009', '', 'Fred Vargas', 'Commissaire Adamsberg'),
('00010', '', 'Manon Moreau', ''),
('00011', '', 'Victoria Hislop', ''),
('00012', '', 'Kate Atkinson', ''),
('00013', '', 'Raymond Briggs', ''),
('00014', '', 'RJ Ellory', ''),
('00015', '', 'Floriane Turmeau', ''),
('00016', '', 'Julian Press', ''),
('00017', '', 'Philippe Masson', ''),
('00018', '', '', 'Guide du Routard'),
('00019', '', '', 'Guide Vert'),
('00020', '', '', 'Guide Vert'),
('00021', '', 'Claudie Gallay', ''),
('00022', '', 'Claudie Gallay', ''),
('00023', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00024', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00025', '', 'Ayrolles - Masbou', 'De cape et de crocs'),
('00026', '', 'Pierre Boulle', 'Julliard');

-- --------------------------------------------------------

--
-- Structure de la table `livres_dvd`
--

DROP TABLE IF EXISTS `livres_dvd`;
CREATE TABLE IF NOT EXISTS `livres_dvd` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `livres_dvd`
--

INSERT INTO `livres_dvd` (`id`) VALUES
('00001'),
('00002'),
('00003'),
('00004'),
('00005'),
('00006'),
('00007'),
('00008'),
('00009'),
('00010'),
('00011'),
('00012'),
('00013'),
('00014'),
('00015'),
('00016'),
('00017'),
('00018'),
('00019'),
('00020'),
('00021'),
('00022'),
('00023'),
('00024'),
('00025'),
('00026'),
('20001'),
('20002'),
('20003'),
('20004');

-- --------------------------------------------------------

--
-- Structure de la table `public`
--

DROP TABLE IF EXISTS `public`;
CREATE TABLE IF NOT EXISTS `public` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `public`
--

INSERT INTO `public` (`id`, `libelle`) VALUES
('00001', 'Jeunesse'),
('00002', 'Adultes'),
('00003', 'Tous publics'),
('00004', 'Ados');

-- --------------------------------------------------------

--
-- Structure de la table `rayon`
--

DROP TABLE IF EXISTS `rayon`;
CREATE TABLE IF NOT EXISTS `rayon` (
  `id` char(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rayon`
--

INSERT INTO `rayon` (`id`, `libelle`) VALUES
('BD001', 'BD Adultes'),
('BL001', 'Beaux Livres'),
('DF001', 'DVD films'),
('DV001', 'Sciences'),
('DV002', 'Maison'),
('DV003', 'Santé'),
('DV004', 'Littérature classique'),
('DV005', 'Voyages'),
('JN001', 'Jeunesse BD'),
('JN002', 'Jeunesse romans'),
('LV001', 'Littérature étrangère'),
('LV002', 'Littérature française'),
('LV003', 'Policiers français étrangers'),
('PR001', 'Presse quotidienne'),
('PR002', 'Magazines');

-- --------------------------------------------------------

--
-- Structure de la table `revue`
--

DROP TABLE IF EXISTS `revue`;
CREATE TABLE IF NOT EXISTS `revue` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `periodicite` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delaiMiseADispo` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `revue`
--

INSERT INTO `revue` (`id`, `periodicite`, `delaiMiseADispo`) VALUES
('10001', 'MS', 52),
('10002', 'MS', 52),
('10003', 'HB', 15),
('10004', 'HB', 15),
('10005', 'QT', 5),
('10006', 'QT', 5),
('10007', 'HB', 26),
('10008', 'HB', 26),
('10009', 'QT', 5),
('10010', 'HB', 12),
('10011', 'MS', 52);

-- --------------------------------------------------------

--
-- Structure de la table `service`
--

DROP TABLE IF EXISTS `service`;
CREATE TABLE IF NOT EXISTS `service` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `service`
--

INSERT INTO `service` (`id`, `service`) VALUES
('1', 'Administratif'),
('2', 'Médiation culturelle'),
('3', 'Prêt');

-- --------------------------------------------------------

--
-- Structure de la table `suivi`
--

DROP TABLE IF EXISTS `suivi`;
CREATE TABLE IF NOT EXISTS `suivi` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `etape` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `suivi`
--

INSERT INTO `suivi` (`id`, `etape`) VALUES
('1', 'en cours'),
('2', 'relancée'),
('3', 'livrée'),
('4', 'réglée');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idService` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idService` (`idService`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `nom`, `password`, `idService`) VALUES
('5', 'evacaron', 'password123', '2'),
('4', 'dianepetit', 'password123', '2'),
('3', 'charlieleroy', 'password123', '2'),
('2', 'bobmartin', 'password123', '1'),
('1', 'alicedupont', 'password123', '1'),
('6', 'francoidurant', 'password123', '3'),
('7', 'gisellelefevre', 'password123', '3'),
('8', 'hugomoreau', 'password123', '3'),
('9', 'irisbrunet', 'password123', '3'),
('10', 'julesblanchard', 'password123', '1'),
('12', 'fred', 'f@Bts24', '2'),
('13', 'megane', 'm@Bts24', '1'),
('15', 'adminmediatekdoc', 'P@$$word2024', '1'),
('14', 'jean', 'j@Bts24', '3');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `abonnement`
--
ALTER TABLE `abonnement`
  ADD CONSTRAINT `abonnement_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `abonnement_ibfk_2` FOREIGN KEY (`idRevue`) REFERENCES `revue` (`id`);

--
-- Contraintes pour la table `commandedocument`
--
ALTER TABLE `commandedocument`
  ADD CONSTRAINT `commandedocument_ibfk_1` FOREIGN KEY (`id`) REFERENCES `commande` (`id`),
  ADD CONSTRAINT `commandedocument_ibfk_2` FOREIGN KEY (`idLivreDvd`) REFERENCES `livres_dvd` (`id`),
  ADD CONSTRAINT `commandedocument_ibfk_3` FOREIGN KEY (`idEtape`) REFERENCES `suivi` (`id`);

--
-- Contraintes pour la table `document`
--
ALTER TABLE `document`
  ADD CONSTRAINT `document_ibfk_1` FOREIGN KEY (`idRayon`) REFERENCES `rayon` (`id`),
  ADD CONSTRAINT `document_ibfk_2` FOREIGN KEY (`idPublic`) REFERENCES `public` (`id`),
  ADD CONSTRAINT `document_ibfk_3` FOREIGN KEY (`idGenre`) REFERENCES `genre` (`id`);

--
-- Contraintes pour la table `dvd`
--
ALTER TABLE `dvd`
  ADD CONSTRAINT `dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `exemplaire`
--
ALTER TABLE `exemplaire`
  ADD CONSTRAINT `exemplaire_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`),
  ADD CONSTRAINT `exemplaire_ibfk_2` FOREIGN KEY (`idEtat`) REFERENCES `etat` (`id`);

--
-- Contraintes pour la table `livre`
--
ALTER TABLE `livre`
  ADD CONSTRAINT `livre_ibfk_1` FOREIGN KEY (`id`) REFERENCES `livres_dvd` (`id`);

--
-- Contraintes pour la table `livres_dvd`
--
ALTER TABLE `livres_dvd`
  ADD CONSTRAINT `livres_dvd_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);

--
-- Contraintes pour la table `revue`
--
ALTER TABLE `revue`
  ADD CONSTRAINT `revue_ibfk_1` FOREIGN KEY (`id`) REFERENCES `document` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
